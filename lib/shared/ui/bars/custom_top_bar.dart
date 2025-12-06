import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/constants/app_assets.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
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
      centerTitle: false, // [수정] true -> false로 변경하여 왼쪽 정렬
      automaticallyImplyLeading: false,
      iconTheme: const IconThemeData(color: Colors.black),

      title: Image.asset(
        AppAssets.logo,
        height: 40,
        fit: BoxFit.contain,
      ),

      actions: showActions
          ? [
        IconButton(
          icon: const Icon(
            Icons.favorite_border,
            color: AppColors.grey_5,
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