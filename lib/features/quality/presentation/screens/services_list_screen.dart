import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../../../projects/domain/entities/project_list_item.dart';
import '../providers/quality_api_provider.dart';

class ServicesListScreen extends ConsumerWidget {
  const ServicesListScreen({required this.project, super.key});

  final ProjectListItem project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(projectServicesProvider(project.id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () => context.pop(),
        ),
        title: Text(project.name),
      ),
      body: servicesAsync.when(
        data: (services) => ListView.separated(
          padding: AppDimensions.screenPadding,
          itemCount: services.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.md),
          itemBuilder: (context, index) {
            final service = services[index];
            final accentColor = _serviceColor(service.rating);
            final icon = _serviceIcon(service.name);
            return AppCard(
              onTap: () => context.push(
                RouteNames.serviceChecklist(project.id, service.id),
                extra: project,
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 64,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  AppIconContainer(icon: icon, color: accentColor),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name, style: AppTextStyles.cardTitle),
                        const SizedBox(height: AppDimensions.xs),
                        Text(
                          'Completion ${service.progress}% • Rating ${(service.rating * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.secondary,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
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
}

IconData _serviceIcon(String name) {
  final normalized = name.toLowerCase();
  if (normalized.contains('house')) return Icons.cleaning_services_outlined;
  if (normalized.contains('pest')) return Icons.bug_report_outlined;
  if (normalized.contains('mep') || normalized.contains('electrical')) {
    return Icons.bolt_outlined;
  }
  return Icons.layers_outlined;
}

Color _serviceColor(num rating) {
  final score = (rating * 100).round();
  if (score >= 90) return AppColors.success;
  if (score >= 75) return AppColors.warning;
  return AppColors.danger;
}
