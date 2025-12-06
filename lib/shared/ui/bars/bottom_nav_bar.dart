import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/constants/app_assets.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';

class BottomNavBar extends StatelessWidget {
  final String currentRoute;

  const BottomNavBar({
    super.key,
    required this.currentRoute,
  });

  static const String homeRoute = "/home";
  static const String recipeRoute = "/recipe";
  static const String recordRoute = "/record";
  static const String profileRoute = "/profile";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.grey_4.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            label: '홈',
            iconPath: AppAssets.home_icon,
            isActive: currentRoute == homeRoute,
            onTap: () => _onTap(context, homeRoute),
          ),
          _BottomItem(
            label: '레시피',
            iconPath: AppAssets.recipe_icon,
            isActive: currentRoute == recipeRoute,
            onTap: () => _onTap(context, recipeRoute),
          ),
          _BottomItem(
            label: '기록',
            iconPath: AppAssets.record_icon,
            isActive: currentRoute == recordRoute,
            onTap: () => _onTap(context, recordRoute),
          ),
          _BottomItem(
            label: '프로필',
            iconPath: AppAssets.profile_icon,
            isActive: currentRoute == profileRoute,
            onTap: () => _onTap(context, profileRoute),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, String route) {
    if (route == currentRoute) return; // 이미 활성화된 화면이면 이동 X
    Navigator.pushNamed(context, route);
  }
}

class _BottomItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final String iconPath;
  final VoidCallback onTap;

  const _BottomItem({
    required this.label,
    required this.isActive,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 28,
            color: isActive ? AppColors.orange : AppColors.grey_4,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.pretendard_regular.copyWith(
              color: isActive ? AppColors.orange : AppColors.grey_4,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
