import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fooder_fe/feature/home/preference_screen.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/ui/bars/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.main,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 44),

              // ---------------------------
              // Top Bar (비워둠)
              // ---------------------------
              Container(
                height: 56,
                alignment: Alignment.center,
                child: const Text(""),
              ),

              _buildIntroSection(),
              const SizedBox(height: 24),
              _buildTodayRecommendButton(context),
              const SizedBox(height: 40),
              _buildPopularTitle(),
              const SizedBox(height: 12),
              _buildPopularRecipeCard(),
              const SizedBox(height: 120),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentRoute: BottomNavBar.homeRoute),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Container(
      width: 327,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "레시피 추천 앱, Fooder",
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            "Fooder는 원하는 재료를 선택하여 AI가 제공한 레시피로 요리해볼 수 있고,\n"
                "다양한 레시피를 검색하여 보관할 수 있으며 그날 먹은 음식을 기록하고 "
                "식습관을 관찰할 수 있는 종합 웰빙 앱입니다.",
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 14,
              height: 1.5,
              color: AppColors.grey_4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayRecommendButton(context) {
    return TextButton(
      onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PreferenceScreen()),
        );
      },
      child: Container(
        width: 327,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "오늘의 메뉴 추천받기",
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey_4,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  ">",
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 22,
                    color: AppColors.grey_4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "원하는 재료를 선택하고 AI가 추천한 레시피로 요리해 보세요!",
              style: AppTextStyles.pretendard_regular.copyWith(
                fontSize: 14,
                color: AppColors.grey_4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularTitle() {
    return Container(
      width: 327,
      alignment: Alignment.centerLeft,
      child: Text(
        "금주 인기 레시피",
        style: AppTextStyles.pretendard_regular.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.grey_4,
        ),
      ),
    );
  }

  Widget _buildPopularRecipeCard() {
    return Container(
      width: 327,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              "https://shop.hansalim.or.kr/shopping/is/itm/100101024/100101024_3_568.jpg",
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "김치찌개",
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey_4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: AppColors.grey_4),
                    const SizedBox(width: 6),
                    Text(
                      "30분",
                      style: AppTextStyles.pretendard_regular.copyWith(
                        fontSize: 14,
                        color: AppColors.grey_4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "재료: 김치, 두부, 파...",
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 13,
                    color: AppColors.grey_4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
