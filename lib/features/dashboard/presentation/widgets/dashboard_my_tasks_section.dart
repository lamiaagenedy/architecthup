import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
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
          AppCard(
            child: Column(
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
                        color: AppColors.divider,
                      ),
                    ),
                ],
              ],
            ),
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
                color: AppColors.primary,
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
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.projectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.secondary,
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DashboardStrings.noPendingTasksToday,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            DashboardStrings.sectionMyTasksSubtitle,
            style: AppTextStyles.secondary,
          ),
        ],
      ),
    );
  }
}
