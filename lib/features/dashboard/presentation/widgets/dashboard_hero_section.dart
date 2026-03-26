import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/dashboard_strings.dart';
import '../../../../core/theme/design_tokens.dart';

class DashboardHeroSection extends StatelessWidget {
  const DashboardHeroSection({
    required this.userName,
    required this.dateLabel,
    required this.activeProjectCount,
    required this.pendingTaskCount,
    required this.onOpenProjects,
    required this.onOpenTasks,
    super.key,
  });

  final String userName;
  final String dateLabel;
  final int activeProjectCount;
  final int pendingTaskCount;
  final VoidCallback onOpenProjects;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(colorScheme.primary, Colors.black, 0.08)!,
            colorScheme.primary,
            Color.lerp(colorScheme.primary, colorScheme.secondary, 0.16)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              top: -18,
              right: -24,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onPrimary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -22,
              bottom: -46,
              child: Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onPrimary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 22,
              top: 78,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.onPrimary.withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroBadge(
                              icon: Icons.calendar_today_rounded,
                              label: dateLabel,
                            ),
                            const SizedBox(height: AppDimensions.md),
                            Text(
                              '${DashboardStrings.greetingPrefix}, $userName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary.withValues(
                                  alpha: 0.86,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.xs),
                            Text(
                              DashboardStrings.greetingHeadline,
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      _HeroLiveIndicator(
                        title: DashboardStrings.statusLive,
                        caption: DashboardStrings.dashboardLiveMonitor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.cardRadius,
                      ),
                      border: Border.all(
                        color: colorScheme.onPrimary.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Text(
                      DashboardStrings.greetingSubhead,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.92),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _DashboardHeroKpiTile(
                          label: DashboardStrings.summaryActiveProjects,
                          value: '$activeProjectCount',
                          icon: Icons.apartment_rounded,
                          helper: DashboardStrings.dashboardHeroProjectsHelper,
                          onTap: onOpenProjects,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: _DashboardHeroKpiTile(
                          label: DashboardStrings.summaryPendingTasks,
                          value: '$pendingTaskCount',
                          icon: Icons.task_alt_rounded,
                          helper: DashboardStrings.dashboardHeroTasksHelper,
                          onTap: onOpenTasks,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.onPrimary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onPrimary.withValues(alpha: 0.9),
          ),
          const SizedBox(width: AppDimensions.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.92),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLiveIndicator extends StatelessWidget {
  const _HeroLiveIndicator({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.onPrimary.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.secondary,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.secondary.withValues(alpha: 0.36),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.76),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeroKpiTile extends StatelessWidget {
  const _DashboardHeroKpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.helper,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String helper;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.onPrimary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.onPrimary.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colorScheme.onPrimary, size: 20),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                helper,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.78),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
