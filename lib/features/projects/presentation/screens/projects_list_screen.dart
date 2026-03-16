import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final filteredProjectsAsync = ref.watch(filteredProjectsProvider);
    final selectedStatus = ref.watch(projectsStatusFilterProvider);

    return filteredProjectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return _ProjectsScaffold(
            searchController: _searchController,
            selectedStatus: selectedStatus,
            onSearchChanged: _handleSearchChanged,
            onStatusSelected: _handleStatusSelected,
            onRefresh: _refreshProjects,
            child: const ProjectsEmptyView(),
          );
        }

        return _ProjectsScaffold(
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

              return ProjectListItemCard(project: project, onTap: () {});
            },
          ),
        );
      },
      loading: () => _ProjectsScaffold(
        searchController: _searchController,
        selectedStatus: selectedStatus,
        onSearchChanged: _handleSearchChanged,
        onStatusSelected: _handleStatusSelected,
        onRefresh: _refreshProjects,
        child: const ProjectsLoadingView(),
      ),
      error: (error, stackTrace) => _ProjectsScaffold(
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
    required this.searchController,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onStatusSelected,
    required this.onRefresh,
    required this.child,
  });

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
            const _ProjectsHeader(),
            const SizedBox(height: AppDimensions.lg),
            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                labelText: 'Search projects',
                hintText: 'Search by name or location',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            SizedBox(
              height: 38,
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
  const _ProjectsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projects',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Track active jobs, scan status quickly, and prepare for deeper project review.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.7)
          : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
