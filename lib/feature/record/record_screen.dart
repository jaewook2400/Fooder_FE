import 'package:flutter/material.dart';
import 'package:fooder_fe/shared/ui/bars/bottom_nav_bar.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("기록"),
      ),
      body: Text('record'),
      bottomNavigationBar: BottomNavBar(currentRoute: BottomNavBar.recordRoute),
    );
  }
}
