import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double width;
  final double height;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.main,
          side: BorderSide(color: AppColors.main, width: 1.4),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.main),
        ),
      ),
    );
  }
}