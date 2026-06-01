import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dashboard_snapshot.dart';

({Color background, Color border, Color foreground}) dashboardToneColors(
  BuildContext context,
  DashboardTone tone,
) {
  return switch (tone) {
    DashboardTone.positive => (
      background: AppColors.success.withValues(alpha: 0.12),
      border: AppColors.success.withValues(alpha: 0.25),
      foreground: AppColors.success,
    ),
    DashboardTone.caution => (
      background: AppColors.warning.withValues(alpha: 0.12),
      border: AppColors.warning.withValues(alpha: 0.25),
      foreground: AppColors.warning,
    ),
    DashboardTone.critical => (
      background: AppColors.danger.withValues(alpha: 0.12),
      border: AppColors.danger.withValues(alpha: 0.25),
      foreground: AppColors.danger,
    ),
    DashboardTone.neutral => (
      background: AppColors.divider,
      border: AppColors.divider,
      foreground: AppColors.textSecondary,
    ),
  };
}
