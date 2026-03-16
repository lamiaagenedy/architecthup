import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/design_tokens.dart';
import '../providers/splash_flow_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashFlowProvider);
    final config = ref.watch(appConfigProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              colorScheme.primary.withValues(alpha: 0.18),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.xl,
            ),
            child: Column(
              children: <Widget>[
                const Spacer(),
                _SplashBrandMark(color: colorScheme.primary),
                const SizedBox(height: AppDimensions.lg),
                Text(
                  AppStrings.appName,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(letterSpacing: -0.6),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  AppStrings.splashTagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xl),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Container(
                    padding: DesignTokens.cardPadding,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.screenRadius,
                      ),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppStrings.splashLoadingMessage,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          splashState.statusMessage,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
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
                Text(
                  config.environmentLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.4,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        AnimatedContainer(
          duration: DesignTokens.shortAnimation,
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isComplete
                ? colorScheme.primary.withValues(alpha: 0.14)
                : colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isComplete ? Icons.check_rounded : Icons.more_horiz_rounded,
            size: 14,
            color: isComplete
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
