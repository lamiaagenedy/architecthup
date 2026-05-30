import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../projects/domain/entities/project_list_item.dart';
import '../providers/quality_api_provider.dart';

class ServicesListScreen extends ConsumerWidget {
  const ServicesListScreen({required this.project, super.key});

  final ProjectListItem project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(projectServicesProvider(project.id));

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: servicesAsync.when(
        data: (services) => ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.lg),
          itemCount: services.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.md),
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              child: ListTile(
                title: Text(service.name),
                subtitle: Text(
                  'Progress: ${service.progress}% • Rating: ${(service.rating * 100).toStringAsFixed(0)}%',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  RouteNames.serviceChecklist(project.id, service.id),
                  extra: project,
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
