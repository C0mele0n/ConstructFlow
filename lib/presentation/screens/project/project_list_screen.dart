// lib/presentation/screens/project/project_list_screen.dart
//
// PROJECT LIST SCREEN (Riverpod version)
// =======================================
// Shows real projects from the database.
// Uses Riverpod to watch the project list and rebuild when data changes.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/project_provider.dart';
import '../../data/models/project.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(projectListProvider.notifier).loadProjects(),
          ),
        ],
      ),
      body: _buildBody(context, ref, projectState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/projects/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ProjectListState state) {
    if (state.isLoading && state.projects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(projectListProvider.notifier).loadProjects(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.projects.isEmpty) {
      return const Center(
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
      );
    }

    // Show project list
    return RefreshIndicator(
      onRefresh: () => ref.read(projectListProvider.notifier).loadProjects(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.projects.length,
        itemBuilder: (context, index) {
          final project = state.projects[index];
          return _ProjectCard(project: project);
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(project.status),
          child: Icon(
            _statusIcon(project.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.address != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.address!,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _statusText(project.status),
              style: TextStyle(
                fontSize: 12,
                color: _statusColor(project.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to project detail
          // context.go('/projects/${project.id}');
        },
      ),
    );
  }

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.orange;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.amber;
      case ProjectStatus.completed:
        return Colors.blue;
    }
  }

  IconData _statusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Icons.edit_note;
      case ProjectStatus.active:
        return Icons.play_arrow;
      case ProjectStatus.onHold:
        return Icons.pause;
      case ProjectStatus.completed:
        return Icons.check;
    }
  }

  String _statusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }
}
