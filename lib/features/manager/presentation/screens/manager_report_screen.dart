import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../providers/manager_provider.dart';

class ManagerReportScreen extends ConsumerWidget {
  const ManagerReportScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(managerReportProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _downloadPdf(context, ref),
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          final services = (report['services'] as List? ?? []).cast<Map>();

          return ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              Text(report['project_name'] as String? ?? '', style: Theme.of(context).textTheme.headlineSmall),
              Text('Company: ${report['company_name'] ?? '—'}'),
              Text('Supervisor: ${report['inspector_name'] ?? '—'}'),
              Text('Grade: ${report['grade'] ?? '—'}'),
              Text('Progress: ${report['progress'] ?? 0}%'),
              const SizedBox(height: AppDimensions.lg),
              ...services.map((service) {
                final items = (service['items'] as List? ?? []).cast<Map>();
                return ExpansionTile(
                  title: Text('${service['name']} • ${service['grade']}'),
                  children: items
                      .map(
                        (item) => ListTile(
                          title: Text(item['text_en'] as String? ?? ''),
                          subtitle: Text(
                            '${item['text_ar'] ?? ''}\nScore: ${item['score'] ?? '—'} • ${item['comment'] ?? ''}',
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref) async {
    final bytes = await ref
        .read(managerRemoteDatasourceProvider)
        .downloadReportPdf(projectId);

    if (!context.mounted || bytes.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/aces-report-$projectId.pdf');
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved to ${file.path}')),
    );
  }
}
