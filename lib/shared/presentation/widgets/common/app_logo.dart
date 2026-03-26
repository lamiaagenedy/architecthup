import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = AppDimensions.xl,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.all(AppDimensions.sm),
    this.backgroundColor,
    this.borderColor,
    this.elevation = 0,
    this.fit = BoxFit.contain,
    this.showHighlight = true,
  });

  final double size;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double elevation;
  final BoxFit fit;
  final bool showHighlight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveRadius = BorderRadius.circular(borderRadius);

    return Material(
      elevation: elevation,
      color: Colors.transparent,
      borderRadius: effectiveRadius,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          gradient: showHighlight
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.98),
                    (backgroundColor ?? colorScheme.surface).withValues(
                      alpha: 0.96,
                    ),
                  ],
                )
              : null,
          color: showHighlight ? null : backgroundColor ?? colorScheme.surface,
          border: Border.all(
            color:
                borderColor ??
                colorScheme.outlineVariant.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                borderRadius - AppDimensions.xs,
              ),
              color: backgroundColor ?? colorScheme.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                borderRadius - AppDimensions.md,
              ),
              child: Image.asset(
                'assets/logo.jpg',
                fit: fit,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
