import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

class AppIconContainer extends StatelessWidget {
  const AppIconContainer({required this.icon, required this.color, super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.iconContainer,
      height: AppDimensions.iconContainer,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }
}
