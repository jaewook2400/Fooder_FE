import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';

class AiRecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> response;

  const AiRecipeDetailScreen({
    required this.response,
    super.key,
  });

  @override
  State<AiRecipeDetailScreen> createState() => _AiRecipeDetailScreenState();
}

class _AiRecipeDetailScreenState extends State<AiRecipeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final recipe = widget.response["recipe"];
    final name = recipe["name"];
    final description = recipe["description"];
    final timeToCook = recipe["timeToCook"];
    final imageUrl = recipe["imageUrl"];
    final ingredients = (recipe["ingredient"] as List).cast<String>();
    final steps = (recipe["steps"] as List).cast<String>();

    return Scaffold(
      backgroundColor: AppColors.main,
      body: Column(
        children: [
          _buildTopBar(context),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderImage(imageUrl),
                  _buildTitleSection(name, description, timeToCook),
                  const SizedBox(height: 20),
                  _buildIngredientSection(ingredients),
                  const SizedBox(height: 20),
                  _buildStepSection(steps),
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
  // Top Bar (뒤로가기만)
  // -----------------------------
  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.grey_4,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // 상단 요리 이미지
  // -----------------------------
  Widget _buildHeaderImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      ),
    );
  }

  // -----------------------------
  // 요리 제목 + 설명 + 정보
  // -----------------------------
  Widget _buildTitleSection(String name, String description, int time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_4,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            description,
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 16,
              color: AppColors.grey_4,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Icon(Icons.access_time, size: 20, color: AppColors.grey_4),
              const SizedBox(width: 6),
              Text(
                "$time분",
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 14,
                  color: AppColors.grey_4,
                ),
              ),

              const SizedBox(width: 20),

              Icon(Icons.person, size: 20, color: AppColors.grey_4),
              const SizedBox(width: 6),
              Text(
                "2-3인분",
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 14,
                  color: AppColors.grey_4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // 재료 박스
  // -----------------------------
  Widget _buildIngredientSection(List<String> ingredients) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
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
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_4,
            ),
          ),
          const SizedBox(height: 16),

          Column(
            children: ingredients.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.main,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 15,
                          color: AppColors.grey_4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // 조리 방법
  // -----------------------------
  Widget _buildStepSection(List<String> steps) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
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
            "조리 방법",
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_4,
            ),
          ),
          const SizedBox(height: 16),

          Column(
            children: List.generate(steps.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.main,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: AppTextStyles.pretendard_regular.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        steps[index],
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 15,
                          color: AppColors.grey_4,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
