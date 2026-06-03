// lib/presentation/screens/cut/cut_list_screen.dart
import 'package:flutter/material.dart';

class CutListScreen extends StatelessWidget {
  final String projectId;
  const CutListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cut List')),
      body: const Center(child: Text('Cut list for this project')),
    );
  }
}
