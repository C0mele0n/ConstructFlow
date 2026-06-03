// lib/presentation/screens/project/project_dashboard_screen.dart
//
// PROJECT DASHBOARD SCREEN
// ========================
// The Project Leader's primary view. An aggregate overview showing:
// - Overall project progress (all phases)
// - Measurements status (logged vs. total)
// - Cut list progress (% complete)
// - Materials status (on-site vs. needed)
// - Installation progress (% complete)
// - Cost summary (spent vs. budget)
// - Crew status (who's assigned to what)
// - Quick actions (invite crew, generate reports)
//
// DESIGN:
// - Cards for each metric — easy to scan at a glance
// - Progress bars for visual progress tracking
// - Color-coded status indicators
// - Big buttons for quick actions
//
// This is the "mission control" screen for the project.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/project.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ProjectDashboardScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDashboardScreen({
    super.key,
  required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Invite crew button
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Invite Crew',
            onPressed: () => _showInviteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══ OVERALL PROGRESS ═══
            _OverallProgressCard(),
            const SizedBox(height: 16),

            // ═══ MEASUREMENTS + CUTS ROW ═══
            Row(
              children: [
                Expanded(child: _MeasurementSummaryCard()),
                const SizedBox(width: 12),
                Expanded(child: _CutProgressCard()),
              ],
            ),
            const SizedBox(height: 16),

            // ═══ MATERIALS + INSTALLATIONS ROW ═══
            Row(
              children: [
                Expanded(child: _MaterialStatusCard()),
                const SizedBox(width: 12),
                Expanded(child: _InstallationProgressCard()),
              ],
            ),
            const SizedBox(height: 16),

            // ═══ COST SUMMARY ═══
            _CostSummaryCard(),
            const SizedBox(height: 16),

            // ═══ CREW STATUS ═══
            _CrewStatusCard(),
            const SizedBox(height: 16),

            // ═══ QUICK ACTIONS ═══
            _QuickActionsCard(projectId: projectId),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    final phoneController = TextEditingController();
    ProjectRole selectedRole = ProjectRole.measurer;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_add, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('Invite Crew Member'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Phone number
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1 (555) 123-4567',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),

              // Role selector
              DropdownButtonFormField<ProjectRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Initial Role',
                  prefixIcon: Icon(Icons.badge),
                ),
                items: ProjectRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.roleColors[role.name],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(role.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (role) {
                  if (role != null) {
                    setDialogState(() => selectedRole = role);
                  }
                },
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
                // TODO: Send invite
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invite sent')),
                );
              },
              child: const Text('Send Invite'),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// OVERALL PROGRESS CARD
// ══════════════════════════════════════════════════

