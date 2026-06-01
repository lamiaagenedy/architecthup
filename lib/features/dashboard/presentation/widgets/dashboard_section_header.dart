import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.eyebrow,
    this.actionText,
    this.onActionTap,
    super.key,
  }) : assert(
         (actionText == null && onActionTap == null) ||
             (actionText != null && onActionTap != null),
         'actionText and onActionTap must be provided together.',
       );

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? eyebrow;
  final String? actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final trailingWidget =
        trailing ??
        (actionText != null
            ? TextButton(
                onPressed: onActionTap,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: AppDimensions.xs,
                  ),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  foregroundColor: AppColors.primary,
                  textStyle: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(actionText!),
                    const SizedBox(width: AppDimensions.xs),
                    const Icon(Icons.arrow_outward_rounded, size: 16),
                  ],
                ),
              )
            : null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactActionLayout =
              trailingWidget != null && constraints.maxWidth < 360;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(title, style: AppTextStyles.sectionTitle),
                  ),
                  if (!compactActionLayout && trailingWidget != null) ...[
                    const SizedBox(width: AppDimensions.md),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: trailingWidget,
                    ),
                  ],
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppDimensions.sm),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: trailingWidget == null ? double.infinity : 560,
                  ),
                  child: Text(subtitle!, style: AppTextStyles.secondary),
                ),
              ],
              if (compactActionLayout) ...[
                const SizedBox(height: AppDimensions.sm),
                trailingWidget,
              ],
            ],
          );
        },
      ),
    );
  }
}
