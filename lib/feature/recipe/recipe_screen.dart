import 'package:flutter/material.dart';
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

  void toggleLike(int index) {
    setState(() {
      filteredList[index]["isLiked"] = !filteredList[index]["isLiked"];
    });
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
    return Scaffold(
      appBar: CustomTopBar(),
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

    return Container(
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey_4,
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

                      const SizedBox(width: 12),

                      Icon(Icons.person, size: 16, color: AppColors.grey_4),
                      const SizedBox(width: 4),
                      Text(
                        "2-3인분",
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

          GestureDetector(
            onTap: () => toggleLike(index),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                item["isLiked"] ? Icons.favorite : Icons.favorite_border,
                color: AppColors.main,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
