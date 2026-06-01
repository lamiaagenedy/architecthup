import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppGradeBadge extends StatelessWidget {
  const AppGradeBadge({required this.label, this.score, super.key});

  final String label;
  final num? score;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(label, score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  _BadgeColors _resolveColors(String label, num? score) {
    final normalized = label.trim().toUpperCase();
    final numericScore = score ?? num.tryParse(normalized);

    if (numericScore != null) {
      if (numericScore >= 90) {
        return _BadgeColors(AppColors.success, AppColors.success);
      }
      if (numericScore >= 75) {
        return _BadgeColors(AppColors.warning, AppColors.warning);
      }
      return _BadgeColors(AppColors.danger, AppColors.danger);
    }

    if (normalized.startsWith('A')) {
      return _BadgeColors(AppColors.success, AppColors.success);
    }
    if (normalized.startsWith('B') || normalized.startsWith('C')) {
      return _BadgeColors(AppColors.warning, AppColors.warning);
    }

    return _BadgeColors(AppColors.danger, AppColors.danger);
  }
}

class _BadgeColors {
  _BadgeColors(this.base, this.foreground)
    : background = base.withValues(alpha: 0.14);

  final Color base;
  final Color foreground;
  final Color background;
}
