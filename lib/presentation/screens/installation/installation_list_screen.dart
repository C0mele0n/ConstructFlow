// lib/presentation/screens/installation/installation_list_screen.dart
//
// INSTALLATION LIST SCREEN
// ========================
// The Installer/Assembler's primary screen. Shows all installation items
// for the project, organized by location/area. The Installer can:
// - Mark items as in-progress / complete
// - Flag items with issues
// - Add punch list items
// - Attach photos of completed work
// - See progress by area
//
// ORGANIZATION:
// Items are grouped by location/area (e.g., "Kitchen", "Master Bath", "Deck").
// This helps the installer focus on one area at a time.
//
// PUNCH LIST:
// Flagged items become punch list items. The Project Leader can see all
// punch list items across all areas and track resolution.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/installation.dart';
import '../../../core/theme/app_theme.dart';

class InstallationListScreen extends ConsumerWidget {
  final String projectId;

  const InstallationListScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installations'),
        actions: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '0/0 done',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add installation item screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.handyman_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No installation items yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Add items to track what goes where',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// INSTALLATION SECTION (grouped by area)
// ══════════════════════════════════════════════════

class InstallationSection extends StatelessWidget {
  final String areaName;
  final List<Installation> items;
  final Function(String itemId, InstallationStatus status)? onStatusChanged;
  final Function(String itemId, String reason)? onFlag;
  final VoidCallback? onAddPunchItem;

  const InstallationSection({
    super.key,
    required this.areaName,
    required this.items,
    this.onStatusChanged,
    this.onFlag,
    this.onAddPunchItem,
  });

  @override
  Widget build(BuildContext context) {
    final completed = items.where((i) => i.status == InstallationStatus.complete).length;
    final total = items.length;
    final flagged = items.where((i) => i.status == InstallationStatus.flagged).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══ AREA HEADER ═══
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppTheme.primaryColor.withOpacity(0.08),
          child: Row(
            children: [
              const Icon(Icons.place, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  areaName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              // Progress badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: completed == total
                      ? AppTheme.accentColor
                      : AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completed/$total',
                  style: TextStyle(
                    color: completed == total ? Colors.white : AppTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Flagged count
              if (flagged > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, size: 14, color: AppTheme.errorColor),
                      const SizedBox(width: 4),
                      Text(
                        '$flagged',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // ═══ INSTALLATION ITEMS ═══
        ...items.map((item) => InstallationCard(
              installation: item,
              onStatusChanged: onStatusChanged != null
                  ? (status) => onStatusChanged!(item.id, status)
                  : null,
              onFlag: onFlag != null
                  ? (reason) => onFlag!(item.id, reason)
                  : null,
            )),

        // ═══ ADD PUNCH LIST ITEM ═══
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextButton.icon(
            onPressed: onAddPunchItem,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Add punch list item'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ══════════════════════════════════════════════════
// INSTALLATION CARD WIDGET
// ══════════════════════════════════════════════════

class InstallationCard extends StatelessWidget {
  final Installation installation;
  final Function(InstallationStatus status)? onStatusChanged;
  final Function(String reason)? onFlag;

  const InstallationCard({
    super.key,
    required this.installation,
    this.onStatusChanged,
    this.onFlag,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = installation.status == InstallationStatus.complete;
    final isFlagged = installation.status == InstallationStatus.flagged;
    final isInProgress = installation.status == InstallationStatus.inProgress;

    return Card(
      color: isComplete
          ? AppTheme.accentColor.withOpacity(0.06)
          : isFlagged
              ? AppTheme.errorColor.withOpacity(0.06)
              : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ TOP ROW: Status indicator + description ═══
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _statusColor(installation.status),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _statusIcon(installation.status),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        installation.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isComplete ? Colors.grey : AppTheme.textPrimary,
                          decoration: isComplete ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (installation.notes != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          installation.notes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // ═══ FLAGGED REASON ═══
            if (isFlagged && installation.flagReason != null) ...[
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
                    Icon(Icons.warning_amber, color: AppTheme.errorColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        installation.flagReason!,
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ═══ PHOTO INDICATORS ═══
            if (installation.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.photo_library, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '${installation.photoUrls.length} photo${installation.photoUrls.length > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ],

            // ═══ TIMESTAMP ═══
            if (installation.completedAt != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: AppTheme.accentColor),
                  const SizedBox(width: 4),
                  Text(
                    'Completed ${_formatTime(installation.completedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // ═══ ACTION BUTTONS (big, glove-friendly) ═══
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = installation.status;

    // Complete: show only "needs re-inspection" if applicable
    if (status == InstallationStatus.complete) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onStatusChanged != null
                    ? () => onStatusChanged!(InstallationStatus.needsReinspection)
                    : null,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Needs Re-inspection'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warningColor,
                  side: BorderSide(color: AppTheme.warningColor),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Needs re-inspection: mark resolved
    if (status == InstallationStatus.needsReinspection) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onStatusChanged != null
                    ? () => onStatusChanged!(InstallationStatus.complete)
                    : null,
                icon: const Icon(Icons.check, size: 22),
                label: const Text('Mark Resolved'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Pending or in-progress: show complete + flag buttons
    return Row(
      children: [
        // Mark in-progress (only if pending)
        if (status == InstallationStatus.pending) ...[
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onStatusChanged != null
                    ? () => onStatusChanged!(InstallationStatus.inProgress)
                    : null,
                icon: const Icon(Icons.play_arrow, size: 22),
                label: const Text('Start'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warningColor,
                  side: BorderSide(color: AppTheme.warningColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Mark complete
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onStatusChanged != null
                  ? () => onStatusChanged!(InstallationStatus.complete)
                  : null,
              icon: const Icon(Icons.check, size: 22),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Flag button
        SizedBox(
          width: 56,
          height: 48,
          child: OutlinedButton(
            onPressed: onFlag != null ? () => _showFlagDialog(context) : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              side: BorderSide(color: AppTheme.errorColor),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.flag, size: 22),
          ),
        ),
      ],
    );
  }

  void _showFlagDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flag, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Flag Issue'),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Describe the issue...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isNotEmpty) {
                onFlag?.call(reason);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Flag'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(InstallationStatus status) {
    switch (status) {
      case InstallationStatus.pending:
        return Colors.grey;
      case InstallationStatus.inProgress:
        return AppTheme.warningColor;
      case InstallationStatus.complete:
        return AppTheme.accentColor;
      case InstallationStatus.flagged:
        return AppTheme.errorColor;
      case InstallationStatus.needsReinspection:
        return Colors.purple;
    }
  }

  IconData _statusIcon(InstallationStatus status) {
    switch (status) {
      case InstallationStatus.pending:
        return Icons.radio_button_unchecked;
      case InstallationStatus.inProgress:
        return Icons.play_arrow;
      case InstallationStatus.complete:
        return Icons.check;
      case InstallationStatus.flagged:
        return Icons.flag;
      case InstallationStatus.needsReinspection:
        return Icons.refresh;
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
