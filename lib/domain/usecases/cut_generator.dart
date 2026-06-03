// lib/domain/usecases/cut_generator.dart
//
// CUT GENERATOR
// =============
// Generates an optimized cut list from measurements.
//
// This is the "brain" of the cut list feature. It takes measurements
// and figures out how to cut them from standard material sizes with
// minimal waste.
//
// ALGORITHM (First Fit Decreasing - FFD):
// 1. Sort cuts from longest to shortest
// 2. For each cut, try to fit it on an existing board/sheet
// 3. If it doesn't fit, start a new board/sheet
// 4. Track waste for each board
//
// This is a "bin packing" problem — a classic optimization problem.
// FFD is simple and gives good results (typically within 22% of optimal).
//
// For MVP, we use a simplified version. A production app would use
// a more sophisticated algorithm or a third-party library.

import '../../data/models/cut.dart';
import '../../data/models/measurement.dart';

/// Standard material sizes (length in inches)
/// In a real app, this would come from a material database
const Map<String, double> standardSizes = {
  'plywood': 96,       // 4ft × 8ft sheet = 96 inches long
  'drywall': 96,       // 4ft × 8ft or 4ft × 12ft
  'lumber 8ft': 96,    // 8 feet
  'lumber 10ft': 120,  // 10 feet
  'lumber 12ft': 144,  // 12 feet
  'lumber 16ft': 192,  // 16 feet
  'default': 96,       // Default to 8ft
};

/// Kerf width — the width of the saw blade (material lost per cut)
const double sawKerf = 0.125; // 1/8 inch typical

/// A single board/sheet with cuts assigned to it
class CutBoard {
  final double totalLength;
  final List<CutAssignment> cuts = [];

  CutBoard(this.totalLength);

  /// Remaining length after all assigned cuts
  double get remainingLength {
    double used = 0;
    for (final cut in cuts) {
      used += cut.length + sawKerf;
    }
    return totalLength - used;
  }

  /// Waste percentage (0.0 to 1.0)
  double get wastePercent => 1 - (remainingLength / totalLength);

  /// Can a cut of this length fit?
  bool canFit(double length) => remainingLength >= length + sawKerf;
}

/// A cut assigned to a board
class CutAssignment {
  final String cutId;
  final String measurementId;
  final double length;
  final double position; // Position along the board

  CutAssignment({
    required this.cutId,
    required this.measurementId,
    required this.length,
    required this.position,
  });
}

/// Result of cut generation
class CutGenerationResult {
  final List<CutBoard> boards;
  final List<Cut> cuts;
  final double totalWaste;
  final int totalBoards;

  CutGenerationResult({
    required this.boards,
    required this.cuts,
    required this.totalWaste,
    required this.totalBoards,
  });
}

/// Generates an optimized cut list from measurements
class CutGenerator {
  /// Generate cuts from a list of measurements
  static CutGenerationResult generate({
    required List<Measurement> measurements,
    required String projectId,
    double? customBoardLength,
  }) {
    // Step 1: Extract all individual cuts from measurements
    final allCuts = <_RawCut>[];
    for (final measurement in measurements) {
      for (int i = 0; i < measurement.quantity; i++) {
        allCuts.add(_RawCut(
          measurementId: measurement.id,
          length: measurement.dimensions.length,
          unit: measurement.dimensions.unit,
          materialType: measurement.materialType,
        ));
      }
    }

    // Step 2: Group by material type and unit
    final grouped = <String, List<_RawCut>>{};
    for (final cut in allCuts) {
      final key = '${cut.materialType}_${cut.unit.name}';
      grouped.putIfAbsent(key, () => []).add(cut);
    }

    // Step 3: Optimize each group
    final resultBoards = <CutBoard>[];
    final resultCuts = <Cut>[];
    int cutCounter = 0;

    for (final entry in grouped.entries) {
      final materialType = entry.key;
      final cuts = entry.value;

      // Sort cuts longest first (FFD algorithm)
      cuts.sort((a, b) => b.length.compareTo(a.length));

      // Determine board length
      final boardLength = customBoardLength ??
          _getStandardBoardLength(materialType, cuts.first.unit);

      // Assign cuts to boards
      final boards = _assignCutsToBoards(cuts, boardLength);

      // Create Cut objects
      for (final board in boards) {
        resultBoards.add(board);
        for (final assignment in board.cuts) {
          resultCuts.add(Cut(
            id: 'cut_${cutCounter++}',
            measurementId: assignment.measurementId,
            projectId: projectId,
            length: assignment.length,
            unit: cuts.first.unit,
            quantity: 1,
            status: CutStatus.pending,
            createdAt: DateTime.now(),
          ));
        }
      }
    }

    // Calculate total waste
    double totalWaste = 0;
    for (final board in resultBoards) {
      totalWaste += board.remainingLength;
    }

    return CutGenerationResult(
      boards: resultBoards,
      cuts: resultCuts,
      totalWaste: totalWaste,
      totalBoards: resultBoards.length,
    );
  }

  /// Assign cuts to boards using First Fit Decreasing
  static List<CutBoard> _assignCutsToBoards(
    List<_RawCut> cuts,
    double boardLength,
  ) {
    final boards = <CutBoard>[];

    for (final cut in cuts) {
      // Try to fit on an existing board
      bool placed = false;
      for (final board in boards) {
        if (board.canFit(cut.length)) {
          final position = board.totalLength - board.remainingLength;
          board.cuts.add(CutAssignment(
            cutId: '${cut.measurementId}_${boards.indexOf(board)}',
            measurementId: cut.measurementId,
            length: cut.length,
            position: position,
          ));
          placed = true;
          break;
        }
      }

      // If it didn't fit, start a new board
      if (!placed) {
        final newBoard = CutBoard(boardLength);
        newBoard.cuts.add(CutAssignment(
          cutId: '${cut.measurementId}_${boards.length}',
          measurementId: cut.measurementId,
          length: cut.length,
          position: 0,
        ));
        boards.add(newBoard);
      }
    }

    return boards;
  }

  /// Get standard board length for a material type
  static double _getStandardBoardLength(String materialType, MeasurementUnit unit) {
    // Convert to inches for comparison
    for (final entry in standardSizes.entries) {
      if (materialType.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    return standardSizes['default']!;
  }
}

/// Internal class for raw cut data before optimization
class _RawCut {
  final String measurementId;
  final double length;
  final MeasurementUnit unit;
  final String materialType;

  _RawCut({
    required this.measurementId,
    required this.length,
    required this.unit,
    required this.materialType,
  });
}
