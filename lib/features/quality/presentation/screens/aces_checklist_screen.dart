import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../projects/domain/entities/project_list_item.dart';
import '../providers/quality_api_provider.dart';
import '../widgets/rating_selector.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Checklist • ${project.name}'),
      ),
      body: checklistAsync.when(
        data: (items) {
          final completed = items.where((item) => item.score != null).length;
          final progress = items.isEmpty ? 0.0 : completed / items.length;

          return Stack(
            children: [
              ListView.separated(
                padding: AppDimensions.screenPadding.copyWith(
                  bottom: AppDimensions.spacingSection * 2,
                ),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.sm),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final borderColor = _scoreColor(item.score);

                  return AppCard(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: borderColor, width: 4),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: AppDimensions.xs,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _ItemNumberCircle(number: item.itemNumber),
                                const SizedBox(width: AppDimensions.sm),
                                Expanded(
                                  child: Text(
                                    item.textAr,
                                    textDirection: TextDirection.rtl,
                                    style: AppTextStyles.cardTitle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.xs),
                            Text(item.textEn, style: AppTextStyles.secondary),
                            const SizedBox(height: AppDimensions.sm),
                            RatingSelector(
                              value: item.score,
                              label: 'Score',
                              onChanged: (score) async {
                                if (score == null) return;
                                await ref
                                    .read(
                                      checklistControllerProvider(
                                        serviceId,
                                      ).notifier,
                                    )
                                    .saveScore(item.id, score);
                              },
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Comment',
                              ),
                              controller: TextEditingController(
                                text: item.comment ?? '',
                              ),
                              onSubmitted: (value) {
                                ref
                                    .read(
                                      checklistControllerProvider(
                                        serviceId,
                                      ).notifier,
                                    )
                                    .saveComment(item.id, value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.lg,
                    AppDimensions.sm,
                    AppDimensions.lg,
                    AppDimensions.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completion ${(progress * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.divider,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
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
}

class _ItemNumberCircle extends StatelessWidget {
  const _ItemNumberCircle({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
      ),
    );
  }
}

Color _scoreColor(int? score) {
  if (score == null) return AppColors.divider;
  if (score >= 90) return AppColors.success;
  if (score >= 75) return AppColors.warning;
  return AppColors.danger;
}
