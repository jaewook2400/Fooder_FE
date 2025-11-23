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
    writeLog("📌 시작");

    final register = await ApiService.register("user1", "pass1");
    writeLog("회원가입: $register");

    final login = await ApiService.login("user1", "pass1");
    writeLog("로그인: $login");

    final recipes = await ApiService.getRecipes();
    writeLog("레시피 수: ${recipes.length}");

    final like = await ApiService.likeRecipe(1);
    writeLog("좋아요 결과: $like");

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
