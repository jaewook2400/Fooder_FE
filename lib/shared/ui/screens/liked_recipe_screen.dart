import 'package:flutter/material.dart';
import 'package:fooder_fe/feature/recipe/recipe_detail_screen.dart';
import 'package:fooder_fe/services/api_service.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/ui/bars/custom_top_bar.dart';

class LikedRecipeScreen extends StatefulWidget {
  const LikedRecipeScreen({super.key});

  @override
  State<LikedRecipeScreen> createState() => _LikedRecipeScreenState();
}

class _LikedRecipeScreenState extends State<LikedRecipeScreen> {
  List<dynamic> likedRecipes = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _loadLikedRecipes();
  }

  Future<void> _loadLikedRecipes() async {
    try {
      final response = await ApiService.getLikedRecipes();
      // response 구조: {"recipes": [...], "count": ...}
      setState(() {
        likedRecipes = response['recipes'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading liked recipes: $e");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(), // 상단바 타이틀 설정
      backgroundColor: AppColors.main,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(child: Text("레시피를 불러오는 중 오류가 발생했습니다."))
          : likedRecipes.isEmpty
          ? _buildEmptyView()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 20),
        itemCount: likedRecipes.length,
        itemBuilder: (context, index) {
          final item = likedRecipes[index];
          return _buildRecipeCard(item);
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 60, color: AppColors.grey_4),
          const SizedBox(height: 16),
          Text(
            "아직 찜한 레시피가 없습니다.",
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 16,
              color: AppColors.grey_4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(dynamic item) {
    final int recipeId = item['recipeId'];
    final String name = item['name'] ?? "이름 없음";
    final String description = item['description'] ?? "";
    final String imageUrl = item['imageUrl'] ?? "";
    final int timeToCook = item['timeToCook'] ?? 0; // 서버에서 추가해준 필드

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipeId: recipeId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // 텍스트 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 14,
                      color: AppColors.grey_4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: AppColors.grey_4),
                      const SizedBox(width: 4),
                      Text(
                        "$timeToCook분",
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 13,
                          color: AppColors.grey_4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 찜 아이콘 (이미 찜한 목록이므로 꽉 찬 하트)
            Icon(
              Icons.favorite,
              color: AppColors.orange, // 혹은 빨간색
            ),
          ],
        ),
      ),
    );
  }
}