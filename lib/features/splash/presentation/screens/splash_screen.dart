import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/splash_flow_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashFlowProvider);
    final config = ref.watch(appConfigProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.xl,
          ),
          child: Column(
            children: <Widget>[
              const Spacer(),
              _SplashBrandMark(color: AppColors.primary),
              const SizedBox(height: AppDimensions.lg),
              Text(AppStrings.appName, style: AppTextStyles.pageTitle),
              const SizedBox(height: AppDimensions.sm),
              Text(
                AppStrings.splashTagline,
                style: AppTextStyles.secondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xl),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Container(
                  padding: AppDimensions.cardPadding,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusCard,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppStrings.splashLoadingMessage,
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        splashState.statusMessage,
                        style: AppTextStyles.secondary,
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      const LinearProgressIndicator(minHeight: 6),
                      const SizedBox(height: AppDimensions.lg),
                      _SplashStepRow(
                        label: AppStrings.splashBootstrapMessage,
                        isComplete: splashState.bootstrapReady,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      _SplashStepRow(
                        label: AppStrings.splashConfigMessage,
                        isComplete: splashState.configReady,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      _SplashStepRow(
                        label: AppStrings.splashSessionMessage,
                        isComplete: splashState.authChecked,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(config.environmentLabel, style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashBrandMark extends StatelessWidget {
  const _SplashBrandMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Icon(
        Icons.domain_add_rounded,
        color: Colors.white,
        size: 42,
      ),
    );
  }
}

class _SplashStepRow extends StatelessWidget {
  const _SplashStepRow({required this.label, required this.isComplete});

  final String label;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isComplete
                ? AppColors.primary.withValues(alpha: 0.14)
                : AppColors.divider,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isComplete ? Icons.check_rounded : Icons.more_horiz_rounded,
            size: 14,
            color: isComplete ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(child: Text(label, style: AppTextStyles.body)),
      ],
    );
  }
}
