import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../app/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_grade_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/manager_provider.dart';

class ManagerReportScreen extends ConsumerWidget {
  const ManagerReportScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(managerReportProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () => context.go(RouteNames.managerProjects),
        ),
        title: const Text('Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          final services = (report['services'] as List? ?? []).cast<Map>();
          final grade = report['grade']?.toString() ?? '—';
          final progress = (report['progress'] as num?) ?? 0;

          return ListView(
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
                            report['project_name'] as String? ?? '',
                            style: AppTextStyles.cardTitle,
                          ),
                        ),
                        AppGradeBadge(label: grade, score: progress),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      'Company: ${report['company_name'] ?? '—'}',
                      style: AppTextStyles.secondary,
                    ),
                    Text(
                      'Supervisor: ${report['inspector_name'] ?? '—'}',
                      style: AppTextStyles.secondary,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    LinearProgressIndicator(
                      value: (progress / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.divider,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSection),
              ...services.map((service) {
                final items = (service['items'] as List? ?? []).cast<Map>();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                  child: AppCard(
                    child: ExpansionTile(
                      title: Text(
                        '${service['name']} • ${service['grade'] ?? '—'}',
                        style: AppTextStyles.cardTitle,
                      ),
                      children: items
                          .map(
                            (item) => ListTile(
                              title: Text(
                                item['text_en'] as String? ?? '',
                                style: AppTextStyles.body,
                              ),
                              subtitle: Text(
                                '${item['text_ar'] ?? ''}\nScore: ${item['score'] ?? '—'} • ${item['comment'] ?? ''}',
                                style: AppTextStyles.secondary,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppDimensions.spacingSection),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: FilledButton.icon(
                  onPressed: () => _downloadPdf(context, ref),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Download PDF'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
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

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref) async {
    final bytes = await ref
        .read(managerRemoteDatasourceProvider)
        .downloadReportPdf(projectId);

    if (!context.mounted || bytes.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/aces-report-$projectId.pdf');
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF saved to ${file.path}')));
  }
}
