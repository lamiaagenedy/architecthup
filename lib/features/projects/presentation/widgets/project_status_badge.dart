import 'package:flutter/material.dart';

import '../../domain/entities/project_list_item.dart';

class ProjectStatusBadge extends StatelessWidget {
  const ProjectStatusBadge({required this.status, super.key});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          height: 1,
        ),
      ),
    );
  }
}

({Color background, Color border, Color foreground}) _statusColors(
  BuildContext context,
  ProjectStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;

  return switch (status) {
    ProjectStatus.pending => (
      background: Colors.orange.shade50.withValues(alpha: 0.82),
      border: Colors.orange.shade200.withValues(alpha: 0.65),
      foreground: Colors.orange.shade800,
    ),
    ProjectStatus.inProgress => (
      background: colorScheme.primaryContainer.withValues(alpha: 0.45),
      border: colorScheme.primary.withValues(alpha: 0.16),
      foreground: colorScheme.primary,
    ),
    ProjectStatus.completed => (
      background: colorScheme.secondaryContainer.withValues(alpha: 0.42),
      border: colorScheme.secondary.withValues(alpha: 0.16),
      foreground: colorScheme.secondary,
    ),
  };
}
