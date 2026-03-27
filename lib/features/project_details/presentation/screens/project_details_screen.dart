import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../projects/domain/entities/project_list_item.dart';
import '../../../projects/presentation/widgets/project_status_badge.dart';

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

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progressPercent = (project.progress * 100).round();

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          Text(
            project.name,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Icon(
                Icons.place_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: Text(
                  project.location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: [
              ProjectStatusBadge(status: project.status),
              _DetailPill(label: '$progressPercent% complete'),
              _DetailPill(label: project.updatedLabel),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            'Actions',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
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

  void _openQualityCheck(BuildContext context) {
    context.push(RouteNames.projectChecklist(project.id), extra: project);
  }

  void _showComingSoon(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(const SnackBar(content: Text('Coming Soon')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ProjectActionCard(
                icon: Icons.checklist_rounded,
                label: 'Quality Check',
                tintColor: colorScheme.primary,
                onTap: () => _openQualityCheck(context),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: ProjectActionCard(
                icon: Icons.photo_camera_outlined,
                label: 'Add Photos',
                tintColor: colorScheme.tertiary,
                onTap: () => _showComingSoon(context),
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
                tintColor: Colors.orange.shade700,
                onTap: () => _showComingSoon(context),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: ProjectActionCard(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Comments',
                tintColor: colorScheme.secondary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AspectRatio(
      aspectRatio: 1.1,
      child: Material(
        color: colorScheme.surface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: tintColor.withValues(alpha: 0.16)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Theme.of(context).splashColor,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
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
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
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
