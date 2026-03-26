import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
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
                      selectedColor: colorScheme.primary,
                      labelStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(
                            color: value == score
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
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
