// lib/presentation/screens/measurement/measurement_list_screen.dart
import 'package:flutter/material.dart';

class MeasurementListScreen extends StatelessWidget {
  final String projectId;
  const MeasurementListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Measurements')),
      body: const Center(child: Text('Measurements for this project')),
    );
  }
}
