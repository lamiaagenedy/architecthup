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
    super.key,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? AppColors.primary;

    return AppCard(
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
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppDimensions.xs),
                Text(subtitle, style: AppTextStyles.secondary),
              ],
            ),
          ),
          Text(
            value,
            style: AppTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
