import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/constants/app_dimensions.dart';
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
      appBar: AppBar(title: const Text('All Projects')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(usersAsync.valueOrNull ?? []),
        child: const Icon(Icons.add),
      ),
      body: projectsAsync.when(
        data: (projects) => ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.lg),
          itemCount: projects.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final project = projects[index];
            return ListTile(
              title: Text(project['name'] as String? ?? ''),
              subtitle: Text(
                '${project['company_name']} • ${project['supervisor_name']} • ${project['progress']}% • ${project['grade']}',
              ),
              onTap: () => context.push(
                RouteNames.managerReport('${project['p_id']}'),
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () => _reassign(project, usersAsync.valueOrNull ?? []),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _flagReinspection('${project['p_id']}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteProject('${project['p_id']}'),
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
    int? selected = project['u_id'] as int?;
    selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Reassign Supervisor'),
        children: users
            .map(
              (user) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, user['U_ID'] as int),
                child: Text(user['Name'] as String? ?? ''),
              ),
            )
            .toList(),
      ),
    );

    if (selected == null) return;

    await ref.read(managerRemoteDatasourceProvider).assignProject(
      projectId: project['p_id'] as int,
      supervisorId: selected,
    );
    ref.invalidate(managerProjectsApiProvider);
  }

  Future<void> _showCreateDialog(List<Map<String, dynamic>> users) async {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final companyController = TextEditingController();
    int? supervisorId = users.isNotEmpty ? users.first['U_ID'] as int? : null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
              TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company')),
              DropdownButtonFormField<int>(
                value: supervisorId,
                items: users
                    .map(
                      (user) => DropdownMenuItem<int>(
                        value: user['U_ID'] as int,
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );

    if (confirmed != true || supervisorId == null || !mounted) return;

    await ref.read(managerRemoteDatasourceProvider).createProject(
      name: nameController.text.trim(),
      location: locationController.text.trim(),
      companyName: companyController.text.trim(),
      supervisorId: supervisorId!,
    );
    ref.invalidate(managerProjectsApiProvider);
  }
}
