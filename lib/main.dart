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
    writeLog("---- unlike 테스트 시작 ----");

    // 1) 로그인
    final login = await ApiService.login("user1", "pass1");
    writeLog("로그인: $login");

    // 2) 전체 레시피
    final recipes = await ApiService.getRecipes();
    writeLog("레시피 개수: ${recipes.length}");

    if (recipes.isEmpty) {
      writeLog("레시피 없음 → 테스트 종료");
      return;
    }

    final targetId = recipes.first["recipeId"];
    writeLog("테스트용 레시피 ID: $targetId");

    // // 3) 좋아요
    // final likeRes = await ApiService.likeRecipe(targetId);
    // writeLog("좋아요: $likeRes");

    // 4) 좋아요 취소
    final unlikeRes = await ApiService.unlikeRecipe(targetId);
    writeLog("좋아요 취소: $unlikeRes");

    writeLog("🎉 unlike 테스트 완료");
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
