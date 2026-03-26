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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inspection readiness',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Review the quality checklist for this project and save the latest inspection ratings.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        context.push(
                          RouteNames.projectChecklist(project.id),
                          extra: project,
                        );
                      },
                      icon: const Icon(Icons.checklist_rounded),
                      label: const Text('Open Checklist'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
