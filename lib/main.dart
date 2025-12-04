import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fooder_fe/feature/account/login_screen.dart';
import 'feature/home/home_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        //'/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        //'/recipe': (context) => RecipeScreen(),
        //'/record': (context) => RecordScreen(),
        //'/profile': (context) => ProfileScreen(),
      },
    );

    // 웹에서는 화면 크기를 제한해서 가운데 정렬
    if (kIsWeb) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 375, // iPhone width
                maxHeight: 812, // iPhone height
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: app, // 기존 MaterialApp을 안에 렌더링
              ),
            ),
          ),
        ),
      );
    }

    // 모바일/데스크탑은 원래대로 전체 화면
    return app;
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text("API 테스트")),
//         body: const ApiTestWidget(),
//       ),
//     );
//   }
// }
//
// class ApiTestWidget extends StatefulWidget {
//   const ApiTestWidget({super.key});
//
//   @override
//   State<ApiTestWidget> createState() => _ApiTestWidgetState();
// }
//
// class _ApiTestWidgetState extends State<ApiTestWidget> {
//   String log = "";
//
//   void writeLog(Object msg) {
//     setState(() => log += "$msg\n");
//   }
//
//   void testFlow() async {
//     writeLog("----시작----");
//
//     // 1) 로그인
//     final login = await ApiService.login("user1", "pass1");
//     writeLog("로그인: $login");
//
//     // 2) 기록된 레시피 목록 불러오기
//     final recordedBefore = await ApiService.getRecordedRecipes();
//     writeLog("삭제 전 기록된 레시피: $recordedBefore");
//
//     if (recordedBefore.isEmpty) {
//       writeLog("❗ 기록된 레시피가 없어서 삭제 테스트를 건너뜀");
//       return;
//     }
//
//     // 3) 첫 번째 기록 레시피 삭제
//     final recipeId = recordedBefore[0]["recipeId"];
//     writeLog("삭제할 레시피 ID: $recipeId");
//
//     final deleted = await ApiService.deleteRecordedRecipe(recipeId);
//     writeLog("삭제 결과: $deleted");
//
//     // 4) 삭제 후 다시 목록 조회
//     final recordedAfter = await ApiService.getRecordedRecipes();
//     writeLog("삭제 후 기록된 레시피: $recordedAfter");
//
//     writeLog("🎉 테스트 완료");
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: testFlow,
//           child: const Text("서버 요청 테스트 실행"),
//         ),
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(12),
//             child: Text(log),
//           ),
//         )
//       ],
//     );
//   }
// }
