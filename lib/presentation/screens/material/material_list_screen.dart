// lib/presentation/screens/material/material_list_screen.dart
//
// MATERIAL LIST SCREEN
// ====================
// The Material Handler's primary screen. Shows all materials needed for
// the project, auto-generated from measurements. The Material Handler can:
// - Mark materials as picked up / delivered / on-site
// - See what's still needed
// - Add manual materials (not from measurements)
// - See real-time cost totals
//
// BIG BUTTON DESIGN:
// - Each material card has big status toggle buttons
// - Swipe right to mark next status
// - Tap to edit details (supplier, cost, notes)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/material.dart';
import '../../../core/theme/app_theme.dart';

class MaterialListScreen extends ConsumerWidget {
  final String projectId;

  const MaterialListScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials'),
        actions: [
          // Total cost display
          // TODO: Show running total when we have real data
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Total: \$0.00',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add material screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Material'),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No materials yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Materials are generated from measurements',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// MATERIAL CARD WIDGET
// ══════════════════════════════════════════════════

class MaterialCard extends StatelessWidget {
  final Material material;
  final VoidCallback? onStatusChanged;
  final VoidCallback? onTap;

  const MaterialCard({
    super.key,
    required this.material,
    this.onStatusChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(material.status);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══ TOP ROW: Material name + status ═══
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (material.typeCategory != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            material.typeCategory!,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      material.status.displayName,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ═══ QUANTITY + SIZE ═══
              Row(
                children: [
                  // Quantity
                  _InfoChip(
                    icon: Icons.numbers,
                    label: '${material.quantityOnSite}/${material.quantityNeeded}',
                    sublabel: 'on site',
                  ),
                  const SizedBox(width: 12),
                  // Size
                  if (material.size != null)
                    _InfoChip(
                      icon: Icons.straighten,
                      label: material.size!,
                    ),
                  const SizedBox(width: 12),
                  // Cost
                  if (material.unitCost != null)
                    _InfoChip(
                      icon: Icons.attach_money,
                      label: '\$${material.unitCost!.toStringAsFixed(2)}',
                      sublabel: 'per unit',
                    ),
                ],
              ),

              // ═══ TOTAL COST ═══
              if (material.totalCost != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calculate, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Total: \$${material.totalCost!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],

              // ═══ SUPPLIER ═══
              if (material.supplier != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.store, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      material.supplier!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],

              // ═══ NOTES ═══
              if (material.notes != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.notes, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        material.notes!,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // ═══ STATUS ACTION BUTTONS (big, glove-friendly) ═══
              _StatusActionButtons(
                material: material,
                onStatusChanged: onStatusChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(MaterialStatus status) {
    switch (status) {
      case MaterialStatus.needed:
        return Colors.red;
      case MaterialStatus.ordered:
        return Colors.orange;
      case MaterialStatus.pickedUp:
        return Colors.blue;
      case MaterialStatus.delivered:
        return Colors.teal;
      case MaterialStatus.onSite:
        return AppTheme.accentColor;
    }
  }
}

// ══════════════════════════════════════════════════
// STATUS ACTION BUTTONS
// ══════════════════════════════════════════════════
// Big buttons to advance the material to the next status.
// Each button is 48px tall minimum for glove-friendly use.

class _StatusActionButtons extends StatelessWidget {
  final Material material;
  final VoidCallback? onStatusChanged;

  const _StatusActionButtons({
    required this.material,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Show the next logical action based on current status
    switch (material.status) {
      case MaterialStatus.needed:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Mark as ordered
                    onStatusChanged?.call();
                  },
                  icon: const Icon(Icons.shopping_cart, size: 22),
                  label: const Text('Mark Ordered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );

      case MaterialStatus.ordered:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Mark as picked up
                    onStatusChanged?.call();
                  },
                  icon: const Icon(Icons.local_shipping, size: 22),
                  label: const Text('Mark Picked Up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );

      case MaterialStatus.pickedUp:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Mark as delivered
                    onStatusChanged?.call();
                  },
                  icon: const Icon(Icons.delivery_dining, size: 22),
                  label: const Text('Mark Delivered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );

      case MaterialStatus.delivered:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Mark as on-site
                    onStatusChanged?.call();
                  },
                  icon: const Icon(Icons.check_circle, size: 22),
                  label: const Text('Confirm On Site'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );

      case MaterialStatus.onSite:
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.accentColor),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppTheme.accentColor, size: 22),
                SizedBox(width: 8),
                Text(
                  'On Site — Ready to Use',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}

// ══════════════════════════════════════════════════
// INFO CHIP WIDGET
// ══════════════════════════════════════════════════

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
