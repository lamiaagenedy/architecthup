import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/project_list_item.dart';

class ProjectStatusBadge extends StatelessWidget {
  const ProjectStatusBadge({required this.status, super.key});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

({Color background, Color foreground}) _statusColors(
  BuildContext context,
  ProjectStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;

  return switch (status) {
    ProjectStatus.pending => (
      background: Colors.orange.shade50,
      foreground: Colors.orange.shade800,
    ),
    ProjectStatus.inProgress => (
      background: colorScheme.primaryContainer.withValues(alpha: 0.6),
      foreground: colorScheme.primary,
    ),
    ProjectStatus.completed => (
      background: colorScheme.secondaryContainer.withValues(alpha: 0.55),
      foreground: colorScheme.secondary,
    ),
  };
}
