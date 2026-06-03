// lib/data/models/cut.dart
//
// CUT MODEL
// =========
// Represents a single cut from a cut list. Generated from measurements.
// The Cutter sees these and marks them complete.

enum CutStatus {
  pending,    // Not started
  inProgress, // Currently being cut
  complete,   // Done
  flagged,    // Problem — needs attention
}

extension CutStatusDisplay on CutStatus {
  String get displayName {
    switch (this) {
      case CutStatus.pending:
        return 'Pending';
      case CutStatus.inProgress:
        return 'In Progress';
      case CutStatus.complete:
        return 'Complete';
      case CutStatus.flagged:
        return 'Flagged';
    }
  }
}

class Cut {
  final String id;
  final String measurementId;     // Which measurement this cut comes from
  final String projectId;
  final double length;            // Cut length
  final MeasurementUnit unit;
  final int quantity;             // How many of this cut
  final CutStatus status;
  final String? cutByUserId;      // Who cut it (null if not assigned)
  final String? notes;            // Cutter's notes
  final String? flagReason;       // Why it was flagged
  final DateTime createdAt;
  final DateTime? completedAt;

  const Cut({
    required this.id,
    required this.measurementId,
    required this.projectId,
    required this.length,
    this.unit = MeasurementUnit.inches,
    this.quantity = 1,
    this.status = CutStatus.pending,
    this.cutByUserId,
    this.notes,
    this.flagReason,
    required this.createdAt,
    this.completedAt,
  });

  Cut copyWith({
    String? id,
    String? measurementId,
    String? projectId,
    double? length,
    MeasurementUnit? unit,
    int? quantity,
    CutStatus? status,
    String? cutByUserId,
    String? notes,
    String? flagReason,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Cut(
      id: id ?? this.id,
      measurementId: measurementId ?? this.measurementId,
      projectId: projectId ?? this.projectId,
      length: length ?? this.length,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      cutByUserId: cutByUserId ?? this.cutByUserId,
      notes: notes ?? this.notes,
      flagReason: flagReason ?? this.flagReason,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() => 'Cut($length ${unit.symbol} × $quantity — $status)';
}
