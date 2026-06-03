// lib/presentation/screens/cut/cut_list_screen.dart
//
// CUT LIST SCREEN
// ===============
// The Cutter's primary screen. Shows all cuts needed for the project,
// organized by material type. The Cutter can:
// - Mark cuts as complete (big ✅ button)
// - Flag cuts with issues (big 🚩 button)
// - Request more material
// - See progress at a glance
//
// VOICE FLOW:
// The Cutter can also use voice to mark cuts:
// - "Mark cut 3 complete" → finds cut #3, marks it done
// - "Flag cut 7" → flags cut #7 with a prompt for the issue
// - "Request more plywood" → creates a material request

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cut.dart';
import '../../../data/models/measurement.dart';
import '../../../core/theme/app_theme.dart';

class CutListScreen extends ConsumerWidget {
  final String projectId;

  const CutListScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Watch cuts from provider
    // final cuts = ref.watch(cutListProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cut List'),
        actions: [
          // Progress indicator in app bar
          // TODO: Show "12/36 cuts done" when we have real data
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '0/0 cuts',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // TODO: Check if cuts are loading
    // if (cuts.isLoading) return const Center(child: CircularProgressIndicator());

    // Placeholder for now
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.content_cut, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No cut list yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Cut lists are generated from measurements',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// CUT CARD WIDGET
// ══════════════════════════════════════════════════

class CutCard extends StatelessWidget {
  final Cut cut;
  final int index; // Display number (1, 2, 3...) for voice commands
  final VoidCallback? onMarkComplete;
  final VoidCallback? onFlag;
  final VoidCallback? onTap;

  const CutCard({
    super.key,
    required this.cut,
    required this.index,
    this.onMarkComplete,
    this.onFlag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = cut.status == CutStatus.complete;
    final isFlagged = cut.status == CutStatus.flagged;

    return Card(
      color: isComplete
          ? AppTheme.accentColor.withOpacity(0.08)
          : isFlagged
              ? AppTheme.errorColor.withOpacity(0.08)
              : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══ TOP ROW: Cut number + status + actions ═══
              Row(
                children: [
                  // Cut number badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _statusColor(cut.status),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isComplete
                          ? const Icon(Icons.check, color: Colors.white, size: 22)
                          : Text(
                              '$index',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Cut details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cut.length.toStringAsFixed(cut.length % 1 == 0 ? 0 : 2)} ${cut.unit.symbol}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isComplete ? Colors.grey : AppTheme.textPrimary,
                            decoration: isComplete ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (cut.quantity > 1)
                          Text(
                            '× ${cut.quantity} pieces',
                            style: TextStyle(
                              fontSize: 14,
                              color: isComplete ? Colors.grey : AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ═══ ACTION BUTTONS (big, glove-friendly) ═══
                  if (!isComplete) ...[
                    // Mark complete button
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onMarkComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.check, size: 28),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Flag button
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: onFlag,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: BorderSide(color: AppTheme.errorColor),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.flag, size: 24),
                      ),
                    ),
                  ],
                ],
              ),

              // ═══ FLAGGED REASON ═══
              if (isFlagged && cut.flagReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: AppTheme.errorColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cut.flagReason!,
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ═══ COMPLETED BY / TIMESTAMP ═══
              if (isComplete && cut.completedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppTheme.accentColor),
                    const SizedBox(width: 6),
                    Text(
                      'Completed ${_formatTime(cut.completedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(CutStatus status) {
    switch (status) {
      case CutStatus.pending:
        return Colors.grey;
      case CutStatus.inProgress:
        return AppTheme.warningColor;
      case CutStatus.complete:
        return AppTheme.accentColor;
      case CutStatus.flagged:
        return AppTheme.errorColor;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}';
  }
}
