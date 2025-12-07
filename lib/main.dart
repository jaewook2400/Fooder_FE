import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fooder_fe/feature/account/login_screen.dart';
import 'feature/home/home_screen.dart';
import 'feature/profile/profile_screen.dart';
import 'feature/recipe/recipe_screen.dart';
import 'feature/record/record_screen.dart';

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
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/recipe': (context) => RecipeScreen(),
        '/record': (context) => RecordScreen(),
        '/profile': (context) => ProfileScreen(),
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