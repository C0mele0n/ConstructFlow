// lib/presentation/screens/project/project_list_screen.dart
//
// PROJECT LIST SCREEN
// ===================
// Shows all projects the user belongs to.
// This is the home screen after logging in.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No projects yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first project to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/projects/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }
}
