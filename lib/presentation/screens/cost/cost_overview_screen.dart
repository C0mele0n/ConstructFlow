// lib/presentation/screens/cost/cost_overview_screen.dart
//
// COST OVERVIEW SCREEN
// ====================
// The Money Handler's primary screen. Shows all costs for the project,
// real-time running totals, budget tracking, and invoice generation.
//
// FEATURES:
// - Running total of all costs (materials + labor + other)
// - Costs grouped by type (Material, Labor, Equipment, etc.)
// - Add new costs manually
// - Real-time sync: costs update live across all crew members
// - Invoice generation (v1.1)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cost.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class CostOverviewScreen extends ConsumerWidget {
  final String projectId;

  const CostOverviewScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Costs'),
        actions: [
          // Generate invoice button (v1.1)
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Generate Invoice',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice generation coming in v1.1')),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCostDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Cost'),
      ),
    );
  }

  void _showAddCostDialog(BuildContext context, WidgetRef ref) {
    // TODO: Navigate to full add cost screen
    // For now, show a simple dialog
    final descController = TextEditingController();
    final amountController = TextEditingController();
    CostType selectedType = CostType.material;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text('Add Cost'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cost type selector
                  SegmentedButton<CostType>(
                    segments: const [
                      ButtonSegment(
                        value: CostType.material,
                        label: Text('Material'),
                        icon: Icon(Icons.inventory_2, size: 18),
                      ),
                      ButtonSegment(
                        value: CostType.labor,
                        label: Text('Labor'),
                        icon: Icon(Icons.person, size: 18),
                      ),
                      ButtonSegment(
                        value: CostType.other,
                        label: Text('Other'),
                        icon: Icon(Icons.more_horiz, size: 18),
                      ),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (selected) {
                      setDialogState(() => selectedType = selected.first);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'e.g., 3/4 Plywood — 12 sheets',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Amount
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (descController.text.trim().isNotEmpty && amount > 0) {
                      // TODO: Save cost via provider
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cost added')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        // ═══ COST SUMMARY HEADER ═══
        _buildCostSummaryHeader(context),

        // ═══ COST LIST ═══
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Placeholder — real data comes from provider
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.attach_money, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No costs yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add costs as they come in',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostSummaryHeader(BuildContext context) {
    // Currency formatter
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          // Grand total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                currency.format(0),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cost type breakdown
          Row(
            children: [
              _CostTypeSummary(label: 'Materials', amount: 0, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              _CostTypeSummary(label: 'Labor', amount: 0, color: AppTheme.secondaryColor),
              const SizedBox(width: 12),
              _CostTypeSummary(label: 'Other', amount: 0, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

}

// ══════════════════════════════════════════════════
// COST TYPE SUMMARY WIDGET
// ══════════════════════════════════════════════════

class _CostTypeSummary extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _CostTypeSummary({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currency.format(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// COST CARD WIDGET
// ══════════════════════════════════════════════════

class CostCard extends StatelessWidget {
  final Cost cost;
  final VoidCallback? onTap;

  const CostCard({
    super.key,
    required this.cost,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final typeColor = _typeColor(cost.type);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _typeIcon(cost.type),
                  color: typeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Description + type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cost.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cost.type.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(cost.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currency.format(cost.amount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year % 100}';
  }

  Color _typeColor(CostType type) {
    switch (type) {
      case CostType.material:
        return AppTheme.primaryColor;
      case CostType.labor:
        return AppTheme.secondaryColor;
      case CostType.equipment:
        return Colors.purple;
      case CostType.subcontractor:
        return Colors.teal;
      case CostType.permit:
        return Colors.brown;
      case CostType.other:
        return Colors.grey;
    }
  }

  IconData _typeIcon(CostType type) {
    switch (type) {
      case CostType.material:
        return Icons.inventory_2;
      case CostType.labor:
        return Icons.person;
      case CostType.equipment:
        return Icons.build;
      case CostType.subcontractor:
        return Icons.group;
      case CostType.permit:
        return Icons.description;
      case CostType.other:
        return Icons.more_horiz;
    }
  }
}

// ══════════════════════════════════════════════════
// ADD COST SCREEN (full screen version)
// ══════════════════════════════════════════════════

class AddCostScreen extends ConsumerStatefulWidget {
  final String projectId;

  const AddCostScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<AddCostScreen> createState() => _AddCostScreenState();
}

class _AddCostScreenState extends ConsumerState<AddCostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  CostType _selectedType = CostType.material;
  bool _isSaving = false;

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // TODO: Save via provider
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cost added'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Cost'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveCost,
            child: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cost type selector
            Text('Cost Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CostType.values.map((type) {
                final isSelected = type == _selectedType;
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Description
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'e.g., 3/4 Plywood — 12 sheets',
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (\$) *',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any additional details...',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveCost,
                icon: const Icon(Icons.check, size: 24),
                label: Text(_isSaving ? 'SAVING...' : 'SAVE COST'),
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
