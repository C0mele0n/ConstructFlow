// lib/presentation/providers/project_provider.dart
//
// PROJECT PROVIDER (Riverpod)
// ===========================
// Manages project data: list of projects, current project, CRUD operations.
// Connects the local database to the UI.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../data/models/project.dart';
import '../../services/sync_service.dart';

/// Project list state
class ProjectListState {
  final List<Project> projects;
  final bool isLoading;
  final String? error;

  const ProjectListState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
  });

  ProjectListState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ProjectListState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Project list notifier
class ProjectListNotifier extends StateNotifier<ProjectListState> {
  final AppDatabase _db;
  final SyncService _syncService;

  ProjectListNotifier(this._db, this._syncService)
      : super(const ProjectListState()) {
    loadProjects();
  }

  /// Load all projects from local database
  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true);
    try {
      final localProjects = await _db.getAllProjects();
      // Convert local models to domain models
      final projects = localProjects.map((p) => _localToDomain(p)).toList();
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new project
  Future<String?> createProject({
    required String name,
    required String createdByUserId,
    String? address,
    String? description,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      // Save to local database
      await _db.insertProject(LocalProject(
        id: id,
        name: name,
        address: address,
        description: description,
        createdByUserId: createdByUserId,
        status: ProjectStatus.planning,
        createdAt: DateTime.now(),
        completedAt: null,
        isSynced: false,
      ));

      // Try to sync to Firestore if online
      if (await _syncService.isOnline) {
        await _syncService.createProject({
          'id': id,
          'name': name,
          'address': address,
          'description': description,
          'createdByUserId': createdByUserId,
          'status': ProjectStatus.planning.index,
          'createdAt': DateTime.now().toIso8601String(),
        });
        // Mark as synced
        final project = await _db.getProject(id);
        if (project != null) {
          await _db.updateProject(project.copyWith(isSynced: true));
        }
      }

      // Reload the list
      await loadProjects();
      return id;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Convert local database model to domain model
  Project _localToDomain(LocalProject p) {
    return Project(
      id: p.id,
      name: p.name,
      address: p.address,
      description: p.description,
      photoUrl: p.photoUrl,
      createdByUserId: p.createdByUserId,
      crew: const [], // TODO: load from memberships table
      status: p.status,
      createdAt: p.createdAt,
      completedAt: p.completedAt,
    );
  }
}

// ──────────────────────────────────────────────
// PROVIDERS
// ──────────────────────────────────────────────

/// Database provider (singleton)
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// Sync service provider (singleton)
final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

/// Project list provider
final projectListProvider =
    StateNotifierProvider<ProjectListNotifier, ProjectListState>((ref) {
  final db = ref.watch(databaseProvider);
  final sync = ref.watch(syncServiceProvider);
  return ProjectListNotifier(db, sync);
});

/// Current project provider (for project detail screen)
final currentProjectProvider =
    StateNotifierProvider.family<CurrentProjectNotifier, AsyncValue<Project?>, String>(
  (ref, projectId) {
    final db = ref.watch(databaseProvider);
    return CurrentProjectNotifier(db, projectId);
  },
);

class CurrentProjectNotifier extends StateNotifier<AsyncValue<Project?>> {
  final AppDatabase _db;
  final String _projectId;

  CurrentProjectNotifier(this._db, this._projectId)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final local = await _db.getProject(_projectId);
      if (local != null) {
        state = AsyncValue.data(Project(
          id: local.id,
          name: local.name,
          address: local.address,
          description: local.description,
          photoUrl: local.photoUrl,
          createdByUserId: local.createdByUserId,
          crew: const [],
          status: local.status,
          createdAt: local.createdAt,
          completedAt: local.completedAt,
        ));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
