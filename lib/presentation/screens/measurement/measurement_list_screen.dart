// lib/presentation/screens/measurement/measurement_list_screen.dart
//
// MEASUREMENT LIST SCREEN
// =======================
// Shows all measurements for a project.
// From here, the Measurer can:
// - Add a new measurement
// - View/edit existing measurements
// - Generate cut list
// - Generate material list

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/measurement.dart';
import '../../../core/theme/app_theme.dart';

class MeasurementListScreen extends ConsumerWidget {
  final String projectId;

  const MeasurementListScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Watch measurements from provider
    // final measurements = ref.watch(measurementsProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurements'),
        actions: [
          // Generate cut list button
          IconButton(
            icon: const Icon(Icons.content_cut),
            tooltip: 'Generate Cut List',
            onPressed: () {
              // TODO: Navigate to cut list
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.straighten, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No measurements yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add your first measurement',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to measurement entry screen
          // context.go('/project/$projectId/measurements/new');
        },
        icon: const Icon(Icons.add),
        label: const Text('Measure'),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// MEASUREMENT CARD WIDGET
// ══════════════════════════════════════════════════

class MeasurementCard extends StatelessWidget {
  final Measurement measurement;
  final VoidCallback? onTap;

  const MeasurementCard({
    super.key,
    required this.measurement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = AppTheme.priorityColors[measurement.priority.name]!;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: material type + priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      measurement.materialType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Priority tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      measurement.priority.displayName,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dimensions
              Row(
                children: [
                  const Icon(Icons.straighten, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    measurement.dimensions.displayString,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  if (measurement.quantity > 1) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.close, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${measurement.quantity}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),

              // Notes (if any)
              if (measurement.notes != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.notes, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        measurement.notes!,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Timestamp
              const SizedBox(height: 8),
              Text(
                _formatTime(measurement.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
