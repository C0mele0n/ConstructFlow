// lib/data/models/measurement.dart
//
// MEASUREMENT MODEL
// =================
// A single measurement entry. The Measurer logs dimensions, material type,
// quantity, and priority. Measurements generate cut lists and material lists.
//
// KEY DART CONCEPTS IN THIS FILE:
// - Nested object (Dimensions class inside Measurement)
// - Computed property (totalArea getter)
// - Enum with extension for display names

/// Units of measurement
enum MeasurementUnit {
  inches,
  feet,
  centimeters,
  meters,
}

extension MeasurementUnitDisplay on MeasurementUnit {
  String get symbol {
    switch (this) {
      case MeasurementUnit.inches:
        return 'in';
      case MeasurementUnit.feet:
        return 'ft';
      case MeasurementUnit.centimeters:
        return 'cm';
      case MeasurementUnit.meters:
        return 'm';
    }
  }

  String get displayName {
    switch (this) {
      case MeasurementUnit.inches:
        return 'Inches';
      case MeasurementUnit.feet:
        return 'Feet';
      case MeasurementUnit.centimeters:
        return 'Centimeters';
      case MeasurementUnit.meters:
        return 'Meters';
    }
  }
}

/// Priority levels for measurements
enum Priority {
  low,
  medium,
  high,
  critical,
}

extension PriorityDisplay on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.critical:
        return 'Critical';
    }
  }
}

/// Dimensions — a nested data class representing length, width, height
class Dimensions {
  final double length;
  final double? width;   // Optional — some materials are linear (pipes, trim)
  final double? height;  // Optional — some are 2D (sheet goods)
  final MeasurementUnit unit;

  const Dimensions({
    required this.length,
    this.width,
    this.height,
    this.unit = MeasurementUnit.inches,
  });

  /// Computed: total area (length × width). Returns null if width is null.
  double? get area {
    if (width == null) return null;
    return length * width!;
  }

  /// Computed: formatted string like "48in × 96in" or "12ft (linear)"
  String get displayString {
    if (width == null) {
      return '$length ${unit.symbol} (linear)';
    }
    if (height == null) {
      return '$length × $width ${unit.symbol}';
    }
    return '$length × $width × $height ${unit.symbol}';
  }

  Dimensions copyWith({
    double? length,
    double? width,
    double? height,
    MeasurementUnit? unit,
  }) {
    return Dimensions(
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      unit: unit ?? this.unit,
    );
  }
}

/// A single measurement entry
class Measurement {
  final String id;
  final String projectId;         // Which project this belongs to
  final String measuredByUserId;  // Who took the measurement
  final Dimensions dimensions;
  final String materialType;      // e.g., "3/4 Plywood", "2x4", "Tile"
  final int quantity;             // How many of this measurement
  final Priority priority;
  final String? notes;            // Free-text notes
  final List<String> photoUrls;   // Photos of the measured area
  final DateTime createdAt;

  const Measurement({
    required this.id,
    required this.projectId,
    required this.measuredByUserId,
    required this.dimensions,
    required this.materialType,
    this.quantity = 1,
    this.priority = Priority.medium,
    this.notes,
    this.photoUrls = const [],
    required this.createdAt,
  });

  /// Computed: total area × quantity
  double? get totalArea {
    final a = dimensions.area;
    if (a == null) return null;
    return a * quantity;
  }

  Measurement copyWith({
    String? id,
    String? projectId,
    String? measuredByUserId,
    Dimensions? dimensions,
    String? materialType,
    int? quantity,
    Priority? priority,
    String? notes,
    List<String>? photoUrls,
    DateTime? createdAt,
  }) {
    return Measurement(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      measuredByUserId: measuredByUserId ?? this.measuredByUserId,
      dimensions: dimensions ?? this.dimensions,
      materialType: materialType ?? this.materialType,
      quantity: quantity ?? this.quantity,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Measurement($materialType: ${dimensions.displayString} × $quantity)';
}
