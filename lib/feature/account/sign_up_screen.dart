import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/constants/app_assets.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/ui/buttons/primary_button.dart';
import 'package:fooder_fe/shared/constants/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 컨트롤러
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(_emailController, '이메일'),
                      const SizedBox(height: 12),

                      _buildTextField(_pwController, '비밀번호', obscureText: true),
                      const SizedBox(height: 12),

                      PrimaryButton(
                        text: '회원가입',
                        onTap: _register,
                        height: 54,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 공통 입력 필드
  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool obscureText = false,
        TextInputType keyboardType = TextInputType.text,
        String? hint,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 라벨
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        // 입력 필드
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.black12, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.black45, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  void _register() async {
    // 필수 입력값 확인
    if (_emailController.text.trim().isEmpty ||
        _pwController.text.trim().isEmpty) {
      _showErrorDialog("모든 항목을 입력해야 회원가입이 가능합니다.");
      return;
    }

    // 유효성 검사를 통과한 경우만 데이터 전송
    final data = {
      "email": _emailController.text.trim(),
      "password": _pwController.text.trim(),
    };

    print('회원가입 데이터: $data');

    ///서버에 회원가입 요청
    try{
      // 1. 회원가입 API 호출
      final registerUri = Uri.parse('$baseUrl/api/register').toString();
      final email = _emailController.text.trim();
      final password = _pwController.text.trim();

      final response = await http.post(
        Uri.parse(registerUri),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final registerResponse = jsonDecode(response.body);
        debugPrint('-----register response is: $registerResponse-----');

        Navigator.pushNamed(context, '/login');
      } else {
        ///throw Exception 대신 회원가입에 실패하였다는 ui바를 호출
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입에 실패하였습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 중 클라이언트에서 오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
      debugPrint('Register Error: $e');
    }
  }

// 에러 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "입력 누락",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }
}

class SelectableToggleGroup extends StatelessWidget {
  final String title; // 상단 라벨 (예: "성별")
  final List<String> options; // 선택 가능한 항목들
  final String selectedOption; // 현재 선택된 항목
  final ValueChanged<String> onSelect; // 선택 시 콜백

  const SelectableToggleGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.black12, width: 1.3),
          ),
          child: Row(
            children: List.generate(options.length, (index) {
              final label = options[index];
              final isSelected = label == selectedOption;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(label),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: index != options.length - 1
                            ? BorderSide(color: Colors.grey.shade400, width: 1)
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.main
                            : Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}