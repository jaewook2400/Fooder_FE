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

      // GET /api/home/ingredient
      if (method == 'GET' && path == '/api/home/ingredient') {
        // DB에서 중복 없이 10개 재료 조회
        final rows = await conn.execute(
          Sql.named('''
        SELECT DISTINCT ingredient
        FROM recipe_ingredients
        LIMIT 10
      '''),
        );

        // rows는 List<List<dynamic>> 형태 → rows[i][0] 사용
        final ingredients = rows.map((row) => row[0] as String).toList();
        _okJson(request, {'ingredient': ingredients});
        continue;
      }

      // POST /api/home/preference
      if (method == 'POST' && path == '/api/home/preference') {
        final body = await _readJson(request);
        final prefs = (body['preference'] as List?)?.cast<bool>() ?? const <bool>[];
        print('📩 /preference from $user: $prefs');

        // TODO: 선호도 기반 추천 알고리즘
        // 지금은 목데이터: AIMadeRecipe 있으면 우선, 없으면 recipes[0]
        final result = Map<String, dynamic>.from(aiMadeRecipe);
        _okJson(request, result);
        continue;
      }

      // DELETE /api/home/:recipeId  (레시피 미선택: 목 처리)
      if (method == 'DELETE' &&
          segments.length == 3 &&
          segments[0] == 'api' &&
          segments[1] == 'home') {
        final id = int.tryParse(segments[2]);
        if (id == null) return _badRequest(request, 'invalid recipeId-1');
        // 실제 로직이 정해지지 않았으므로 수신만 확인
        print('🗑️  unselect recipe $id for $user');
        _okJson(request, {'message': 'unselected', 'recipeId': id});
        continue;
      }

      // --------------- 레시피 ---------------

      // GET /api/recipe/like   (좋아요한 레시피 목록) -- 항상 /api/recipe 보단 위에 있어야 함!(특수한 케이스가 일반적인 케이스보다 먼저)
      if (method == 'GET' && path == '/api/recipe/like') {
        final profile = userInfo.putIfAbsent(user, () => {
          'likedRecipeId': <int>[],
          'recordedRecipe': <Map<String, dynamic>>[],
        });
        final likedIds = (profile['likedRecipeId'] as List).cast<int>();
        final likedRecipes = recipes.where((r) => likedIds.contains(r['recipeId'] as int)).toList();
        _okJson(request, {'recipes': likedRecipes, 'count': likedRecipes.length});
        continue;
      }

      // GET /api/recipe  (전체)
      if (method == 'GET' && path == '/api/recipe') {
        _okJson(request, {'recipes': recipes});
        continue;
      }

      // GET /api/recipe/:recipeId (상세)
      if (method == 'GET' &&
          segments.length == 3 &&
          segments[0] == 'api' &&
          segments[1] == 'recipe') {
        final id = int.tryParse(segments[2]);
        if (id == null) return _badRequest(request, 'invalid recipeId-2');

        final recipe = recipes.firstWhere(
              (r) => r['recipeId'] == id,
          orElse: () => {},
        );
        if (recipe.isEmpty) return _notFound(request, 'recipe not found');
        _okJson(request, recipe);
        continue;
      }

      // POST /api/recipe/:recipeId/like
      if (method == 'POST' &&
          segments.length == 4 &&
          segments[0] == 'api' &&
          segments[1] == 'recipe' &&
          segments[3] == 'like') {
        final id = int.tryParse(segments[2]);
        if (id == null) return _badRequest(request, 'invalid recipeId-3');

        final profile = userInfo.putIfAbsent(user, () => {
          'likedRecipeId': <int>[],
          'recordedRecipe': <Map<String, dynamic>>[],
        });

        final liked = (profile['likedRecipeId'] as List).cast<int>();
        if (!liked.contains(id)) liked.add(id);

        _okJson(request, {'message': 'liked', 'recipeId': id});
        continue;
      }

      // DELETE /api/recipe/:recipeId/like
      if (method == 'DELETE' &&
          segments.length == 4 &&
          segments[0] == 'api' &&
          segments[1] == 'recipe' &&
          segments[3] == 'like') {
        final id = int.tryParse(segments[2]);
        if (id == null) return _badRequest(request, 'invalid recipeId-4');

        final profile = userInfo.putIfAbsent(user, () => {
          'likedRecipeId': <int>[],
          'recordedRecipe': <Map<String, dynamic>>[],
        });

        final liked = (profile['likedRecipeId'] as List).cast<int>();
        liked.remove(id);

        _okJson(request, {'message': 'unliked', 'recipeId': id});
        continue;
      }

      // --------------- 기록(Record) ---------------

      // GET /api/record/recipe  (기록된 레시피)
      if (method == 'GET' && path == '/api/record/recipe') {
        final profile = userInfo.putIfAbsent(user, () => {
          'likedRecipeId': <int>[],
          'recordedRecipe': <Map<String, dynamic>>[],
        });

        final list = (profile['recordedRecipe'] as List).cast<Map<String, dynamic>>();
        _okJson(request, {'recipes': list, 'count': list.length});
        continue;
      }

      // DELETE /api/record/:recipeId  (기록된 레시피 삭제)
      if (method == 'DELETE' &&
          segments.length == 3 &&
          segments[0] == 'api' &&
          segments[1] == 'record') {

        print("REQ PATH: ${request.uri.pathSegments}");

        final id = int.tryParse(segments[2]);
        if (id == null) return _badRequest(request, 'invalid recipeId-5');

        final profile = userInfo.putIfAbsent(user, () => {
          'likedRecipeId': <int>[],
          'recordedRecipe': <Map<String, dynamic>>[],
        });

        // recordedRecipe는 List<Map<String, dynamic>>
        final list = (profile['recordedRecipe'] as List).cast<Map<String, dynamic>>();

        // recipeId가 같은 recordedRecipe만 삭제
        list.removeWhere((recipe) => recipe['recipeId'] == id);

        _okJson(request, {'message': 'record deleted', 'recipeId': id});
        continue;
      }

      // POST /api/record/recipe (수동 추가)
      if (method == 'POST' && path == '/api/record/recipe') {
        final body = await _readJson(request);
        // recipeId가 없으면 자동 채번 (1000번대부터)
        var rid = body['recipeId'];
        if (rid == null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          rid = (now % 1000000) + 1000;
          body['recipeId'] = rid;
        }

        final profile = userInfo.putIfAbsent(user, () => {
          'likedRecipeId': <int>[],
          'recordedRecipe': <Map<String, dynamic>>[],
        });

        final list = (profile['recordedRecipe'] as List).cast<Map<String, dynamic>>();
        list.add(Map<String, dynamic>.from(body));

        _okJson(request, {'message': 'recorded added', 'recipeId': body['recipeId']});
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
      if (method == 'GET' && path == '/api/debug/userinfo') {
        final pretty = const JsonEncoder.withIndent('  ').convert({
          'userInfo': userInfo
        });

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(pretty)
          ..close();

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
