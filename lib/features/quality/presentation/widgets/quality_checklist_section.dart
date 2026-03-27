import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/quality_checklist_items.dart';
import '../providers/inspection_checklist_provider.dart';
import 'quality_checklist_item_tile.dart';

class QualityChecklistSection extends ConsumerWidget {
  const QualityChecklistSection({
    required this.projectId,
    required this.category,
    required this.items,
    super.key,
  });

  final String projectId;
  final InspectionCategoryKey category;
  final List<String> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionChecklistProvider(projectId));
    final notifier = ref.read(inspectionChecklistProvider(projectId).notifier);
    final categoryItems =
        state.entries[category] ?? const <InspectionItemState>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(items.length, (index) {
          final itemState = categoryItems[index];
          return QualityChecklistItemTile(
            itemNumber: index + 1,
            title: items[index],
            itemState: itemState,
            onRatingChanged: (next) {
              if (next == null) {
                final current = itemState.rating;
                if (current != null) {
                  notifier.toggleRating(category, index, current);
                }
                return;
              }

              notifier.toggleRating(category, index, next);
            },
            onToggleComment: () {
              notifier.toggleCommentExpanded(category, index);
            },
            onCommentChanged: (value) {
              notifier.updateComment(category, index, value);
            },
          );
        }),
      ],
    );
  }
}
