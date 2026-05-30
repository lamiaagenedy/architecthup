import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../projects/domain/entities/project_list_item.dart';
import '../providers/quality_api_provider.dart';
import '../widgets/score_dropdown_widget.dart';

class AcesChecklistScreen extends ConsumerWidget {
  const AcesChecklistScreen({
    required this.project,
    required this.serviceId,
    super.key,
  });

  final ProjectListItem project;
  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistAsync = ref.watch(checklistControllerProvider(serviceId));

    return Scaffold(
      appBar: AppBar(title: Text('Checklist • ${project.name}')),
      body: checklistAsync.when(
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.lg),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sm),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.itemNumber}. ${item.textEn}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      item.textAr,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    ScoreDropdownWidget(
                      value: item.score,
                      onChanged: (score) async {
                        if (score == null) return;
                        await ref
                            .read(checklistControllerProvider(serviceId).notifier)
                            .saveScore(item.id, score);
                      },
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Comment',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: item.comment ?? ''),
                      onSubmitted: (value) {
                        ref
                            .read(checklistControllerProvider(serviceId).notifier)
                            .saveComment(item.id, value);
                      },
                    ),
                  ],
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
