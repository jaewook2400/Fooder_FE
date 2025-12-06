import 'package:flutter/material.dart';
import 'package:fooder_fe/feature/recipe/recipe_detail_screen.dart';
import 'package:fooder_fe/services/api_service.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/ui/bars/bottom_nav_bar.dart';
import 'package:fooder_fe/shared/ui/bars/custom_top_bar.dart';

class RecipeScreen extends StatefulWidget {
  RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late Future<List<dynamic>> recipeFuture;

  List<dynamic> originalList = [];
  List<dynamic> filteredList = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    recipeFuture = loadRecipes();
  }

  Future<List<dynamic>> loadRecipes() async {
    final data = await ApiService.getRecipes(); // { recipes: [...] }
    final list = data.map((e) {
      return {
        ...e,
        "isLiked": false, // ★ 프론트단에서 좋아요 상태 추가
      };
    }).toList();

    originalList = list;
    filteredList = list;

    return list;
  }

  // 좋아요 토글 기능 (API 연동: 좋아요 / 좋아요 취소 분기 처리)
  Future<void> toggleLike(int index) async {
    final item = filteredList[index];
    final int recipeId = item["recipeId"];
    final bool wasLiked = item["isLiked"]; // 변경 전 상태

    // 1. UI 선반영 (Optimistic Update)
    setState(() {
      item["isLiked"] = !wasLiked;
    });

    try {
      // 2. 상태에 따라 API 분기 호출
      if (wasLiked) {
        // 이미 좋아요 상태였으므로 -> 취소 요청 (DELETE)
        await ApiService.unlikeRecipe(recipeId);
      } else {
        // 좋아요가 아니었으므로 -> 좋아요 요청 (POST)
        await ApiService.likeRecipe(recipeId);
      }
    } catch (e) {
      // 3. 실패 시 롤백
      setState(() {
        item["isLiked"] = wasLiked;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("변경 실패: $e")),
      );
    }
  }

  // 검색 기능
  void searchRecipe(String keyword) {
    setState(() {
      if (keyword.trim().isEmpty) {
        filteredList = List.from(originalList);
      } else {
        filteredList = originalList
            .where((item) =>
            item["name"].toString().contains(keyword.trim()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // [수정] GestureDetector로 감싸서 빈 화면 터치 시 키보드 내리기
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent, // 빈 공간 터치 감지 보장
      child: Scaffold(
        appBar: const CustomTopBar(),
        backgroundColor: AppColors.main,
        bottomNavigationBar:
        BottomNavBar(currentRoute: BottomNavBar.recipeRoute),

        body: FutureBuilder(
          future: recipeFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                const SizedBox(height: 12),

                _buildSearchBar(),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    // [참고] 리스트뷰 스크롤 시에도 키보드가 내려가게 하려면 아래 속성 추가
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildRecipeCard(filteredList[index], index);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // -------------------------
  // 검색창 UI
  // -------------------------
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.grey_4, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: searchRecipe,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "레시피 검색...",
                hintStyle: AppTextStyles.pretendard_regular.copyWith(
                  color: AppColors.grey_4,
                  fontSize: 14,
                ),
              ),
              style: AppTextStyles.pretendard_regular.copyWith(
                color: AppColors.grey_4,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
// 레시피 카드 UI
// -------------------------
  Widget _buildRecipeCard(dynamic item, int index) {
    final imageUrl = item["imageUrl"] ?? "";
    final name = item["name"] ?? "";
    final desc = item["description"] ?? "";
    final time = item["timeToCook"] ?? 0;
    // API 응답에 따라 id 키값이 'id'인지 'recipeId'인지 확인 필요 (여기선 recipeId로 가정)
    final recipeId = item["recipeId"] ?? 0;

    // [수정] 카드 전체를 클릭할 수 있도록 GestureDetector로 감쌈
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
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              child: Image.network(
                imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.pretendard_regular.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orange,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.pretendard_regular.copyWith(
                        fontSize: 14,
                        color: AppColors.grey_4,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: AppColors.grey_4),
                        const SizedBox(width: 4),
                        Text(
                          "$time분",
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_4,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 좋아요 버튼 (카드 클릭과 별개로 동작함)
            GestureDetector(
              onTap: () => toggleLike(index),
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  item["isLiked"] ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.orange,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
