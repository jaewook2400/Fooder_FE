import 'package:flutter/material.dart';

class RecommendRecipeScreen extends StatefulWidget {
  final dynamic response; //ai 추천 레시피 내용
  const RecommendRecipeScreen({
    required this.response,
    super.key
  });

  @override
  State<RecommendRecipeScreen> createState() => _RecommendRecipeScreenState();
}

class _RecommendRecipeScreenState extends State<RecommendRecipeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
