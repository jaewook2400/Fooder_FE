import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/ui/bars/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("홈"),
      ),
      body: const Center(
        child: Text("홈 화면"),
      ),
      bottomNavigationBar: BottomNavBar(
          currentRoute: BottomNavBar.homeRoute
      ),
    );
  }
}
