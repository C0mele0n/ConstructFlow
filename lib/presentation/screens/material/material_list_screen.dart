// lib/presentation/screens/material/material_list_screen.dart
import 'package:flutter/material.dart';

class MaterialListScreen extends StatelessWidget {
  final String projectId;
  const MaterialListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materials')),
      body: const Center(child: Text('Material list for this project')),
    );
  }
}
