import 'package:flutter/material.dart';

class AiRecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> response;

  const AiRecipeDetailScreen({
    required this.response,
    super.key
  });

  @override
  State<AiRecipeDetailScreen> createState() => _AiRecipeDetailScreenState();
}

class _AiRecipeDetailScreenState extends State<AiRecipeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
