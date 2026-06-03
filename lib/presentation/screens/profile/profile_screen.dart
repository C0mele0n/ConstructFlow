// lib/presentation/screens/profile/profile_screen.dart
//
// PROFILE SCREEN
// ==============
// Shows the user's profile: name, photo, trade specialties, and
// a portfolio of project history. This is where individual workers
// build their reputation over time.
//
// PORTFOLIO FEATURES:
// - Project history (projects participated in, roles held, dates)
// - Aggregate stats (total cuts, measurements, installations)
// - Exportable summary for resumes/job bids
// - Trade specialty tags

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/project.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Edit profile button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══ PROFILE HEADER ═══
            _buildProfileHeader(context),
            const SizedBox(height: 24),

            // ═══ TRADE SPECIALTIES ═══
            _buildTradeSpecialties(context),
            const SizedBox(height: 24),

            // ═══ PORTFOLIO STATS ═══
            _buildPortfolioStats(context),
            const SizedBox(height: 24),

            // ═══ PROJECT HISTORY ═══
            _buildProjectHistory(context),
            const SizedBox(height: 24),

            // ═══ EXPORT BUTTON ═══
            _buildExportButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // PROFILE HEADER
  // ══════════════════════════════════════════

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile photo
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
              child: const Icon(
                Icons.person,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              'John Doe', // TODO: From user provider
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),

            // Member since
            Text(
              'Member since Jan 2026', // TODO: From user data
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // TRADE SPECIALTIES
  // ══════════════════════════════════════════

  Widget _buildTradeSpecialties(BuildContext context) {
    // TODO: From user provider
    final specialties = ['Framing', 'Finish Carpentry', 'Deck Building'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trade Specialties',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: specialties.map((specialty) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                specialty,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // PORTFOLIO STATS
  // ══════════════════════════════════════════

  Widget _buildPortfolioStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Stats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCard(
              icon: Icons.straighten,
              label: 'Measurements',
              value: '142',
              color: AppTheme.roleColors['measurer']!,
            ),
            const SizedBox(width: 8),
            _StatCard(
              icon: Icons.content_cut,
              label: 'Cuts',
              value: '387',
              color: AppTheme.roleColors['cutter']!,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StatCard(
              icon: Icons.inventory_2,
              label: 'Materials',
              value: '89',
              color: AppTheme.roleColors['materialHandler']!,
            ),
            const SizedBox(width: 8),
            _StatCard(
              icon: Icons.handyman,
              label: 'Installations',
              value: '56',
              color: AppTheme.roleColors['installerAssembler']!,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StatCard(
              icon: Icons.folder,
              label: 'Projects',
              value: '12',
              color: AppTheme.roleColors['projectLeader']!,
            ),
            const SizedBox(width: 8),
            _StatCard(
              icon: Icons.attach_money,
              label: 'Value Tracked',
              value: '\$48K',
              color: AppTheme.roleColors['moneyHandler']!,
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // PROJECT HISTORY
  // ══════════════════════════════════════════

  Widget _buildProjectHistory(BuildContext context) {
    // TODO: From real data
    final projects = [
      _ProjectHistoryItem(
        name: 'Kitchen Remodel — 123 Main St',
        roles: [ProjectRole.measurer, ProjectRole.cutter],
        status: ProjectStatus.active,
        date: 'May 2026 — Present',
      ),
      _ProjectHistoryItem(
        name: 'Deck Build — 456 Oak Ave',
        roles: [ProjectRole.installerAssembler],
        status: ProjectStatus.completed,
        date: 'Apr 2026',
      ),
      _ProjectHistoryItem(
        name: 'Bathroom Reno — 789 Pine Rd',
        roles: [ProjectRole.measurer, ProjectRole.materialHandler, ProjectRole.cutter],
        status: ProjectStatus.completed,
        date: 'Mar 2026',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project History',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...projects.map((project) => _ProjectHistoryCard(project: project)),
      ],
    );
  }

  // ══════════════════════════════════════════
  // EXPORT BUTTON
  // ══════════════════════════════════════════

  Widget _buildExportButton(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Portfolio export coming in v1.1')),
          );
        },
        icon: const Icon(Icons.download, size: 22),
        label: const Text('Export Portfolio (PDF)'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          side: BorderSide(color: AppTheme.primaryColor),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // EDIT DIALOG
  // ══════════════════════════════════════════

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: 'John Doe');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Edit Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Trade specialties (simplified — would be a proper selector)
            const TextField(
              decoration: InputDecoration(
                labelText: 'Trade Specialties (comma separated)',
                hintText: 'Framing, Finish Carpentry, Deck Building',
                prefixIcon: Icon(Icons.build),
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
              // TODO: Save profile changes
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// HELPER WIDGETS
// ══════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectHistoryItem {
  final String name;
  final List<ProjectRole> roles;
  final ProjectStatus status;
  final String date;

  _ProjectHistoryItem({
    required this.name,
    required this.roles,
    required this.status,
    required this.date,
  });
}

class _ProjectHistoryCard extends StatelessWidget {
  final _ProjectHistoryItem project;

  const _ProjectHistoryCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final isActive = project.status == ProjectStatus.active;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project name + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.accentColor.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Completed',
                    style: TextStyle(
                      color: isActive ? AppTheme.accentColor : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Roles
            Wrap(
              spacing: 4,
              children: project.roles.map((role) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.roleColors[role.name]!.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role.shortName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.roleColors[role.name],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),

            // Date
            Text(
              project.date,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
