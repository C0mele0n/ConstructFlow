// lib/presentation/screens/project/project_create_screen.dart
//
// PROJECT CREATE SCREEN
// =====================
// Form to create a new project. The user who creates it
// automatically becomes the Project Leader.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectCreateScreen extends StatefulWidget {
  const ProjectCreateScreen({super.key});

  @override
  State<ProjectCreateScreen> createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends State<ProjectCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    // TODO: Save to Firebase
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      context.go('/projects');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Project name (required)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name *',
                hintText: 'Kitchen Remodel - 123 Main St',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Project name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address (optional)
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: '123 Main St, Anytown, USA',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // Description (optional)
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Notes about the job...',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Create button
            ElevatedButton(
              onPressed: _isCreating ? null : _createProject,
              child: _isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }
}
