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
    writeLog("---- testFlow 시작 ----");

    // 1) 로그인
    final login = await ApiService.login("user1", "pass1");
    writeLog("로그인 결과: $login");

    // 2) 전체 레시피 조회
    final all = await ApiService.getRecipes();
    writeLog("전체 레시피 개수: ${all.length}");

    if (all.isEmpty) {
      writeLog("레시피가 없습니다. 테스트 종료");
      return;
    }

    final firstId = all.first["recipeId"];
    writeLog("테스트 대상으로 레시피 ID = $firstId 사용");

    // 3) 상세 조회
    final detail = await ApiService.getRecipe(firstId);
    writeLog("상세 레시피: $detail");

    writeLog("🎉 상세 조회 테스트 완료");
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
