import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_grade_badge.dart';
import '../../../manager/presentation/providers/manager_provider.dart';
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

class ProjectActionsGrid extends ConsumerWidget {
  const ProjectActionsGrid({required this.project, super.key});

  final ProjectListItem project;

  void _openServices(BuildContext context) {
    context.push(RouteNames.projectServices(project.id), extra: project);
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('Generating report...'),
            ],
          ),
          duration: Duration(days: 1),
        ),
      );

      final bytes = await ref
          .read(managerRemoteDatasourceProvider)
          .downloadReportPdf(project.id);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate report: Empty PDF')),
        );
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/aces-report-${project.id}.pdf');
      await file.writeAsBytes(bytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF download failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
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
            icon: Icons.description_outlined,
            label: 'Report',
            tintColor: AppColors.warning,
            onTap: () => _downloadPdf(context, ref),
          ),
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
