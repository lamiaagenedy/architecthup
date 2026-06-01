import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
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
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$itemNumber. $title',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle.copyWith(height: 1.35),
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
              foregroundColor: AppColors.textSecondary,
            ),
            icon: Icon(
              itemState.isCommentExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
            ),
            label: Text(
              itemState.isCommentExpanded ? 'Hide comment' : 'Add comment',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.secondary,
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
