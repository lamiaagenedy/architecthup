import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/project_list_item.dart';
import '../providers/projects_provider.dart';
import '../widgets/project_list_item_card.dart';
import '../widgets/projects_state_views.dart';

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsListProvider);
    final filteredProjectsAsync = ref.watch(filteredProjectsProvider);
    final selectedStatus = ref.watch(projectsStatusFilterProvider);
    final totalProjectsCount = projectsAsync.valueOrNull?.length ?? 0;

    return filteredProjectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return _ProjectsScaffold(
            visibleProjectsCount: 0,
            totalProjectsCount: totalProjectsCount,
            searchController: _searchController,
            selectedStatus: selectedStatus,
            onSearchChanged: _handleSearchChanged,
            onStatusSelected: _handleStatusSelected,
            onRefresh: _refreshProjects,
            child: const ProjectsEmptyView(),
          );
        }

        return _ProjectsScaffold(
          visibleProjectsCount: projects.length,
          totalProjectsCount: totalProjectsCount,
          searchController: _searchController,
          selectedStatus: selectedStatus,
          onSearchChanged: _handleSearchChanged,
          onStatusSelected: _handleStatusSelected,
          onRefresh: _refreshProjects,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, index) {
              final project = projects[index];

              return ProjectListItemCard(
                project: project,
                onTap: () => context.go(
                  RouteNames.projectDetails(project.id),
                  extra: project,
                ),
              );
            },
          ),
        );
      },
      loading: () => _ProjectsScaffold(
        visibleProjectsCount: totalProjectsCount,
        totalProjectsCount: totalProjectsCount,
        searchController: _searchController,
        selectedStatus: selectedStatus,
        onSearchChanged: _handleSearchChanged,
        onStatusSelected: _handleStatusSelected,
        onRefresh: _refreshProjects,
        child: const ProjectsLoadingView(),
      ),
      error: (error, stackTrace) => _ProjectsScaffold(
        visibleProjectsCount: totalProjectsCount,
        totalProjectsCount: totalProjectsCount,
        searchController: _searchController,
        selectedStatus: selectedStatus,
        onSearchChanged: _handleSearchChanged,
        onStatusSelected: _handleStatusSelected,
        onRefresh: _refreshProjects,
        child: ProjectsErrorView(onRetry: _refreshProjects),
      ),
    );
  }

  void _handleSearchChanged(String value) {
    ref.read(projectsQueryProvider.notifier).state = value;
  }

  void _handleStatusSelected(ProjectStatus? status) {
    ref.read(projectsStatusFilterProvider.notifier).state = status;
  }

  Future<void> _refreshProjects() async {
    ref.invalidate(projectsListProvider);
    await ref.read(projectsListProvider.future);
  }
}

class _ProjectsScaffold extends StatelessWidget {
  const _ProjectsScaffold({
    required this.visibleProjectsCount,
    required this.totalProjectsCount,
    required this.searchController,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onStatusSelected,
    required this.onRefresh,
    required this.child,
  });

  final int visibleProjectsCount;
  final int totalProjectsCount;
  final TextEditingController searchController;
  final ProjectStatus? selectedStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ProjectStatus?> onStatusSelected;
  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: DesignTokens.pagePadding,
          children: [
            _ProjectsHeader(
              visibleProjectsCount: visibleProjectsCount,
              totalProjectsCount: totalProjectsCount,
              selectedStatus: selectedStatus,
            ),
            const SizedBox(height: AppDimensions.lg),
            _ProjectsSearchField(
              controller: searchController,
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: AppDimensions.md),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _StatusFilterChip(
                    label: 'All',
                    isSelected: selectedStatus == null,
                    onTap: () => onStatusSelected(null),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  ...ProjectStatus.values.map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(right: AppDimensions.sm),
                      child: _StatusFilterChip(
                        label: status.label,
                        isSelected: selectedStatus == status,
                        onTap: () => onStatusSelected(status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProjectsHeader extends StatelessWidget {
  const _ProjectsHeader({
    required this.visibleProjectsCount,
    required this.totalProjectsCount,
    required this.selectedStatus,
  });

  final int visibleProjectsCount;
  final int totalProjectsCount;
  final ProjectStatus? selectedStatus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filterLabel = selectedStatus?.label ?? 'All statuses';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 3,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'PROJECT PORTFOLIO',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.primary.withValues(alpha: 0.9),
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Projects',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            height: 1.05,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Scan delivery health, compare progress, and jump into the right project faster.',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: [
            _ProjectsStatPill(
              label: 'Showing',
              value: '$visibleProjectsCount of $totalProjectsCount',
            ),
            _ProjectsStatPill(label: 'Filter', value: filterLabel),
          ],
        ),
      ],
    );
  }
}

class _ProjectsStatPill extends StatelessWidget {
  const _ProjectsStatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          children: [
            TextSpan(text: '$label  '),
            TextSpan(
              text: value,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectsSearchField extends StatelessWidget {
  const _ProjectsSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search by project name or location',
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppDimensions.sm,
            end: AppDimensions.xs,
          ),
          child: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: DesignTokens.shortAnimation,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.14)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedPadding(
            duration: DesignTokens.shortAnimation,
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? AppDimensions.md : 14,
              vertical: AppDimensions.sm,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: DesignTokens.shortAnimation,
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 8 : 0,
                    height: 8,
                    margin: EdgeInsets.only(right: isSelected ? 8 : 0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
