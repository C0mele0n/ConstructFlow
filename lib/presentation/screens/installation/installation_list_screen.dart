// lib/presentation/screens/installation/installation_list_screen.dart
import 'package:flutter/material.dart';

class InstallationListScreen extends StatelessWidget {
  final String projectId;
  const InstallationListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Installations')),
      body: const Center(child: Text('Installation list for this project')),
    );
  }
}
