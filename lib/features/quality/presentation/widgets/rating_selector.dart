import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class RatingSelector extends StatelessWidget {
  const RatingSelector({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  static const List<int> _ratingScale = [50, 75, 80, 85, 90, 100];

  final int? value;
  final ValueChanged<int?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.cardTitle),
        const SizedBox(height: AppDimensions.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _ratingScale
                .map(
                  (score) => Padding(
                    padding: const EdgeInsets.only(right: AppDimensions.sm),
                    child: ChoiceChip(
                      label: Text('$score'),
                      selected: value == score,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.cardBackground,
                      shape: const StadiumBorder(
                        side: BorderSide(color: AppColors.divider),
                      ),
                      labelStyle: AppTextStyles.caption.copyWith(
                        color: value == score
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (_) {
                        final nextValue = value == score ? null : score;
                        onChanged(nextValue);
                      },
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}
