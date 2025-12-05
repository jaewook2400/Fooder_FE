import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/ui/bars/bottom_nav_bar.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("레시피"),
      ),
      body: Text('reipe'),
      bottomNavigationBar: BottomNavBar(currentRoute: BottomNavBar.recipeRoute),
    );
  }
}
