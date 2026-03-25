import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.color, this.size = AppDimensions.lg});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Icon(
      Icons.apartment_rounded,
      size: size,
      color: color ?? colorScheme.onPrimary,
    );
  }
}
