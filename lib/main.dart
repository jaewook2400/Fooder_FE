import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("API 테스트")),
        body: const ApiTestWidget(),
      ),
    );
  }
}

class ApiTestWidget extends StatefulWidget {
  const ApiTestWidget({super.key});

  @override
  State<ApiTestWidget> createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends State<ApiTestWidget> {
  String log = "";

  void writeLog(Object msg) {
    setState(() => log += "$msg\n");
  }

  void testFlow() async {
    writeLog("----시작----");

    // 1) 로그인
    final login = await ApiService.login("user1", "pass1");
    writeLog("로그인: $login");

    // 2) 현재 레시피 개수 (DB 기준)
    final recipeCountBefore = await ApiService.getRecipeCount();
    writeLog("현재 레시피 개수(시작 시점): $recipeCountBefore");

    // 3-1) 전체 레시피 DB에서 받아오기
    final recipes = await ApiService.getRecipes();
    writeLog("📌 전체 레시피 개수: ${recipes.length}");

    // 3-2) 첫 번째 레시피 확인 (있을 때만)
    if (recipes.isNotEmpty) {
      final r = recipes.first;
      writeLog("첫 번째 레시피: ${r["name"]}");
      writeLog("재료: ${r["ingredients"]}");
      writeLog("조리 단계: ${r["steps"]}");
    }

    // 4) 재료 목록 테스트
    final ingredients = await ApiService.getIngredients();
    writeLog("재료 목록(10개 최대): $ingredients");

    // 5) 선호도 → AI 레시피 생성 (예: 짝수 인덱스만 true)
    final prefs = List<bool>.generate(
      ingredients.length,
          (i) => i.isEven,
    );
    writeLog("보낼 preference: $prefs");

    final aiRecipe = await ApiService.sendPreference(prefs);
    writeLog("AI 생성 레시피 응답: $aiRecipe");

    final recipeId = aiRecipe["recipe"]["recipeId"];
    writeLog("생성된 레시피 ID: $recipeId");

    // 6) 생성 후 레시피 개수 확인
    final recipeCountAfterCreate = await ApiService.getRecipeCount();
    writeLog("레시피 개수(생성 후): $recipeCountAfterCreate");

    // 7) 삭제 테스트
    final deleted = await ApiService.deleteRecipe(recipeId);
    writeLog("레시피 삭제 결과: $deleted");

    // 8) 삭제 후 레시피 개수 확인
    final recipeCountAfterDelete = await ApiService.getRecipeCount();
    writeLog("레시피 개수(삭제 후): $recipeCountAfterDelete");

    writeLog("🎉 테스트 완료");
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: testFlow,
          child: const Text("서버 요청 테스트 실행"),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Text(log),
          ),
        )
      ],
    );
  }
}
