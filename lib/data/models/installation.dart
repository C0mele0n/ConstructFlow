// lib/data/models/installation.dart
//
// INSTALLATION MODEL
// ==================
// Tracks what gets installed/assembled and where.
// The Installer/Assembler uses this to track progress and manage punch lists.

enum InstallationStatus {
  pending,
  inProgress,
  complete,
  flagged,       // Problem found
  needsReinspection, // Was flagged, fixed, needs to be checked again
}

extension InstallationStatusDisplay on InstallationStatus {
  String get displayName {
    switch (this) {
      case InstallationStatus.pending:
        return 'Pending';
      case InstallationStatus.inProgress:
        return 'In Progress';
      case InstallationStatus.complete:
        return 'Complete';
      case InstallationStatus.flagged:
        return 'Flagged';
      case InstallationStatus.needsReinspection:
        return 'Needs Re-inspection';
    }
  }
}

class Installation {
  final String id;
  final String projectId;
  final String description;        // e.g., "Install upper cabinets — Kitchen east wall"
  final String? locationOrArea;    // e.g., "Kitchen", "Master Bath", "Deck"
  final InstallationStatus status;
  final String? installedByUserId;
  final String? notes;
  final String? flagReason;        // Why it was flagged
  final List<String> photoUrls;    // Before/during/after photos
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  const Installation({
    required this.id,
    required this.projectId,
    required this.description,
    this.locationOrArea,
    this.status = InstallationStatus.pending,
    this.installedByUserId,
    this.notes,
    this.flagReason,
    this.photoUrls = const [],
    required this.createdAt,
    this.completedAt,
    this.updatedAt,
  });

  Installation copyWith({
    String? id,
    String? projectId,
    String? description,
    String? locationOrArea,
    InstallationStatus? status,
    String? installedByUserId,
    String? notes,
    String? flagReason,
    List<String>? photoUrls,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return Installation(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      description: description ?? this.description,
      locationOrArea: locationOrArea ?? this.locationOrArea,
      status: status ?? this.status,
      installedByUserId: installedByUserId ?? this.installedByUserId,
      notes: notes ?? this.notes,
      flagReason: flagReason ?? this.flagReason,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Installation($description — $status)';
}
