import 'package:flutter/widgets.dart';

import '../../../../shared/presentation/widgets/common/feature_placeholder_screen.dart';

class LandscapeScreen extends StatelessWidget {
  const LandscapeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Landscape',
      description:
          'Landscape is reserved as its own feature module for later implementation.',
    );
  }
}
