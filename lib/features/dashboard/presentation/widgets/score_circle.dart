import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class ScoreCircle extends StatelessWidget {
  const ScoreCircle({required this.score, this.foregroundColor, super.key});

  final int? score;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final resolvedForeground = foregroundColor ?? AppColors.primary;
    final hasScore = score != null;
    final progress = hasScore ? (score!.clamp(0, 100) / 100.0) : 0.0;

    return SizedBox(
      width: AppDimensions.xl + AppDimensions.sm,
      height: AppDimensions.xl + AppDimensions.sm,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: hasScore ? progress : 0,
            strokeWidth: 4,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(resolvedForeground),
          ),
          Text(
            hasScore ? '$score' : '-',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: hasScore ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
