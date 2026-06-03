import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                  foregroundColor: colorScheme.primary,
                  textStyle: textTheme.labelLarge?.copyWith(
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
              Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.06,
                        color: colorScheme.onSurface,
                      ),
                    ),
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
                  child: Text(
                    subtitle!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
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
