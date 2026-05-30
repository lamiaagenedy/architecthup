import 'package:flutter/material.dart';

class ScoreDropdownWidget extends StatelessWidget {
  const ScoreDropdownWidget({
    required this.value,
    required this.onChanged,
    super.key,
  });

  static const scores = [50, 75, 80, 85, 90, 100];

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Score',
        border: OutlineInputBorder(),
      ),
      items: scores
          .map(
            (score) => DropdownMenuItem<int>(
              value: score,
              child: Text('$score'),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
