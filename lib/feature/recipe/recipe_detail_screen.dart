import 'package:flutter/material.dart';
import 'package:fooder_fe/services/api_service.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/ui/bars/custom_top_bar.dart';
import 'package:fooder_fe/shared/ui/buttons/accept_button.dart';
import 'package:fooder_fe/shared/ui/buttons/cancel_button.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<Map<String, dynamic>> response;

  @override
  void initState() {
    super.initState();
    // API 호출 (Future 객체 저장)
    response = ApiService.getRecipe(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(),
      backgroundColor: AppColors.main,
      // FutureBuilder를 사용하여 비동기 데이터 처리
      body: FutureBuilder<Map<String, dynamic>>(
        future: response,
        builder: (context, snapshot) {
          // 1. 로딩 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. 에러가 발생했을 때
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "레시피를 불러오는 중 오류가 발생했습니다.\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          // 3. 데이터가 없을 때
          if (!snapshot.hasData) {
            return const Center(child: Text("레시피 정보가 없습니다."));
          }

          // 4. 데이터 로드 성공 (UI 렌더링)
          final recipe = snapshot.data!;

          final name = recipe["name"] ?? "이름 없음";
          final description = recipe["description"] ?? "";
          final timeToCook = recipe["timeToCook"] ?? 0;
          final imageUrl = recipe["imageUrl"] ?? "";
          final ingredients = (recipe["ingredient"] as List?)?.cast<String>() ?? [];
          final steps = (recipe["steps"] as List?)?.cast<String>() ?? [];

          return Column(
            children: [
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
                      _buildBottomButtons(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // -----------------------------
  // 상단 요리 이미지
  // -----------------------------
  Widget _buildHeaderImage(String imageUrl) {
    return Stack(
      children: [
        // 1. 이미지를 먼저 배치 (배경)
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: imageUrl.isNotEmpty
              ? Image.network(
            imageUrl,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.broken_image)),
              );
            },
          )
              : Container(
            height: 180,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.image)),
          ),
        ),

        // 2. 뒤로가기 버튼을 나중에 배치 (이미지 위로 올라옴)
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea( // SafeArea 추가 권장 (상단바 영역 침범 방지)
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      // 버튼이 잘 보이도록 반투명 배경 추가 (선택 사항)
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.grey_4,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

          if (ingredients.isEmpty)
            const Text("재료 정보가 없습니다.")
          else
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

          if (steps.isEmpty)
            const Text("조리 방법 정보가 없습니다.")
          else
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

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 홈으로 (CancelButton)
        CancelButton(
          text: "홈으로",
          onTap: () {
            Navigator.pushNamed(context, '/home');
          },
          width: 150,
        ),

        const SizedBox(width: 20),

        // 레시피 저장 (AcceptButton)
        AcceptButton(
          text: "레시피 저장",
          onTap: () {
            // TODO: 레시피 저장 API 호출 로직 구현
            // 그 이후에 record로 이동해서 저장한 레시피가 바로 뜨도록
            Navigator.pushNamed(context, '/record');
          },
          width: 150,
        ),
      ],
    );
  }
}