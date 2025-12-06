import 'package:flutter/material.dart';
import 'package:fooder_fe/feature/home/ai_recipe_detail_screen.dart';
import 'package:fooder_fe/feature/home/preference_screen.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/services/api_service.dart';

class RecommendRecipeScreen extends StatefulWidget {
  final Map<String, dynamic> response;
  final List<String> selectedIngredient;

  const RecommendRecipeScreen({
    required this.response,
    required this.selectedIngredient,
    super.key,
  });

  @override
  State<RecommendRecipeScreen> createState() => _RecommendRecipeScreenState();
}

class _RecommendRecipeScreenState extends State<RecommendRecipeScreen> {

  void reject(int recipeId){
    //1. delete api 호출하는 함수 호출
    ApiService.deleteRecipe(recipeId);

    //2. 다시 선호도 조사 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PreferenceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.response["recipe"];
    final name = recipe["name"] ?? "";
    final timeToCook = recipe["timeToCook"] ?? 30;
    final description = recipe["description"] ?? "";
    final imageUrl = recipe["imageUrl"] ?? "";
    final ingredients = (recipe["ingredient"] as List).cast<String>();

    return Scaffold(
      backgroundColor: AppColors.main,
      body: Column(
        children: [
          const SizedBox(height: 50),

          // ---------------------------
          // TOPBAR (비워둠)
          // ---------------------------
          Container(
            height: 50,
            alignment: Alignment.center,
            child: const Text(""),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  _buildSelectedIngredientBox(widget.selectedIngredient),
                  const SizedBox(height: 30),

                  Text(
                    "선택한 재료로 생성된 요리는..!",
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 18,
                      color: AppColors.grey_4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildMainRecipeCard(
                    name: name,
                    description: description,
                    timeToCook: timeToCook,
                    imageUrl: imageUrl,
                  ),

                  const SizedBox(height: 20),

                  _buildIngredientList(ingredients),

                  const SizedBox(height: 40),

                  _buildButtons(context),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // 선택한 재료 TAG BOX
  // -----------------------------
  Widget _buildSelectedIngredientBox(List<String> list) {
    return Container(
      width: 330,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "선택한 재료",
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_4,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: list
                .map(
                  (e) => Container(
                padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.main.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  e,
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 14,
                    color: AppColors.grey_4,
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // 추천 레시피 카드
  // -----------------------------
  Widget _buildMainRecipeCard({
    required String name,
    required String description,
    required int timeToCook,
    required String imageUrl,
  }) {
    return Container(
      width: 330,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey_4,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  description,
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 14,
                    color: AppColors.grey_4,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.access_time,
                        color: AppColors.grey_4, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "${timeToCook.toString()}분",
                      style: AppTextStyles.pretendard_regular.copyWith(
                        color: AppColors.grey_4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // 재료 리스트
  // -----------------------------
  Widget _buildIngredientList(List<String> items) {
    return Container(
      width: 330,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "재료",
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_4,
            ),
          ),
          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.main,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e,
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 15,
                          color: AppColors.grey_4,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // 버튼 2개
  // -----------------------------
  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 다시 선택하기
        GestureDetector(
          onTap: () => reject(widget.response['recipe']['recipeId']),
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.white,
              border: Border.all(color: AppColors.main),
            ),
            child: Center(
              child: Text(
                "다시 선택하기",
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 16,
                  color: AppColors.orange,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 20),

        // 레시피 선택
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AiRecipeDetailScreen(response: widget.response),
              ),
            );
          },
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.orange,
            ),
            child: Center(
              child: Text(
                "레시피 선택",
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
