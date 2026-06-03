import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_container.dart';

class StatsCardWidget extends StatelessWidget {
  const StatsCardWidget({
    required this.title,
    required this.value,
    required this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? AppColors.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 240;
        final valueWidget = FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        );

        if (isNarrow) {
          return AppCard(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      AppIconContainer(icon: icon!, color: resolvedIconColor),
                      const SizedBox(width: AppDimensions.sm),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.secondary,
                ),
                const SizedBox(height: AppDimensions.sm),
                valueWidget,
              ],
            ),
          );
        }

        return AppCard(
          onTap: onTap,
          child: Row(
            children: [
              if (icon != null) ...[
                AppIconContainer(icon: icon!, color: resolvedIconColor),
                const SizedBox(width: AppDimensions.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Flexible(child: valueWidget),
            ],
          ),
        );
      },
    );
  }
}
