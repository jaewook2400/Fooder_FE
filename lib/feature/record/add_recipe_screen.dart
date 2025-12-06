import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fooder_fe/services/api_service.dart';
import 'package:fooder_fe/shared/constants/app_colors.dart';
import 'package:fooder_fe/shared/constants/app_text_styles.dart';
import 'package:fooder_fe/shared/ui/bars/custom_top_bar.dart';
import 'package:fooder_fe/shared/ui/buttons/accept_button.dart';
import 'package:image_picker/image_picker.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  // 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // 재료와 조리 순서는 여러 개일 수 있으므로 리스트로 관리
  final List<TextEditingController> _ingredientControllers = [TextEditingController()];
  final List<TextEditingController> _stepControllers = [TextEditingController()];

  File? _selectedImage; // 선택된 이미지를 저장할 변수
  String _uploadedImageUrl = "";
  final ImagePicker _picker = ImagePicker();
  final String _fixedImageUrl = "https://www.urbanbrush.net/web/wp-content/uploads/edd/2021/07/urbanbrush-20210720213004046257.jpg";

  bool _isLoading = false;
  bool _isImageUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (var c in _ingredientControllers) c.dispose();
    for (var c in _stepControllers) c.dispose();
    super.dispose();
  }

  // 재료 입력 필드 추가
  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  // 조리 순서 입력 필드 추가
  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path); // 화면 표시용 로컬 파일 설정
          _isImageUploading = true; // 업로드 시작 표시
        });

        // 선택하자마자 서버로 업로드
        await _uploadImageToServer();
      }
    } catch (e) {
      print("이미지 선택 오류: $e");
    }
  }

  // 3. 서버 업로드 함수 호출
  Future<void> _uploadImageToServer() async {
    if (_selectedImage == null) return;

    try {
      // ★ 여기서 File 객체를 인자로 넣습니다.
      String uploadedUrl = await ApiService.uploadImage(_selectedImage!);

      setState(() {
        _uploadedImageUrl = uploadedUrl; // ★ 서버에서 받은 URL 저장
        _isImageUploading = false; // 업로드 완료
      });

      print("서버에 저장된 이미지 URL: $uploadedUrl");
      // 이 URL을 나중에 레시피 저장 API 보낼 때 imageUrl 필드에 넣어서 보냄
    } catch (e) {
      print("업로드 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이미지 업로드 실패: $e")),
        );
      }
    }
  }

  // 레시피 저장 로직
  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    // 이미지 업로드 중이라면 기다리라고 알림
    if (_isImageUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이미지 업로드가 진행 중입니다. 잠시만 기다려주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. 데이터 가공
      final name = _nameController.text;
      final description = _descController.text;

      // 빈 칸은 제외하고 리스트 생성
      final ingredients = _ingredientControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final steps = _stepControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      // ★ 최종 이미지 URL 결정: 업로드된 게 있으면 그거 쓰고, 없으면 기본값
      final String finalImageUrl =
      _uploadedImageUrl.isNotEmpty ? _uploadedImageUrl : _fixedImageUrl;

      // 2. API 요청 데이터 구성
      final Map<String, dynamic> requestData = {
        "name": name,
        "description": description,
        "imageUrl": finalImageUrl,
        "ingredient": ingredients,
        "steps": steps,
        "timeToCook": 30, // 기본값 설정 (필요 시 입력 필드 추가 가능)
      };

      // 3. API 호출
      await ApiService.sendRecordRecipe(requestData);

      if (!mounted) return;

      // 4. 성공 시 뒤로가기 및 스낵바 표시
      Navigator.pop(context, true); // true를 반환하여 목록 갱신 신호 전달 가능
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("레시피가 성공적으로 저장되었습니다!")),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CustomTopBar(showActions: false), // 뒤로가기만 있는 상단바
        backgroundColor: AppColors.main,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("레시피 기본 정보"),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _nameController,
                  label: "레시피 이름",
                  hint: "예: 김치볶음밥",
                  validator: (v) => v == null || v.isEmpty ? "이름을 입력해주세요" : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _descController,
                  label: "간단한 설명",
                  hint: "예: 누구나 좋아하는 매콤한 볶음밥",
                  maxLines: 2,
                ),

                const SizedBox(height: 30),
                _buildSectionTitle("대표 이미지"),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: _pickImage, // 클릭 시 갤러리 오픈
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _selectedImage != null
                            ? Image.file(
                          _selectedImage!, // 로컬 파일 표시
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Image.network(
                          _fixedImageUrl, // 기본 이미지 표시
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // 이미지 업로드 중일 때 로딩 표시
                      if (_isImageUploading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      // 카메라 아이콘 오버레이 (선택 유도)
                      if (!_isImageUploading)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                _buildDynamicListSection(
                  title: "재료",
                  controllers: _ingredientControllers,
                  onAdd: _addIngredientField,
                  hintText: "예: 김치 1/4포기",
                ),

                const SizedBox(height: 30),
                _buildDynamicListSection(
                  title: "조리 순서",
                  controllers: _stepControllers,
                  onAdd: _addStepField,
                  hintText: "예: 팬에 기름을 두르고 달궈주세요.",
                  isStep: true,
                ),

                const SizedBox(height: 40),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : AcceptButton(
                    text: "레시피 저장하기",
                    onTap: _submitRecipe,
                    width: double.infinity, // 버튼 꽉 차게
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 섹션 타이틀 위젯
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.pretendard_regular.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.grey_4,
      ),
    );
  }

  // 기본 텍스트 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 라벨을 텍스트 필드 바깥으로 이동
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_4,
            ),
          ),
        ),
        // 2. 텍스트 필드 컨테이너
        Container(
          // 높이를 고정하지 않고 내용물에 맞게 늘어나도록 설정하거나,
          // 필요하다면 최소 높이만 지정하는 것이 좋습니다.
          // 여기서는 maxLines가 1일 때만 높이를 고정하고, 그 외엔 유동적으로 둡니다.
          height: maxLines == 1 ? 50 : null,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(fontSize: 15), // 입력 글자 크기 조정
            decoration: InputDecoration(
              // labelText 제거 (바깥으로 뺐으므로)
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              // contentPadding을 조절하여 텍스트 수직 정렬 맞춤
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true, // 텍스트 필드 내부 여백을 타이트하게 잡음
            ),
          ),
        ),
      ],
    );
  }

  // 동적 리스트 (재료, 조리순서) 위젯
  Widget _buildDynamicListSection({
    required String title,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required String hintText,
    bool isStep = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(title),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text("추가"),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.orange,
              ),
            ),
          ],
        ),
        ...List.generate(controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controllers[index],
                    label: isStep ? "Step ${index + 1}" : "재료 ${index + 1}",
                    hint: hintText,
                    maxLines: isStep ? 2 : 1,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}