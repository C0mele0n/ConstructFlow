// lib/presentation/widgets/role_badge.dart
//
// ROLE BADGE WIDGET
// =================
// A small colored badge that shows a user's role.
// Used in project crew lists, user cards, etc.

import 'package:flutter/material.dart';
import '../../data/models/project.dart';
import '../../core/theme/app_theme.dart';

class RoleBadge extends StatelessWidget {
  final ProjectRole role;
  final bool compact;

  const RoleBadge({
    super.key,
    required this.role,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(role);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        compact ? role.shortName : role.displayName,
        style: TextStyle(
          color: color,
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _roleColor(ProjectRole role) {
    switch (role) {
      case ProjectRole.measurer:
        return AppTheme.roleColors['measurer']!;
      case ProjectRole.materialHandler:
        return AppTheme.roleColors['materialHandler']!;
      case ProjectRole.cutter:
        return AppTheme.roleColors['cutter']!;
      case ProjectRole.installerAssembler:
        return AppTheme.roleColors['installerAssembler']!;
      case ProjectRole.moneyHandler:
        return AppTheme.roleColors['moneyHandler']!;
      case ProjectRole.projectLeader:
        return AppTheme.roleColors['projectLeader']!;
    }
  }
}
