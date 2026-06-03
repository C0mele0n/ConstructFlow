// lib/presentation/screens/cost/cost_overview_screen.dart
import 'package:flutter/material.dart';

class CostOverviewScreen extends StatelessWidget {
  final String projectId;
  const CostOverviewScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Costs')),
      body: const Center(child: Text('Cost overview for this project')),
    );
  }
}
