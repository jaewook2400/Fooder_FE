import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/ui/screens/liked_recipe_screen.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  // final String title; // 더 이상 문자열 타이틀은 필요하지 않으므로 주석 처리하거나 삭제
  final bool showActions;

  const CustomTopBar({
    super.key,
    // required this.title, // 생성자에서도 제거
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      iconTheme: const IconThemeData(color: Colors.black),

      // [수정] Text 대신 Image.asset 사용
      title: Image.asset(
        'assets/images/logo_orange.png', // 실제 로고 이미지 경로로 수정해주세요
        height: 30, // 로고 크기에 맞게 높이 조절 (보통 24~40 사이)
        fit: BoxFit.contain,
      ),

      actions: showActions
          ? [
        IconButton(
          icon: const Icon(
            Icons.favorite_border,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LikedRecipeScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}