import 'package:flutter/material.dart';
import 'package:fooder_fe/feature/record/add_recipe_screen.dart';
import 'package:fooder_fe/services/api_service.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/ui/bars/bottom_nav_bar.dart';
import 'package:fooder_fe/shared/ui/bars/custom_top_bar.dart';
import 'package:table_calendar/table_calendar.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay = DateTime.now();

  Map<DateTime, List<Map<String, dynamic>>> recordMap = {};
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final response = await ApiService.getRecordedRecipes();

      // 날짜별 그룹화
      for (final item in response) {
        final DateTime parsed = DateTime.parse(item["recordedAt"]);
        final dateKey = DateTime(parsed.year, parsed.month, parsed.day);

        recordMap.putIfAbsent(dateKey, () => []);
        recordMap[dateKey]!.add(item);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(),
      backgroundColor: AppColors.main,
      bottomNavigationBar: BottomNavBar(currentRoute: BottomNavBar.recordRoute),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipeScreen()),
          );
        },
        backgroundColor: AppColors.main,
        child: Icon(Icons.add, color: AppColors.white, size: 32),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? Center(
        child: Text(
          "기록을 불러오지 못했습니다.",
          style: AppTextStyles.pretendard_regular.copyWith(
            color: AppColors.grey_4,
          ),
        ),
      )
          : Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: _buildCalendar()
          ),
          const SizedBox(height: 20),
          _buildSelectedDateLabel(),
          Expanded(child: _buildRecordList()),
        ],
      ),
    );
  }

  // ---------------------- 달력 -----------------------
  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // 원하는 배경색 (예: 흰색)
        borderRadius: BorderRadius.circular(20), // 모서리를 둥글게 (선택 사항)
        boxShadow: [ // 그림자 효과 (선택 사항)
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TableCalendar(
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        focusedDay: focusedDay,

        selectedDayPredicate: (day) =>
        selectedDay != null &&
            day.year == selectedDay!.year &&
            day.month == selectedDay!.month &&
            day.day == selectedDay!.day,

        onDaySelected: (selected, focused) {
          setState(() {
            selectedDay = selected;
            focusedDay = focused;
          });
        },

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.pretendard_regular.copyWith(
            fontSize: 18,
            color: AppColors.grey_4,
          ),
          leftChevronIcon:
          Icon(Icons.chevron_left, color: AppColors.grey_4),
          rightChevronIcon:
          Icon(Icons.chevron_right, color: AppColors.grey_4),
        ),

        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.grey_4.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          defaultTextStyle:
          AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
          weekendTextStyle:
          AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
        ),
      ),
    );
  }

  // ---------------------- 날짜 타이틀 -----------------------
  Widget _buildSelectedDateLabel() {
    if (selectedDay == null) return const SizedBox.shrink();

    final y = selectedDay!.year;
    final m = selectedDay!.month.toString().padLeft(2, '0');
    final d = selectedDay!.day.toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(
        "$y년 $m월 $d일",
        style: AppTextStyles.pretendard_regular.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.grey_4,
        ),
      ),
    );
  }

  // ---------------------- 기록 리스트 -----------------------
  Widget _buildRecordList() {
    if (selectedDay == null) {
      return Center(
        child: Text(
          "날짜를 선택해주세요.",
          style: AppTextStyles.pretendard_regular.copyWith(
            color: AppColors.grey_4,
            fontSize: 16,
          ),
        ),
      );
    }

    final key = DateTime(
      selectedDay!.year,
      selectedDay!.month,
      selectedDay!.day,
    );

    final items = recordMap[key] ?? [];

    if (items.isEmpty) {
      return Center(
        child: Text(
          "기록이 없습니다.",
          style: AppTextStyles.pretendard_regular.copyWith(
            color: AppColors.grey_4,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
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
              // 제목 + 삭제 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item["name"],
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey_4,
                    ),
                  ),
                  Text(
                    "삭제",
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 14,
                      color: AppColors.grey_4.withOpacity(0.5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                item["description"] ?? "",
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 14,
                  color: AppColors.grey_4,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 18, color: AppColors.grey_4),
                  const SizedBox(width: 6),
                  Text(
                    "${item["timeToCook"]}분",
                    style: AppTextStyles.pretendard_regular.copyWith(
                      color: AppColors.grey_4,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Icon(Icons.person,
                      size: 18, color: AppColors.grey_4),
                  const SizedBox(width: 6),
                  Text(
                    "1-2인분", // 서버에 인분 정보 없으므로 placeholder
                    style: AppTextStyles.pretendard_regular.copyWith(
                      color: AppColors.grey_4,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
