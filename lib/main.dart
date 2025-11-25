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
    writeLog("---- 기록 레시피 테스트 시작 ----");

    // 1) 로그인
    final login = await ApiService.login("user1", "pass1");
    writeLog("로그인: $login");

    // 2) 기록된 레시피 목록 조회
    final records = await ApiService.getRecordedRecipes();
    writeLog("기록된 레시피 개수: ${records.length}");
    writeLog("기록된 레시피 목록: $records");

    if (records.isEmpty) {
      writeLog("기록된 레시피가 없어서 삭제 테스트 불가");
      writeLog("🎉 테스트 종료");
      return;
    }

    writeLog("🎉 기록 레시피 테스트 완료");
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
