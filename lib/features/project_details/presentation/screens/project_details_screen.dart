import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_grade_badge.dart';
import '../../../projects/domain/entities/project_list_item.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({required this.project, super.key})
    : _missingProjectId = null;

  const ProjectDetailsScreen.missing({required String projectId, super.key})
    : project = null,
      _missingProjectId = projectId;

  final ProjectListItem? project;
  final String? _missingProjectId;

  @override
  Widget build(BuildContext context) {
    final project = this.project;
    if (project == null) {
      return _MissingProjectDetailsView(projectId: _missingProjectId ?? '');
    }

    final progressPercent = (project.progress * 100).round();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () => context.pop(),
        ),
        title: const Text('Project Details'),
      ),
      body: ListView(
        padding: AppDimensions.screenPadding,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: AppTextStyles.sectionTitle,
                      ),
                    ),
                    AppGradeBadge(
                      label: project.grade ?? '—',
                      score: progressPercent,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Expanded(
                      child: Text(
                        project.location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Wrap(
                  spacing: AppDimensions.sm,
                  runSpacing: AppDimensions.sm,
                  children: [
                    _DetailPill(label: '$progressPercent% complete'),
                    _DetailPill(label: project.updatedLabel),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSection),
          Text('Actions', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppDimensions.md),
          ProjectActionsGrid(project: project),
        ],
      ),
    );
  }
}

class ProjectActionsGrid extends StatelessWidget {
  const ProjectActionsGrid({required this.project, super.key});

  final ProjectListItem project;

  void _openServices(BuildContext context) {
    context.push(RouteNames.projectServices(project.id), extra: project);
  }

  void _openStats(BuildContext context) {
    context.push(
      '${RouteNames.projectDetails(project.id)}/stats',
      extra: project,
    );
  }

  void _showComingSoon(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(const SnackBar(content: Text('Coming Soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ProjectActionCard(
                icon: Icons.checklist_rounded,
                label: 'Inspection',
                tintColor: AppColors.primary,
                onTap: () => _openServices(context),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: ProjectActionCard(
                icon: Icons.analytics_outlined,
                label: 'Stats',
                tintColor: AppColors.primary,
                onTap: () => _openStats(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        Row(
          children: [
            Expanded(
              child: ProjectActionCard(
                icon: Icons.description_outlined,
                label: 'Reports',
                tintColor: AppColors.warning,
                onTap: () => _showComingSoon(context),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: ProjectActionCard(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Comments',
                tintColor: AppColors.success,
                onTap: () => _showComingSoon(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProjectActionCard extends StatelessWidget {
  const ProjectActionCard({
    required this.icon,
    required this.label,
    required this.tintColor,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color tintColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: AppCard(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppDimensions.xl + AppDimensions.xs,
              height: AppDimensions.xl + AppDimensions.xs,
              decoration: BoxDecoration(
                color: tintColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.sm + 2),
              ),
              child: Icon(icon, color: tintColor, size: AppDimensions.md),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _MissingProjectDetailsView extends StatelessWidget {
  const _MissingProjectDetailsView({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Text(
          'Project data is unavailable for "$projectId". Please reopen details from the projects list.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
