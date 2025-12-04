import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double height;
  final double width;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height, //기본 54
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.main,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}