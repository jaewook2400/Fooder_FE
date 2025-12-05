import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/ui/bars/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필"),
      ),
      body: Text('profile'),
      bottomNavigationBar: BottomNavBar(currentRoute: BottomNavBar.profileRoute),
    );
  }
}
