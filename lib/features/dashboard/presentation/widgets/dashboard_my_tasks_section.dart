import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/dashboard_strings.dart';
import '../providers/dashboard_operations_provider.dart';
import 'dashboard_section_header.dart';

class DashboardMyTasksSection extends StatelessWidget {
  const DashboardMyTasksSection({
    required this.tasks,
    required this.onOpenTasks,
    super.key,
  });

  final List<DashboardTaskSnapshotItem> tasks;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasTasks = tasks.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          eyebrow: DashboardStrings.sectionMyTasksEyebrow,
          title: DashboardStrings.sectionMyTasksTitle,
          subtitle: DashboardStrings.sectionMyTasksSubtitle,
          actionText: DashboardStrings.viewAllTasks,
          onActionTap: onOpenTasks,
        ),
        const SizedBox(height: AppDimensions.md),
        if (hasTasks)
          Column(
            children: [
              for (var index = 0; index < tasks.length; index++) ...[
                DashboardTaskPreviewItem(task: tasks[index]),
                if (index != tasks.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.sm,
                    ),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.42),
                    ),
                  ),
              ],
            ],
          )
        else
          const _TasksEmptyState(),
        SizedBox(height: hasTasks ? AppDimensions.sm : AppDimensions.xs),
      ],
    );
  }
}

class DashboardTaskPreviewItem extends StatelessWidget {
  const DashboardTaskPreviewItem({required this.task, super.key});

  final DashboardTaskSnapshotItem task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.28,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.projectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TasksEmptyState extends StatelessWidget {
  const _TasksEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DashboardStrings.noPendingTasksToday,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          DashboardStrings.sectionMyTasksSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
