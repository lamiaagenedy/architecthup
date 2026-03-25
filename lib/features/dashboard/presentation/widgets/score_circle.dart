import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';

class ScoreCircle extends StatelessWidget {
  const ScoreCircle({required this.score, this.foregroundColor, super.key});

  final int? score;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedForeground = foregroundColor ?? theme.colorScheme.primary;
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
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(resolvedForeground),
          ),
          Text(
            hasScore ? '$score' : '-',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: hasScore
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
