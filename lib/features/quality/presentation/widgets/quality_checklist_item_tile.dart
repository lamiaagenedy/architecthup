import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../providers/inspection_checklist_provider.dart';
import 'rating_selector.dart';

class QualityChecklistItemTile extends StatelessWidget {
  const QualityChecklistItemTile({
    required this.itemNumber,
    required this.title,
    required this.itemState,
    required this.onRatingChanged,
    required this.onToggleComment,
    required this.onCommentChanged,
    super.key,
  });

  final int itemNumber;
  final String title;
  final InspectionItemState itemState;
  final ValueChanged<int?> onRatingChanged;
  final VoidCallback onToggleComment;
  final ValueChanged<String> onCommentChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$itemNumber. $title',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          RatingSelector(
            value: itemState.rating,
            onChanged: onRatingChanged,
            label: 'Rating',
          ),
          const SizedBox(height: AppDimensions.sm),
          TextButton.icon(
            onPressed: onToggleComment,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              itemState.isCommentExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
            ),
            label: Text(
              itemState.isCommentExpanded ? 'Hide comment' : 'Add comment',
            ),
          ),
          if (itemState.isCommentExpanded) ...[
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              initialValue: itemState.comment,
              minLines: 2,
              maxLines: 4,
              onChanged: onCommentChanged,
              decoration: const InputDecoration(
                hintText: 'Optional comment',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
