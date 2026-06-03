import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../app/di/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_grade_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/manager_provider.dart';

class ManagerProjectsScreen extends ConsumerStatefulWidget {
  const ManagerProjectsScreen({super.key});

  @override
  ConsumerState<ManagerProjectsScreen> createState() =>
      _ManagerProjectsScreenState();
}

class _ManagerProjectsScreenState extends ConsumerState<ManagerProjectsScreen> {
  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(managerProjectsApiProvider);
    final usersAsync = ref.watch(managerUsersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () => context.go(RouteNames.managerDashboard),
        ),
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(usersAsync.valueOrNull ?? []),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: projectsAsync.when(
        data: (projects) => ListView.separated(
          padding: AppDimensions.screenPadding,
          itemCount: projects.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sm),
          itemBuilder: (context, index) {
            final project = projects[index];
            final progress = _parseNum(project['progress']);
            final grade = project['grade']?.toString() ?? '—';
            final projectId = _parseInt(project['p_id']);

            return AppCard(
              onTap: () => context.push(RouteNames.managerReport('$projectId')),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project['name'] as String? ?? '',
                          style: AppTextStyles.cardTitle,
                        ),
                      ),
                      AppGradeBadge(label: grade, score: progress),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    project['company_name'] as String? ?? '',
                    style: AppTextStyles.secondary,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  LinearProgressIndicator(
                    value: (progress / 100).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.divider,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${project['supervisor_name'] ?? ''}',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: () =>
                            _reassign(project, usersAsync.valueOrNull ?? []),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => _flagReinspection('$projectId'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteProject('$projectId'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(authControllerProvider.notifier).logout();
    await ref.read(authLocalDatasourceProvider).clearSession();
    if (!context.mounted) return;
    context.go(RouteNames.login);
  }

  Future<void> _deleteProject(String projectId) async {
    await ref.read(managerRemoteDatasourceProvider).deleteProject(projectId);
    ref.invalidate(managerProjectsApiProvider);
  }

  Future<void> _flagReinspection(String projectId) async {
    await ref.read(managerRemoteDatasourceProvider).flagReinspection(projectId);
    ref.invalidate(managerProjectsApiProvider);
  }

  Future<void> _reassign(
    Map<String, dynamic> project,
    List<Map<String, dynamic>> users,
  ) async {
    int? selected = _parseNullableInt(project['u_id']);
    selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Reassign Supervisor'),
        children: users
            .map(
              (user) => SimpleDialogOption(
                onPressed: () =>
                    Navigator.pop(context, _parseInt(user['U_ID'])),
                child: Text(user['Name'] as String? ?? ''),
              ),
            )
            .toList(),
      ),
    );

    if (selected == null) return;
    final projectId = _parseInt(project['p_id']);

    await ref
        .read(managerRemoteDatasourceProvider)
        .assignProject(projectId: projectId, supervisorId: selected);
    ref.invalidate(managerProjectsApiProvider);
  }

  Future<void> _showCreateDialog(List<Map<String, dynamic>> users) async {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final companyController = TextEditingController();
    int? supervisorId = users.isNotEmpty
        ? _parseNullableInt(users.first['U_ID'])
        : null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(labelText: 'Company'),
              ),
              DropdownButtonFormField<int>(
                value: supervisorId,
                items: users
                    .map(
                      (user) => DropdownMenuItem<int>(
                        value: _parseInt(user['U_ID']),
                        child: Text(user['Name'] as String? ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (value) => supervisorId = value,
                decoration: const InputDecoration(labelText: 'Supervisor'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed != true || supervisorId == null || !mounted) return;

    await ref
        .read(managerRemoteDatasourceProvider)
        .createProject(
          name: nameController.text.trim(),
          location: locationController.text.trim(),
          companyName: companyController.text.trim(),
          supervisorId: supervisorId!,
        );
    ref.invalidate(managerProjectsApiProvider);
  }

  num _parseNum(dynamic value) {
    return num.tryParse(value?.toString() ?? '0') ?? 0;
  }

  int _parseInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString());
  }
}
