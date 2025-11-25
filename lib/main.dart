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
    writeLog("---- 좋아요 목록 테스트 시작 ----");

    // 1) 로그인
    final login = await ApiService.login("user1", "pass1");
    writeLog("로그인: $login");

    // 2) 전체 레시피
    final allRecipes = await ApiService.getRecipes();
    writeLog("전체 레시피 수: ${allRecipes.length}");

    if (allRecipes.isEmpty) {
      writeLog("레시피 없음 → 테스트 종료");
      return;
    }

    final firstId = allRecipes.first["recipeId"];
    writeLog("테스트용 레시피 ID: $firstId");

    // 3) 좋아요 추가
    final liked = await ApiService.likeRecipe(firstId);
    writeLog("좋아요 결과: $liked");

    // 4) 좋아요 목록 조회
    final likedList = await ApiService.getLikedRecipes();
    writeLog("좋아요한 레시피 목록: $likedList");

    // 5) 좋아요 취소
    final unliked = await ApiService.unlikeRecipe(firstId);
    writeLog("좋아요 취소: $unliked");

    // 6) 좋아요 목록 재조회
    final likedListAfter = await ApiService.getLikedRecipes();
    writeLog("좋아요 목록(취소 후): $likedListAfter");

    writeLog("🎉 좋아요 목록 테스트 완료");
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