class _OverallProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'OVERALL PROGRESS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // TODO: Compute from real data
            const Text(
              '32%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.32,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phase 2: Build in progress',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// MEASUREMENT SUMMARY CARD
// ══════════════════════════════════════════════════

class _MeasurementSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Measurements',
      icon: Icons.straighten,
      iconColor: AppTheme.roleColors['measurer']!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Real data from provider
          const Text(
            '18',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text(
            'logged',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _StatusRow(label: 'Pending review', count: 3, color: Colors.orange),
          _StatusRow(label: 'Approved', count: 15, color: AppTheme.accentColor),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// CUT PROGRESS CARD
// ══════════════════════════════════════════════════

class _CutProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Cuts',
      icon: Icons.content_cut,
      iconColor: AppTheme.roleColors['cutter']!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '12/36',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text(
            'complete',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 12 / 36,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.roleColors['cutter']!,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '33%',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// MATERIAL STATUS CARD
// ══════════════════════════════════════════════════

class _MaterialStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Materials',
      icon: Icons.inventory_2,
      iconColor: AppTheme.roleColors['materialHandler']!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '8/12',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text(
            'on site',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _StatusRow(label: 'Needed', count: 4, color: Colors.red),
          _StatusRow(label: 'Picked up', count: 2, color: Colors.blue),
          _StatusRow(label: 'On site', count: 8, color: AppTheme.accentColor),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// INSTALLATION PROGRESS CARD
// ══════════════════════════════════════════════════

class _InstallationProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Installation',
      icon: Icons.handyman,
      iconColor: AppTheme.roleColors['installerAssembler']!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5/14',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text(
            'complete',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 5 / 14,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.roleColors['installerAssembler']!,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          _StatusRow(label: 'Flagged', count: 2, color: AppTheme.errorColor),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// COST SUMMARY CARD
// ══════════════════════════════════════════════════

class _CostSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return _DashboardCard(
      title: 'Costs',
      icon: Icons.attach_money,
      iconColor: AppTheme.roleColors['moneyHandler']!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total spent
          Text(
            currency.format(4250),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text(
            'total spent',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Breakdown
          Row(
            children: [
              Expanded(
                child: _CostBreakdownItem(
                  label: 'Materials',
                  amount: 2800,
                  color: AppTheme.primaryColor,
                ),
              ),
              Expanded(
                child: _CostBreakdownItem(
                  label: 'Labor',
                  amount: 1200,
                  color: AppTheme.secondaryColor,
                ),
              ),
              Expanded(
                child: _CostBreakdownItem(
                  label: 'Other',
                  amount: 250,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          // Budget bar (if budget is set)
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Budget: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
              Text(
                currency.format(6000),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Text(
                '71% used',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 4250 / 6000,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.warningColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// CREW STATUS CARD
// ══════════════════════════════════════════════════

class _CrewStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Load from real crew data
    final crewMembers = [
      _CrewMember(name: 'John D.', roles: [ProjectRole.projectLeader], isActive: true),
      _CrewMember(name: 'Mike S.', roles: [ProjectRole.measurer, ProjectRole.cutter], isActive: true),
      _CrewMember(name: 'Carlos R.', roles: [ProjectRole.materialHandler], isActive: false),
      _CrewMember(name: 'Sarah K.', roles: [ProjectRole.installerAssembler], isActive: true),
      _CrewMember(name: 'Tom W.', roles: [ProjectRole.moneyHandler], isActive: false),
    ];

    return _DashboardCard(
      title: 'Crew',
      icon: Icons.group,
      iconColor: AppTheme.roleColors['projectLeader']!,
      child: Column(
        children: crewMembers.map((member) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: member.isActive
                          ? AppTheme.accentColor
                          : Colors.grey[300],
                      child: Text(
                        member.name.split(' ').map((n) => n[0]).join(),
                        style: TextStyle(
                          color: member.isActive ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (member.isActive)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Name + roles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 4,
                        children: member.roles.map((role) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.roleColors[role.name]!.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role.shortName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.roleColors[role.name],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Status
                Text(
                  member.isActive ? 'Active' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: member.isActive ? AppTheme.accentColor : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CrewMember {
  final String name;
  final List<ProjectRole> roles;
  final bool isActive;

  _CrewMember({
    required this.name,
    required this.roles,
    required this.isActive,
  });
}

// ══════════════════════════════════════════════════
// QUICK ACTIONS CARD
// ══════════════════════════════════════════════════

class _QuickActionsCard extends StatelessWidget {
  final String projectId;

  const _QuickActionsCard({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Quick Actions',
      icon: Icons.bolt,
      iconColor: AppTheme.warningColor,
      child: Column(
        children: [
          // Action buttons row 1
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.person_add,
                  label: 'Invite Crew',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    // TODO: Show invite dialog
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.share,
                  label: 'Share Project',
                  color: AppTheme.secondaryColor,
                  onTap: () {
                    // TODO: Share project link
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Action buttons row 2
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.file_download,
                  label: 'Export Data',
                  color: Colors.teal,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export coming soon')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.receipt_long,
                  label: 'Generate Invoice',
                  color: AppTheme.roleColors['moneyHandler']!,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invoice generation in v1.1')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Mark complete button (full width, prominent)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Show confirmation dialog
              },
              icon: const Icon(Icons.check_circle_outline, size: 22),
              label: const Text('Mark Project Complete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentColor,
                side: BorderSide(color: AppTheme.accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusRow({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CostBreakdownItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _CostBreakdownItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          currency.format(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
