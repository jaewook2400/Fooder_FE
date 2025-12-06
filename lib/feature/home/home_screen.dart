import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fooder_fe/feature/home/preference_screen.dart';
import 'package:fooder_fe/feature/recipe/recipe_detail_screen.dart'; // 상세 페이지 이동을 위해 필요
import 'package:fooder_fe/services/api_service.dart'; // API 서비스 임포트
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/ui/bars/bottom_nav_bar.dart';
import 'package:fooder_fe/shared/ui/bars/custom_top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 최근 레시피 데이터를 담을 Future 변수
  late Future<Map<String, dynamic>> recentRecipeFuture;

  @override
  void initState() {
    super.initState();
    // API 호출하여 Future 초기화
    recentRecipeFuture = ApiService.getRecentRecipe();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CustomTopBar(), // const 추가
        backgroundColor: AppColors.main,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              _buildIntroSection(),
              const SizedBox(height: 24),
              _buildTodayRecommendButton(context),
              const SizedBox(height: 40),

              _buildRecentTitle(),

              const SizedBox(height: 12),

              _buildRecentRecipeCard(),

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
              color: AppColors.orange,
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
                    color: AppColors.orange,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  ">",
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 22,
                    color: AppColors.orange,
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

  // [수정] 타이틀 텍스트 변경
  Widget _buildRecentTitle() {
    return Container(
      width: 327,
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        "최근에 추가된 레시피", // 텍스트 변경
        style: AppTextStyles.pretendard_regular.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.grey_5,
        ),
      ),
    );
  }

  Widget _buildRecentRecipeCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: recentRecipeFuture,
      builder: (context, snapshot) {
        // 1. 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 142, // 카드 높이만큼 공간 확보
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. 에러 발생
        if (snapshot.hasError) {
          return Container(
            width: 327,
            height: 142,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text("레시피를 불러올 수 없습니다."),
          );
        }

        // 3. 데이터 없음 (빈 객체 등)
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: 327,
            height: 142,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text("최근 추가된 레시피가 없습니다."),
          );
        }

        // 4. 데이터 있음
        final data = snapshot.data!;
        final recipeId = data['recipeId'];
        final name = data['name'] ?? "이름 없음";
        final timeToCook = data['timeToCook'] ?? 0;
        final imageUrl = data['imageUrl'] ?? "";
        final ingredients = (data['ingredient'] as List?)?.cast<String>() ?? [];

        // 재료 리스트를 문자열로 변환 (예: "김치, 두부, 파...")
        final ingredientString = ingredients.join(", ");

        return GestureDetector(
          onTap: () {
            // 카드 클릭 시 상세 페이지로 이동
            if (recipeId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipeId: recipeId),
                ),
              );
            }
          },
          child: Container(
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
                    imageUrl,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 110,
                        height: 110,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orange,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: AppColors.grey_4),
                          const SizedBox(width: 6),
                          Text(
                            "$timeToCook분",
                            style: AppTextStyles.pretendard_regular.copyWith(
                              fontSize: 14,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "재료: $ingredientString",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 13,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}