import 'package:flutter/material.dart';
import 'package:fooder_fe/services/api_service.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  Map<String, dynamic>? ingredientData;   // API 원본 Map
  List<dynamic> ingredientList = [];      // 실제 화면에서 사용할 List
  bool isLoading = true;                  // 로딩 여부
  bool isError = false;                   // 에러 체크

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  Future<void> _fetchIngredients() async {
    try {
      final response = await ApiService.getIngredients();
      // response는 Map<String, dynamic>

      // 데이터 검증 (비판적 보완)
      if (response.isEmpty || response["ingredients"] == null) {
        throw Exception("Ingredients 데이터가 비어 있음");
      }

      setState(() {
        ingredientData = response;
        ingredientList = response["ingredients"];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      debugPrint("재료 API 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (isError) {
      return Center(
        child: Text(
          "데이터를 불러오지 못했습니다.",
          style: AppTextStyles.pretendard_regular.copyWith(
            color: AppColors.grey_4,
          ),
        ),
      );
    }

    // 안전장치
    if (ingredientList.isEmpty) {
      return Center(
        child: Text(
          "표시할 재료가 없습니다.",
          style: AppTextStyles.pretendard_regular.copyWith(
            color: AppColors.grey_4,
          ),
        ),
      );
    }

    // ↓↓↓ 여기서부터 네가 보여준 UI 구성 시작 (카드 스와이프 등)
    return Column(
      children: [
        const SizedBox(height: 40),

        // 예: 상단 상태 표시 영역
        Text(
          "재료 선택 중...",
          style: AppTextStyles.pretendard_regular.copyWith(
            fontSize: 16,
            color: AppColors.grey_4,
          ),
        ),

        // 예: 진행률
        Text(
          "1 / ${ingredientList.length}",
          style: AppTextStyles.pretendard_regular.copyWith(
            color: AppColors.grey_4,
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: PageView.builder(
            itemCount: ingredientList.length,
            itemBuilder: (context, index) {
              final item = ingredientList[index];

              return _buildIngredientCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientCard(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(
                item["imageUrl"],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            item["name"],
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_4,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "좌우로 스와이프하세요",
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 14,
              color: AppColors.grey_4,
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
