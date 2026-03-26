import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/project_list_item.dart';
import 'project_status_badge.dart';

class ProjectListItemCard extends StatelessWidget {
  const ProjectListItemCard({
    required this.project,
    required this.onTap,
    super.key,
  });

  final ProjectListItem project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressPercent = (project.progress * 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: DesignTokens.shortAnimation,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.54),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  ProjectStatusBadge(status: project.status),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Expanded(
                    child: Text(
                      project.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
              _ProjectProgressBlock(
                progress: project.progress,
                progressPercent: progressPercent,
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Updated ${project.updatedLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectProgressBlock extends StatelessWidget {
  const _ProjectProgressBlock({
    required this.progress,
    required this.progressPercent,
  });

  final double progress;
  final int progressPercent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressColor = _progressColor(context, progressPercent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$progressPercent%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Color _progressColor(BuildContext context, int progressPercent) {
  final colorScheme = Theme.of(context).colorScheme;

  if (progressPercent >= 90) {
    return colorScheme.secondary;
  }
  if (progressPercent >= 65) {
    return colorScheme.primary;
  }

  return Colors.orange.shade700;
}
