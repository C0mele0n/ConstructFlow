// lib/data/models/project.dart
//
// PROJECT MODEL
// =============
// A project is the main workspace. It represents one job site or job.
// All measurements, cuts, materials, costs, and installation notes
// for a job live inside one project.
//
// KEY DART CONCEPTS IN THIS FILE:
// - Enum = a fixed set of named values (like a dropdown list)
// - List of custom objects (List<ProjectMembership>)
// - Factory constructor = constructor that doesn't always create a new instance

/// The current status of a project
enum ProjectStatus {
  planning,    // Just created, being set up
  active,      // Work is happening
  onHold,      // Paused for some reason
  completed,   // Job is done
}

extension ProjectStatusDisplay on ProjectStatus {
  String get displayName {
    switch (this) {
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

class Project {
  final String id;
  final String name;              // "Kitchen Remodel - 123 Main St"
  final String? address;          // Job site address (optional)
  final String? description;      // Notes about the job
  final String? photoUrl;         // Photo of the job site
  final String createdByUserId;   // Who created the project
  final List<ProjectMembership> crew;  // People on the project + their roles
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;    // When the job was marked done

  const Project({
    required this.id,
    required this.name,
    this.address,
    this.description,
    this.photoUrl,
    required this.createdByUserId,
    this.crew = const [],
    this.status = ProjectStatus.planning,
    required this.createdAt,
    this.completedAt,
  });

  // Helper: get all user IDs in this project
  List<String> get crewMemberIds => crew.map((m) => m.userId).toList();

  // Helper: check if a specific user is on this project
  bool hasMember(String userId) => crewMemberIds.contains(userId);

  // Helper: get the roles a specific user holds on this project
  List<ProjectRole> getRolesForUser(String userId) {
    final membership = crew.where((m) => m.userId == userId);
    return membership.expand((m) => m.roles).toList();
  }

  // copyWith pattern (same as User)
  Project copyWith({
    String? id,
    String? name,
    String? address,
    String? description,
    String? photoUrl,
    String? createdByUserId,
    List<ProjectMembership>? crew,
    ProjectStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      crew: crew ?? this.crew,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name, status: $status)';
}

// ──────────────────────────────────────────────
// PROJECT MEMBERSHIP
// ──────────────────────────────────────────────
// Links a user to a project and tracks which roles they hold.
// One user can have multiple roles on the same project.

class ProjectMembership {
  final String userId;
  final List<ProjectRole> roles;
  final DateTime joinedAt;

  const ProjectMembership({
    required this.userId,
    this.roles = const [],
    required this.joinedAt,
  });

  ProjectMembership copyWith({
    String? userId,
    List<ProjectRole>? roles,
    DateTime? joinedAt,
  }) {
    return ProjectMembership(
      userId: userId ?? this.userId,
      roles: roles ?? this.roles,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

// ──────────────────────────────────────────────
// PROJECT ROLES (the six roles)
// ──────────────────────────────────────────────

enum ProjectRole {
  measurer,
  materialHandler,
  cutter,
  installerAssembler,
  moneyHandler,
  projectLeader,
}

// Extension: adds a human-readable display name to each role
// This is a Dart "extension" — it adds methods to an existing type
// without modifying the original enum.
extension ProjectRoleDisplay on ProjectRole {
  String get displayName {
    switch (this) {
      case ProjectRole.measurer:
        return 'Measurer';
      case ProjectRole.materialHandler:
        return 'Material Handler';
      case ProjectRole.cutter:
        return 'Cutter';
      case ProjectRole.installerAssembler:
        return 'Installer/Assembler';
      case ProjectRole.moneyHandler:
        return 'Money Handler';
      case ProjectRole.projectLeader:
        return 'Project Leader';
    }
  }

  String get shortName {
    switch (this) {
      case ProjectRole.measurer:
        return 'Measure';
      case ProjectRole.materialHandler:
        return 'Material';
      case ProjectRole.cutter:
        return 'Cut';
      case ProjectRole.installerAssembler:
        return 'Install';
      case ProjectRole.moneyHandler:
        return 'Money';
      case ProjectRole.projectLeader:
        return 'Lead';
    }
  }
}
