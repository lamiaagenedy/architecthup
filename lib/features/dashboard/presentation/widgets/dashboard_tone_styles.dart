import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_snapshot.dart';

({Color background, Color border, Color foreground}) dashboardToneColors(
  BuildContext context,
  DashboardTone tone,
) {
  final colorScheme = Theme.of(context).colorScheme;

  return switch (tone) {
    DashboardTone.positive => (
      background: colorScheme.secondaryContainer.withValues(alpha: 0.55),
      border: colorScheme.secondary.withValues(alpha: 0.18),
      foreground: colorScheme.secondary,
    ),
    DashboardTone.caution => (
      background: Colors.orange.shade50,
      border: Colors.orange.shade200,
      foreground: Colors.orange.shade700,
    ),
    DashboardTone.critical => (
      background: colorScheme.errorContainer.withValues(alpha: 0.55),
      border: colorScheme.error.withValues(alpha: 0.16),
      foreground: colorScheme.error,
    ),
    DashboardTone.neutral => (
      background: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      border: colorScheme.outlineVariant.withValues(alpha: 0.6),
      foreground: colorScheme.onSurfaceVariant,
    ),
  };
}
