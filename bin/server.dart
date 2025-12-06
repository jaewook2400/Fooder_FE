import 'package:fooder_fe/local_database.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:postgres/postgres.dart';

Future<void> main() async {

  final conn = await Connection.open(Endpoint
    (
      host: 'localhost',
      port: 5432,
      database: 'fooder_app',
      username: 'postgres',
      password: '5632',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
  print("-----PostgreSQL connected!-----");

  final result = await conn.execute(
    Sql.named('SELECT * FROM users'),
  );
  print(result.first.toColumnMap());

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080, shared: true);
  print('-----Server running on http://${server.address.host}:${server.port}-----');

  await for (final request in server){

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    // 공통 헤더 (JSON & CORS)
    _applyCommonHeaders(request.response);

    try {
      final method = request.method;
      final path = request.uri.path; // e.g., /api/recipe/3/like
      final segments = request.uri.pathSegments; // [api, recipe, 3, like]

      // 로그용 기본 정보
      final startedAt = DateTime.now();
      final ip = request.connectionInfo?.remoteAddress.address ?? '-';
      final query = request.uri.query.isNotEmpty ? '?${request.uri.query}' : '';
      final authHeaderForLog = request.headers.value(HttpHeaders.authorizationHeader);
      final userForLog = _extractUserFromAuth(authHeaderForLog);

// 응답이 끝난 직후(status 확정) 예쁘게 한 줄 로그
      request.response.done.then((_) async {
        final elapsed = DateTime.now().difference(startedAt).inMilliseconds;
        final status = request.response.statusCode;
        _printAccessLog(
          method: method,
          path: '$path$query',
          status: status,
          ms: elapsed,
          user: userForLog,
          ip: ip,
        );
      });

// 1) Public API는 토큰 검사 없이 통과
      if (!_isPublicEndpoint(method, path, segments)) {
        final authHeader = request.headers.value(HttpHeaders.authorizationHeader);

        // 2) 토큰 없거나 유효하지 않으면 401
        if (!await _validateToken(authHeader, conn)) {
          _unauthorized(request, 'invalid or missing token');
          continue;
        }
      }

// 3) 토큰이 유효하니 user 추출 가능
      final user = _extractUserFromAuth(
          request.headers.value(HttpHeaders.authorizationHeader)
      );

      // --------------- 온보딩 ---------------

      // POST /api/register
      if (method == 'POST' && path == '/api/register') {
        final body = await _readJson(request);
        final username = (body['username'] ?? '').toString();
        final password = (body['password'] ?? '').toString();

        if (username.isEmpty || password.isEmpty) {
          return _badRequest(request, 'username/password required');
        }

        //1. username 중복 체크
        final check = await conn.execute(
          Sql.named('SELECT user_id FROM users WHERE username = @u'),
          parameters: {'u': username},
        );

        if (check.isNotEmpty) {
          return _badRequest(request, 'already registered');
        }

        //2. 회원정보 저장
        await conn.execute(
          Sql.named('''
          INSERT INTO users (username, password_hash)
          VALUES (@u, @p)
        '''),
          parameters: {
            'u': username,
            'p': password,  // 나중에 bcrypt로 바꾸면 좋음
          },
        );

        print('----- User registered: $username -----');

        _okJson(request, {
          'message': 'registered',
          'token': 'token-$username',
          'username': username,
        });
        continue;
      }

      // POST /api/login
      if (method == 'POST' && path == '/api/login') {
        final body = await _readJson(request);
        final username = (body['username'] ?? '').toString();
        final password = (body['password'] ?? '').toString();

        if (username.isEmpty || password.isEmpty) {
          return _badRequest(request, 'username/password required');
        }

        final result = await conn.execute(
          Sql.named('SELECT password_hash FROM users WHERE username = @u'),
          parameters: {'u': username},
        );

        if (result.isEmpty) return _badRequest(request, 'invalid credentials');
        ;

        final dbPassword = result.first[0];

        if (dbPassword != password) return _badRequest(request, 'invalid credentials');

        _okJson(request, {
          'message': 'logged in',
          'token': 'token-$username',
          'username': username,
        });
        continue;
      }

      // --------------- 홈 ---------------

      // GET /api/home/recent (가장 최근 레시피 1개 조회)
      if (method == 'GET' && path == '/api/home/recent') {
        // 1. 가장 최근에 추가된 레시피 1개 조회 (recipe_id 기준 내림차순 정렬)
        final recipeRows = await conn.execute(
          Sql.named('''
      SELECT recipe_id, name, time_to_cook, image_url
      FROM recipes
      ORDER BY recipe_id DESC
      LIMIT 1
    '''),
        );

        if (recipeRows.isEmpty) {
          // 레시피가 하나도 없는 경우 빈 객체 또는 null 반환 (상황에 맞게 처리)
          _okJson(request, {});
          continue;
        }

        final r = recipeRows.first.toColumnMap();
        final recipeId = r['recipe_id'];

        // 2. 해당 레시피의 재료 조회
        final ingRows = await conn.execute(
          Sql.named('''
      SELECT ingredient
      FROM recipe_ingredients
      WHERE recipe_id = @id
    '''),
          parameters: {'id': recipeId},
        );

        final ingredient = ingRows.map((row) => row[0] as String).toList();

        // 3. 응답 JSON 생성
        _okJson(request, {
          'recipeId': recipeId,
          'name': r['name'],
          'timeToCook': r['time_to_cook'],
          'ingredient': ingredient,
          'imageUrl': r['image_url'],
        });
        continue;
      }

      // GET /api/home/ingredient
      if (method == 'GET' && path == '/api/home/ingredient') {
        // ingredients 테이블에서 모든 재료 조회
        final rows = await conn.execute(
          Sql.named('''
      SELECT ingredient, image_url
      FROM recommend_ingredients
      ORDER BY id
      LIMIT 10
    '''),
        );

        // 결과를 Map 형태로 변환
        final ingredients = rows.map((row) => {
          'ingredient': row[0] as String,
          'imageUrl': row[1] as String,
        }).toList();

        _okJson(request, {'ingredients': ingredients});
        continue;
      }

      // POST /api/home/preference
      if (method == 'POST' && path == '/api/home/preference') {
        final body = await _readJson(request);

        // 1) 클라이언트에서 좋아요한 재료 문자열 리스트를 받는다.
        final preferredIngredients = (body['preference'] as List?)?.cast<String>() ?? [];
        print('/preference from $user: $preferredIngredients');

        if (preferredIngredients.isEmpty) {
          return _badRequest(request, 'empty preferred ingredients');
        }

        // 3) AI 추천 함수 호출
        final recommended = await aiMadeRecipe(preferredIngredients);
        // recommended 예: { recipeName: ..., ingredients: [...], steps: [...], imageUrl: ... }

        // 4) DB 저장
        // 4-1) recipes 저장
        final insertedRecipe = await conn.execute(
          Sql.named('''
      INSERT INTO recipes (name, time_to_cook, description, image_url)
      VALUES (@n, @t, @d, @img)
      RETURNING recipe_id, name, time_to_cook, description, image_url
    '''),
          parameters: {
            'n': recommended['name'],
            't': recommended['time_to_cook'],
            'd': recommended['description'],
            'img': recommended['imageUrl'],
          },
        );

        final recipe = insertedRecipe.first.toColumnMap();
        final recipeId = recipe['recipe_id'];

        // 4-2) recipe_ingredients 저장
        for (final ing in recommended['ingredient']) {
          await conn.execute(
            Sql.named('''
        INSERT INTO recipe_ingredients (recipe_id, ingredient)
        VALUES (@id, @ing)
      '''),
            parameters: {'id': recipeId, 'ing': ing},
          );
        }

        // 4-3) recipe_steps 저장
        final steps = (recommended['steps'] as List?)?.cast<String>() ?? [];

        for (int i = 0; i < steps.length; i++) {
          await conn.execute(
            Sql.named('''
        INSERT INTO recipe_steps (recipe_id, step_order, step_text)
        VALUES (@id, @order, @text)
      '''),
            parameters: {
              'id': recipeId,
              'order': i + 1,   // step_order는 1부터 시작
              'text': steps[i],
            },
          );
        }

        print("-----새 레시피 저장 완료: ID=$recipeId-----");

        // 5) 생성된 레시피 클라이언트에 응답
        _okJson(request, {
          'recipe': {
            'recipeId': recipeId,
            'name': recipe['name'],
            'timeToCook': recipe['time_to_cook'],
            'description': recipe['description'],
            'imageUrl': recipe['image_url'],
            'ingredient': recommended['ingredient'],
            'steps': steps,
          }
        });
        continue;
      }

      // DELETE /api/home/:recipeId
      if (method == 'DELETE' &&
          segments.length == 3 &&
          segments[0] == 'api' &&
          segments[1] == 'home') {

        final id = int.tryParse(segments[2]);
        if (id == null) return _badRequest(request, 'invalid recipeId');

        print('-----DELETE recipe $id from DB-----');

        final deleted = await conn.execute(
          Sql.named('''
      DELETE FROM recipes
      WHERE recipe_id = @id
      RETURNING recipe_id
    '''),
          parameters: {'id': id},
        );

        if (deleted.isEmpty) {
          return _notFound(request, 'recipe not found');
        }

        // recipe_ingredients, user_liked_recipes, user_recorded_recipes는
        // FK ON DELETE CASCADE 덕분에 자동 삭제됨

        _okJson(request, {
          'message': 'recipe deleted',
          'recipeId': id,
        });
        continue;
      }

      // --------------- 레시피 ---------------

      // GET /api/recipe/like  (좋아요한 레시피 목록: DB 연동) (recipe API의 맨 위에 이게 있어야 함)
      if (method == 'GET' && path == '/api/recipe/like') {
        // 1) username → user_id 조회
        final userRows = await conn.execute(
          Sql.named('SELECT user_id FROM users WHERE username = @u'),
          parameters: {'u': user},
        );

        if (userRows.isEmpty) {
          return _unauthorized(request, 'user not found');
        }

        final userId = userRows.first[0] as int;

        // 2) 좋아요한 레시피 조회 (JOIN)
        // [수정] SELECT 절에 r.time_to_cook 추가
        final rows = await conn.execute(
          Sql.named('''
      SELECT r.recipe_id, r.name, r.description, r.image_url, r.time_to_cook
      FROM user_liked_recipes ul
      JOIN recipes r ON ul.recipe_id = r.recipe_id
      WHERE ul.user_id = @uid
      ORDER BY r.recipe_id
    '''),
          parameters: {'uid': userId},
        );

        final likedRecipes = rows.map((row) => {
          "recipeId": row[0],
          "name": row[1],
          "description": row[2],
          "imageUrl": row[3],
          "timeToCook": row[4], // [수정] 응답 JSON에 timeToCook 매핑 (인덱스 4)
        }).toList();

        _okJson(request, {
          'recipes': likedRecipes,
          'count': likedRecipes.length,
        });
        continue;
      }


      // GET /api/recipe  (전체 레시피: DB 연동)
      if (method == 'GET' && path == '/api/recipe') {
        // 1) 레시피 기본 정보 조회
        final recipeRows = await conn.execute(
          Sql.named('''
      SELECT recipe_id, name, time_to_cook, description, image_url
      FROM recipes
      ORDER BY recipe_id
    '''),
        );

        final recipes = [];

        for (final row in recipeRows) {
          final r = row.toColumnMap();
          final recipeId = r['recipe_id'];

          // 2) 재료 조회
          final ingRows = await conn.execute(
            Sql.named('''
        SELECT ingredient
        FROM recipe_ingredients
        WHERE recipe_id = @id
      '''),
            parameters: {'id': recipeId},
          );
          final ingredient = ingRows.map((i) => i[0] as String).toList();

          // 3) 조리 단계 조회
          final stepRows = await conn.execute(
            Sql.named('''
        SELECT step_order, step_text
        FROM recipe_steps
        WHERE recipe_id = @id
        ORDER BY step_order
      '''),
            parameters: {'id': recipeId},
          );
          final steps = stepRows.map((s) => s.toColumnMap()).toList();

          // 4) 하나의 레시피 JSON으로 구성
          recipes.add({
            'recipeId': recipeId,
            'name': r['name'],
            'timeToCook': r['time_to_cook'],
            'description': r['description'],
            'imageUrl': r['image_url'],
            'ingredient': ingredient,
            'steps': steps.map((s) => s['step_text']).toList(),
          });
        }

        _okJson(request, {'recipes': recipes});
        continue;
      }

      // GET /api/recipe/:recipeId (상세, DB 연동)
      if (method == 'GET' &&
          segments.length == 3 &&
          segments[0] == 'api' &&
          segments[1] == 'recipe') {

        final id = int.tryParse(segments[2]);
        if (id == null) return _badRequest(request, 'invalid recipeId');

        // 1) 레시피 기본 정보 조회
        final recipeRows = await conn.execute(
          Sql.named('''
      SELECT recipe_id, name, time_to_cook, description, image_url
      FROM recipes
      WHERE recipe_id = @id
    '''),
          parameters: {'id': id},
        );

        if (recipeRows.isEmpty) {
          return _notFound(request, 'recipe not found');
        }

        final r = recipeRows.first.toColumnMap();

        // 2) 재료 조회
        final ingRows = await conn.execute(
          Sql.named('''
      SELECT ingredient
      FROM recipe_ingredients
      WHERE recipe_id = @id
    '''),
          parameters: {'id': id},
        );
        final ingredient = ingRows.map((x) => x[0] as String).toList();

        // 3) 조리 단계 조회
        final stepRows = await conn.execute(
          Sql.named('''
      SELECT step_order, step_text
      FROM recipe_steps
      WHERE recipe_id = @id
      ORDER BY step_order
    '''),
          parameters: {'id': id},
        );
        final steps = stepRows.map((s) => s[1] as String).toList();

        // 4) 응답
        _okJson(request, {
          'recipe': {
            'recipeId': r['recipe_id'],
            'name': r['name'],
            'timeToCook': r['time_to_cook'],
            'description': r['description'],
            'imageUrl': r['image_url'],
            'ingredient': ingredient,
            'steps': steps,
          }
        });

        continue;
      }


      // POST /api/recipe/:recipeId/like  (DB 연동)
      if (method == 'POST' &&
          segments.length == 4 &&
          segments[0] == 'api' &&
          segments[1] == 'recipe' &&
          segments[3] == 'like') {

        final id = int.tryParse(segments[2]);
        if (id == null) return _badRequest(request, 'invalid recipeId');

        // 1) username -> user_id 조회
        final userRows = await conn.execute(
          Sql.named('SELECT user_id FROM users WHERE username = @u'),
          parameters: {'u': user},
        );

        if (userRows.isEmpty) {
          // 토큰에 있는 username이 DB에 없는 경우
          return _unauthorized(request, 'user not found');
        }

        final userId = userRows.first[0] as int;

        // 2) 레시피 존재 여부 확인
        final recipeRows = await conn.execute(
          Sql.named('SELECT recipe_id FROM recipes WHERE recipe_id = @id'),
          parameters: {'id': id},
        );

        if (recipeRows.isEmpty) {
          return _notFound(request, 'recipe not found');
        }

        // 3) 이미 좋아요 했는지 확인
        final alreadyRows = await conn.execute(
          Sql.named('''
      SELECT id 
      FROM user_liked_recipes
      WHERE user_id = @uid AND recipe_id = @rid
    '''),
          parameters: {
            'uid': userId,
            'rid': id,
          },
        );

        if (alreadyRows.isEmpty) {
          // 4) 없으면 새로 INSERT
          await conn.execute(
            Sql.named('''
        INSERT INTO user_liked_recipes (user_id, recipe_id)
        VALUES (@uid, @rid)
      '''),
            parameters: {
              'uid': userId,
              'rid': id,
            },
          );
          print('-----user $userId liked recipe $id-----');
        } else {
          print('=====user $userId already liked recipe $id=====');
        }

        _okJson(request, {'message': 'liked', 'recipeId': id});
        continue;
      }

      // DELETE /api/recipe/:recipeId/like  (DB 연동)
      if (method == 'DELETE' &&
          segments.length == 4 &&
          segments[0] == 'api' &&
          segments[1] == 'recipe' &&
          segments[3] == 'like') {

        final id = int.tryParse(segments[2]);
        if (id == null) return _badRequest(request, 'invalid recipeId');

        // 1) username → user_id 조회
        final userRows = await conn.execute(
          Sql.named('SELECT user_id FROM users WHERE username = @u'),
          parameters: {'u': user},
        );

        if (userRows.isEmpty) {
          return _unauthorized(request, 'user not found');
        }

        final userId = userRows.first[0] as int;

        // 2) 좋아요 레코드 삭제
        final deleted = await conn.execute(
          Sql.named('''
      DELETE FROM user_liked_recipes
      WHERE user_id = @uid AND recipe_id = @rid
    '''),
          parameters: {
            'uid': userId,
            'rid': id,
          },
        );

        final affected = deleted.affectedRows;

        if (affected == 0) {
          print('=====좋아요 상태가 아니었음 (user=$userId, recipe=$id)=====');
        } else {
          print('-----좋아요 취소됨 (user=$userId, recipe=$id)-----');
        }

        _okJson(request, {'message': 'unliked', 'recipeId': id});
        continue;
      }

      // --------------- 기록(Record) ---------------

      // GET /api/record/recipe  (기록된 레시피)
      if (method == 'GET' && path == '/api/record/recipe') {
        // 1) username → user_id 조회
        final userRow = await conn.execute(
          Sql.named('SELECT user_id FROM users WHERE username = @u'),
          parameters: {'u': user},
        );

        if (userRow.isEmpty) return _unauthorized(request, 'user not found');
        final userId = userRow.first[0] as int;

        // 2) recorded된 recipe_id 및 recorded_at 목록 가져오기
        // [수정] recorded_at 컬럼 추가 조회
        final recordedRows = await conn.execute(
          Sql.named('''
      SELECT recipe_id, recorded_at
      FROM user_recorded_recipes
      WHERE user_id = @uid
    '''),
          parameters: {'uid': userId},
        );

        if (recordedRows.isEmpty) {
          _okJson(request, {'recipes': [], 'count': 0});
          continue;
        }

        // recipe_id 리스트 추출
        final recordedIds = recordedRows.map((r) => r[0] as int).toList();

        // recipe_id -> recorded_at 매핑 (하나의 레시피를 여러 번 기록했을 수도 있으므로 로직 주의)
        // 여기서는 가장 최근 기록 혹은 단순 매핑으로 처리.
        // 만약 같은 레시피를 여러 날짜에 기록했다면 구조를 조금 더 복잡하게 가져가야 하지만,
        // 현재 구조상 1:1 매핑 혹은 단순 리스트 매핑으로 가정하고 진행합니다.
        final recordedAtMap = <int, String>{};
        for (final row in recordedRows) {
          final rid = row[0] as int;
          final rAt = row[1]; // DateTime or String
          if (rAt != null) {
            recordedAtMap[rid] = rAt.toString();
          }
        }

        // 3) recipe 상세 JOIN해서 가져오기
        final recipesRows = await conn.execute(
          Sql.named('''
      SELECT r.recipe_id, r.name, r.time_to_cook, r.description, r.image_url
      FROM recipes r
      WHERE r.recipe_id = ANY(@ids)
    '''),
          parameters: {'ids': recordedIds},
        );

        // 4) 재료 목록 가져오기
        final ingredientRows = await conn.execute(
          Sql.named('''
      SELECT recipe_id, ingredient
      FROM recipe_ingredients
      WHERE recipe_id = ANY(@ids)
      ORDER BY recipe_id
    '''),
          parameters: {'ids': recordedIds},
        );

        // recipe_id → ingredient 리스트 맵핑
        final ingredientMap = <int, List<String>>{};
        for (final row in ingredientRows) {
          final rid = row[0] as int;
          final ing = row[1] as String;
          ingredientMap.putIfAbsent(rid, () => []).add(ing);
        }

        // ★ 최종 응답으로 묶기
        final result = [];

        for (final row in recipesRows) {
          final map = row.toColumnMap();
          final rId = map['recipe_id'];

          result.add({
            'recipeId': rId,
            'name': map['name'],
            'timeToCook': map['time_to_cook'],
            'description': map['description'],
            'imageUrl': map['image_url'],
            'ingredient': ingredientMap[rId] ?? [],
            'recordedAt': recordedAtMap[rId], // [추가] 기록된 날짜 포함
          });
        }

        _okJson(request, {'recipes': result, 'count': result.length});
        continue;
      }

      // DELETE /api/record/:recipeId  (기록된 레시피 삭제 = 레시피 영구 삭제)
      if (method == 'DELETE' &&
          segments.length == 3 &&
          segments[0] == 'api' &&
          segments[1] == 'record') {

        final id = int.tryParse(segments[2]);
        if (id == null) return _badRequest(request, 'invalid recipeId');

        // 🔐 유저 인증 정보에서 username 얻기
        final username = _extractUserFromAuth(
            request.headers.value(HttpHeaders.authorizationHeader)
        );

        // username → user_id 매핑
        final userRow = await conn.execute(
          Sql.named('SELECT user_id FROM users WHERE username = @u'),
          parameters: {'u': username},
        );
        if (userRow.isEmpty) return _unauthorized(request, 'user not found');

        final userId = userRow.first[0];

        // 1) 이 레시피가 이 유저가 기록한 레시피인지 확인
        final check = await conn.execute(
          Sql.named('''
      SELECT id FROM user_recorded_recipes
      WHERE user_id = @uid AND recipe_id = @rid
    '''),
          parameters: {'uid': userId, 'rid': id},
        );

        if (check.isEmpty) {
          return _notFound(request, 'recipe not found or not yours');
        }

        // 2) recorded 기록 먼저 삭제
        await conn.execute(
          Sql.named('DELETE FROM user_recorded_recipes WHERE recipe_id = @rid'),
          parameters: {'rid': id},
        );

        // 3) steps 삭제
        await conn.execute(
          Sql.named('DELETE FROM recipe_steps WHERE recipe_id = @rid'),
          parameters: {'rid': id},
        );

        // 4) ingredients 삭제
        await conn.execute(
          Sql.named('DELETE FROM recipe_ingredients WHERE recipe_id = @rid'),
          parameters: {'rid': id},
        );

        // 5) recipes 삭제 (마지막)
        await conn.execute(
          Sql.named('DELETE FROM recipes WHERE recipe_id = @rid'),
          parameters: {'rid': id},
        );

        _okJson(request, {
          'message': 'recipe permanently deleted',
          'recipeId': id
        });

        continue;
      }

      // POST /api/record/recipe (수동 추가)
      if (method == 'POST' && path == '/api/record/recipe') {
        final body = await _readJson(request);

        final recipeName = body['name'] ?? '';
        final description = body['description'] ?? '';
        final imageUrl = body['imageUrl'] ?? '';
        // [수정] timeToCook은 int로 변환 (기본값 0)
        final timeToCook = body['timeToCook'] is int
            ? body['timeToCook']
            : int.tryParse(body['timeToCook'].toString()) ?? 0;
        final steps = (body['steps'] as List?)?.cast<String>() ?? [];
        final ingredient = (body['ingredient'] as List?)?.cast<String>() ?? [];

        if (recipeName.isEmpty || ingredient.isEmpty) {
          return _badRequest(request, 'name and ingredients are required');
        }

        // 1) username → user_id 조회
        final userRow = await conn.execute(
          Sql.named('SELECT user_id FROM users WHERE username = @u'),
          parameters: {'u': user},
        );

        if (userRow.isEmpty) return _unauthorized(request, 'user not found');
        final userId = userRow.first[0] as int;

        // 2) recipes 테이블에 저장 (time_to_cook 추가)
        final inserted = await conn.execute(
          Sql.named('''
      INSERT INTO recipes (name, description, image_url, time_to_cook)
      VALUES (@n, @d, @img, @time)
      RETURNING recipe_id, name, description, image_url, time_to_cook
    '''),
          parameters: {
            'n': recipeName,
            'd': description,
            'img': imageUrl,
            'time': timeToCook, // [추가] 조리 시간 저장
          },
        );

        final recipe = inserted.first.toColumnMap();
        final recipeId = recipe['recipe_id'];

        // 3) 재료 저장
        for (final ing in ingredient) {
          await conn.execute(
            Sql.named('''
        INSERT INTO recipe_ingredients (recipe_id, ingredient)
        VALUES (@id, @ing)
      '''),
            parameters: {'id': recipeId, 'ing': ing},
          );
        }

        // 4) [추가] 조리 순서(Steps) 저장
        // recipe_steps 테이블이 있다고 가정 (step_order, description 컬럼 필요)
        for (int i = 0; i < steps.length; i++) {
          await conn.execute(
            Sql.named('''
        INSERT INTO recipe_steps (recipe_id, step_order, description)
        VALUES (@id, @order, @desc)
      '''),
            parameters: {
              'id': recipeId,
              'order': i + 1, // 1부터 시작하는 순서
              'desc': steps[i],
            },
          );
        }

        // 5) user_recorded_recipes 저장
        await conn.execute(
          Sql.named('''
      INSERT INTO user_recorded_recipes (user_id, recipe_id)
      VALUES (@uid, @rid)
    '''),
          parameters: {'uid': userId, 'rid': recipeId},
        );

        print("-----수동 레시피 추가 완료 → recipeId=$recipeId-----");

        // 6) 클라이언트에 응답
        _okJson(request, {
          'message': 'recorded added',
          'recipe': {
            'recipeId': recipeId,
            'name': recipe['name'],
            'description': recipe['description'],
            'imageUrl': recipe['image_url'],
            'timeToCook': recipe['time_to_cook'],
            'ingredient': ingredient,
            'steps': steps,
          }
        });
        continue;
      }

      // --------------- 이미지 URL 생성(Mock) ---------------

      // POST /api/imageUrl
      if (method == 'POST' && path == '/api/imageUrl') {
        final seed = DateTime.now().millisecondsSinceEpoch;
        final url = 'https://picsum.photos/seed/$seed/300/400';
        _okJson(request, {'imageUrl': url});
        continue;
      }

      // GET /api/debug/userinfo -- 디버깅용 API!!
      // if (method == 'GET' && path == '/api/debug/userinfo') {
      //   final pretty = const JsonEncoder.withIndent('  ').convert({
      //     'userInfo': userInfo
      //   });
      //
      //   request.response
      //     ..statusCode = HttpStatus.ok
      //     ..headers.contentType = ContentType.json
      //     ..write(pretty)
      //     ..close();
      //
      //   continue;
      // }


      //-----------디버깅용-----------

      // GET /api/debug/recipe-count
      if (method == 'GET' && path == '/api/debug/recipe-count') {
        final rows = await conn.execute(
          Sql.named('SELECT COUNT(*) FROM recipes'),
        );

        final count = rows.first[0];

        _okJson(request, {
          'recipeCount': count,
        });
        continue;
      }


      // --------------- 기본 404 ---------------
      return _notFound(request, 'Endpoint not found: $method $path');
    } catch (e, st) {
      print('=====Error: $e\n$st=====');
      _serverError(request, 'internal error');
    }
  }
}

Future<Map<String, dynamic>> aiMadeRecipe(List<String> ingredient) async {
  return {
    'name': 'AI 추천 계란볶음밥',
    'time_to_cook': '5',
    'description': '선호 재료 기반 자동 생성 레시피',
    'ingredient': ['계란', '밥', '대파'],
    'steps': ['1. 준비한다', '2. 볶는다'],
    'imageUrl': 'https://recipe1.ezmember.co.kr/cache/recipe/2018/04/04/833880e807106a8288be48259b19c4031.jpg'
  };
}


// ----------------- 유틸 -----------------

String _statusMark(int status) {
  if (status >= 500) return '=====';
  if (status >= 400) return '====';
  if (status >= 300) return '===';
  if (status >= 200) return '---';
  return '-';
}

void _printAccessLog({
  required String method,
  required String path,
  required int status,
  required int ms,
  required String user,
  required String ip,
}){
  final mark = _statusMark(status);
  final m = method.padRight(6); // GET/POST 정렬
  // 예: 200  12ms  GET   /api/recipe/1        user1    127.0.0.1
  print('$mark $status  ${ms}ms  $m $path    $user    $ip');
}

String _extractUserFromAuth(String? authHeader) {
  // Authorization: Bearer token-<username> 또는 Bearer <username>
  if (authHeader == null) return 'user1';
  final parts = authHeader.split(' ');
  if (parts.length >= 2 && parts[0].toLowerCase() == 'bearer') {
    final token = parts[1];
    // token-username 또는 username 모두 허용
    final u = token.startsWith('token-') ? token.substring(6) : token;
    return u.isEmpty ? 'user1' : u;
  }
  return 'user1';
}

bool _isPublicEndpoint(String method, String path, List<String> segments) {
  // POST /api/register
  if (method == 'POST' && path == '/api/register') return true;

  // POST /api/login
  if (method == 'POST' && path == '/api/login') return true;

  // POST /api/imageUrl
  if (method == 'POST' && path == '/api/imageUrl') return true;

  // GET /api/recipe
  if (method == 'GET' && path == '/api/recipe') return true;

  // GET /api/recipe/:id
  if (method == 'GET' &&
      segments.length == 3 &&
      segments[0] == 'api' &&
      segments[1] == 'recipe') {
    return true;
  }

  return false;
}

Future<bool> _validateToken(String? authHeader, Connection conn) async {
  print('-----validateToken() called. authHeader = $authHeader -----');

  if (authHeader == null) {
    print('=====No Authorization header======');
    return false;
  }

  final parts = authHeader.split(' ');
  if (parts.length != 2 || parts[0].toLowerCase() != 'bearer') {
    print('=====Header format invalid: $authHeader=====');
    return false;
  }

  final token = parts[1];
  if (!token.startsWith('token-')) {
    print('=====Token does not start with token- prefix=====');
    return false;
  }

  final username = token.substring(6);
  if (username.isEmpty) {
    print('=====Username empty in token=====');
    return false;
  }

  print('------ Checking DB for username "$username"... -----');

  final rows = await conn.execute(
    Sql.named('SELECT user_id FROM users WHERE username = @u'),
    parameters: {'u': username},
  );

  return rows.isNotEmpty;
}


void _applyCommonHeaders(HttpResponse res) {
  res.headers.contentType = ContentType.json;
  // CORS (필요시)
  res.headers.set('Access-Control-Allow-Origin', '*');
  res.headers.set('Access-Control-Allow-Headers', '*');
  res.headers.set('Access-Control-Allow-Methods', 'GET,POST,DELETE,OPTIONS');
}

Future<Map<String, dynamic>> _readJson(HttpRequest req) async {
  final text = await utf8.decoder.bind(req).join();
  print("-----BODY: $text-----");
  final data = jsonDecode(text);
  if (data is Map<String, dynamic>) return data;
  throw const FormatException('JSON object required');
}

void _okJson(HttpRequest req, Object obj) {
  req.response
    ..statusCode = HttpStatus.ok
    ..write(jsonEncode(obj))
    ..close();
}

void _badRequest(HttpRequest req, String msg) {
  req.response
    ..statusCode = HttpStatus.badRequest
    ..write(jsonEncode({'error': msg}))
    ..close();
}

void _unauthorized(HttpRequest req, String msg) {
  req.response
    ..statusCode = HttpStatus.unauthorized
    ..write(jsonEncode({'error': msg}))
    ..close();
}

void _notFound(HttpRequest req, String msg) {
  req.response
    ..statusCode = HttpStatus.notFound
    ..write(jsonEncode({'error': msg}))
    ..close();
}

void _serverError(HttpRequest req, String msg) {
  req.response
    ..statusCode = HttpStatus.internalServerError
    ..write(jsonEncode({'error': msg}))
    ..close();
}
