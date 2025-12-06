import 'package:fooder_fe/feature/home/home_screen.dart';
import 'package:fooder_fe/services/secure_storage.dart';
import 'package:fooder_fe/shared/constants/constants.dart';
import 'package:fooder_fe/shared/ui/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/constants/app_assets.dart';
import 'package:fooder_fe/feature/account/sign_up_screen.dart';
import 'package:fooder_fe/shared/ui/buttons/primary_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscure = true;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일과 비밀번호를 모두 입력하세요.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

   try{
      // 1. 로그인 API 호출
      final loginUri = Uri.parse('$baseUrl/api/login').toString();

      final response = await http.post(
        Uri.parse(loginUri),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final loginResponse = jsonDecode(response.body);
        //final accessToken = loginResponse.data['token'].toString(); //data는 왜? 빼야할듯한데
        final accessToken = loginResponse['token'].toString();
        debugPrint('-----login response is: $loginResponse-----');

        // 2. 토큰 저장
        await SecureStorage().saveAccessToken(accessToken);

        print("-----my access token is: $accessToken-----");

        Navigator.pushNamed(context, '/home');
      } else {
        //throw Exception('Login failed: ${response.statusCode}');
        ///throw Exception 대신 email, pw일치하지 않다는 ui바를 호출
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이메일 또는 비밀번호가 일치하지 않습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 중 오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
      debugPrint('Login Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Image.asset(
                  AppAssets.logo,
                  scale: 5,
                ),
                const SizedBox(height: 30),

                // 이메일
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '이메일',
                    style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
                  ),
                ),
                const SizedBox(height: 8),

                LoginTextField(
                  controller: emailController,
                  hintText: 'university@example.ac.kr',
                ),
                const SizedBox(height: 28),

                // 비밀번호
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '비밀번호',
                    style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
                  ),
                ),
                const SizedBox(height: 8),

                LoginTextField(
                  controller: passwordController,
                  hintText: '비밀번호를 입력하세요',
                  obscureText: obscure,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => obscure = !obscure),
                    child: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.grey_4,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 로그인 버튼
                PrimaryButton(
                  text: '로그인',
                  onTap: () {
                    login();
                  },
                  height: 54,
                  width: double.infinity,
                ),
                const SizedBox(height: 36),

                // 구분선
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.grey_2)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '또는',
                        style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.grey_2)),
                  ],
                ),
                const SizedBox(height: 28),

                Text(
                  '아직 계정이 없으신가요?',
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
                ),
                const SizedBox(height: 20),

                // 회원가입 버튼
                SecondaryButton(
                  text: '회원가입',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignUpScreen(),
                      ),
                    );
                  },
                  width: double.infinity,
                  height: 54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey_1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: AppColors.main,
        style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: hintText,
          hintStyle: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_3),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}