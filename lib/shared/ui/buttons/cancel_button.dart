import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';

class CancelButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;

  const CancelButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 150,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white,
          border: Border.all(color: AppColors.main),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 16,
              color: AppColors.orange,
            ),
          ),
        ),
      ),
    );
  }
}