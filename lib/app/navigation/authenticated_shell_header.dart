import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/design_tokens.dart';
import '../../shared/presentation/widgets/common/app_logo.dart';

class AuthenticatedShellHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const AuthenticatedShellHeader({
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    super.key,
  });

  final String title;
  final String subtitle;
  final String eyebrow;

  @override
  Size get preferredSize =>
      const Size.fromHeight(DesignTokens.shellHeaderHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: ClipPath(
          clipper: const _ShellHeaderClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  Color.lerp(colorScheme.primary, colorScheme.secondary, 0.22)!,
                  Color.lerp(colorScheme.primary, Colors.black, 0.12)!,
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: -32,
                  right: -28,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.onPrimary.withValues(alpha: 0.08),
                    ),
                    child: const SizedBox(width: 132, height: 132),
                  ),
                ),
                Positioned(
                  left: -12,
                  bottom: -52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.onPrimary.withValues(alpha: 0.08),
                    ),
                    child: const SizedBox(width: 116, height: 116),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 360;
                      final badgeSize = isCompact ? 50.0 : 60.0;
                      final actionSize = isCompact ? 36.0 : 40.0;

                      return Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          DesignTokens.shellHeaderHorizontalPadding,
                          DesignTokens.shellHeaderTopSpacing,
                          DesignTokens.shellHeaderHorizontalPadding,
                          DesignTokens.shellHeaderBottomSpacing,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppLogo(
                              size: badgeSize,
                              borderRadius: isCompact ? 20 : 24,
                              padding: EdgeInsets.all(
                                isCompact ? AppDimensions.xs : AppDimensions.sm,
                              ),
                              elevation: 6,
                              backgroundColor: Colors.white,
                              borderColor: colorScheme.onPrimary.withValues(
                                alpha: 0.78,
                              ),
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: AppDimensions.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    eyebrow,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        (isCompact
                                                ? textTheme.labelMedium
                                                : textTheme.labelLarge)
                                            ?.copyWith(
                                              color: colorScheme.onPrimary
                                                  .withValues(alpha: 0.84),
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.2,
                                            ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        (isCompact
                                                ? textTheme.titleLarge
                                                : textTheme.headlineSmall)
                                            ?.copyWith(
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    maxLines: isCompact ? 1 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onPrimary.withValues(
                                        alpha: 0.9,
                                      ),
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Container(
                              width: actionSize,
                              height: actionSize,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.onPrimary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colorScheme.onPrimary.withValues(
                                    alpha: 0.18,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: colorScheme.onPrimary.withValues(
                                  alpha: 0.9,
                                ),
                                size: isCompact ? 18 : 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellHeaderClipper extends CustomClipper<Path> {
  const _ShellHeaderClipper();

  @override
  Path getClip(Size size) {
    final curveDepth = DesignTokens.shellHeaderCurveDepth;
    final path = Path()
      ..lineTo(0, size.height - curveDepth)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height + 10,
        size.width * 0.5,
        size.height - curveDepth * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height - curveDepth - 8,
        size.width,
        size.height - curveDepth,
      )
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
