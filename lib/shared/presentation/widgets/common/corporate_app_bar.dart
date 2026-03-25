import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import 'app_logo.dart';

class CorporateAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CorporateAppBar({
    required this.title,
    super.key,
    this.isRoot = false,
    this.onBack,
  });

  final String title;
  final bool isRoot;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(DesignTokens.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      leading: isRoot
          ? const Padding(
              padding: EdgeInsetsDirectional.only(start: 16),
              child: Align(alignment: Alignment.centerLeft, child: AppLogo()),
            )
          : IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onPrimary,
              ),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
      leadingWidth: 64,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: isRoot
          ? const <Widget>[]
          : const [
              Padding(
                padding: EdgeInsetsDirectional.only(end: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AppLogo(),
                ),
              ),
            ],
    );
  }
}
