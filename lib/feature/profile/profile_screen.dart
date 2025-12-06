import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/ui/bars/bottom_nav_bar.dart';
import 'package:fooder_fe/shared/ui/bars/custom_top_bar.dart';
import '../../shared/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CustomTopBar(),
        backgroundColor: AppColors.main,
        body: Column(
          children: [
            // 사용자 정보 영역
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: AppColors.grey_1,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.main,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사용자님',
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 16,
                          color: AppColors.grey_4,
                        ),
                      ),
                      Text(
                        'user@example.com',
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 14,
                          color: AppColors.grey_4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 프로필 수정 / 설정 / 로그아웃 카드
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.main.withOpacity(0.2),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _menuItem(
                      icon: Icons.person_outline,
                      label: '프로필 수정',
                    ),
                    _divider(),
                    _menuItem(
                      icon: Icons.settings_outlined,
                      label: '설정',
                    ),
                    _divider(),
                    _menuItem(
                      icon: Icons.logout,
                      label: '로그아웃',
                      color: Colors.red,
                      iconColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 통계 3개 박스 (레시피 / 찜 / 기록)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statBox(number: 12, label: '레시피'),
                  _statBox(number: 8, label: '찜'),
                  _statBox(number: 24, label: '기록'),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: AppColors.main.withOpacity(0.3),
              ),
            ),
          ],
        ),

        bottomNavigationBar: BottomNavBar(currentRoute: BottomNavBar.profileRoute),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    Color? color,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? AppColors.grey_4,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 16,
                  color: color ?? AppColors.grey_4,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: color ?? AppColors.grey_4,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: AppColors.grey_2, height: 1);
  }

  Widget _statBox({required int number, required String label}) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$number',
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 20,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 14,
              color: AppColors.grey_4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? AppColors.main : AppColors.grey_4,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.pretendard_regular.copyWith(
            fontSize: 12,
            color: isSelected ? AppColors.main : AppColors.grey_4,
          ),
        ),
      ],
    );
  }
}
