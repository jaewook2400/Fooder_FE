import 'package:flutter/material.dart';
import 'package:fooder_fe/services/api_service.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  List<Map<String, dynamic>> ingredientList = [];
  bool isLoading = true;
  bool isError = false;

  int currentIndex = 0;

  List<String> liked = [];
  List<String> disliked = [];

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  Future<void> _fetchIngredients() async {
    try {
      final response = await ApiService.getIngredients();
      if (response.isEmpty) throw Exception("No data");

      setState(() {
        ingredientList = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  void handleChoice(bool like) async {
    final current = ingredientList[currentIndex];

    if (like) {
      liked.add(current["ingredient"]);
    } else {
      disliked.add(current["ingredient"]);
    }

    // 다음 카드로 이동
    if (currentIndex < ingredientList.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      // 모든 카드 평가 완료
      debugPrint("평가 완료");
      debugPrint("좋아요: $liked");
      debugPrint("싫어요: $disliked");

      final response = await ApiService.sendPreference(liked);
      debugPrint(response.toString());
      // TODO: 다음 페이지 이동 or 서버 전송

    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isError) {
      return Scaffold(
        body: Center(
          child: Text(
            "데이터를 불러오지 못했습니다.",
            style: AppTextStyles.pretendard_regular.copyWith(
              color: AppColors.grey_4,
            ),
          ),
        ),
      );
    }

    final item = ingredientList[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const SizedBox(height: 60),

          Text(
            "재료 선택 중...",
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 18,
              color: AppColors.grey_4,
            ),
          ),

          Text(
            "${currentIndex + 1} / ${ingredientList.length}",
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 14,
              color: AppColors.grey_4,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: _buildIngredientCard(item),
          ),

          const SizedBox(height: 24),

          _buildButtons(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                item["imageUrl"] ?? "",
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item["ingredient"] ?? "",
              style: AppTextStyles.pretendard_regular.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.grey_4,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // X (싫어요)
        GestureDetector(
          onTap: () => handleChoice(false),
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "X",
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey_4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 60),

        // O (좋아요)
        GestureDetector(
          onTap: () => handleChoice(true),
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.main,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "O",
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
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
