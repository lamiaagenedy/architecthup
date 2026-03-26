import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<AppBottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.sm,
              AppDimensions.md,
              AppDimensions.sm,
            ),
            child: Row(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  Expanded(
                    flex: index == currentIndex ? 2 : 1,
                    child: _NavigationItemButton(
                      item: items[index],
                      isSelected: index == currentIndex,
                      onTap: () => onTap(index),
                    ),
                  ),
                  if (index != items.length - 1)
                    const SizedBox(width: AppDimensions.xs),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppBottomNavigationItem {
  const AppBottomNavigationItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _NavigationItemButton extends StatelessWidget {
  const _NavigationItemButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppBottomNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.xs,
                vertical: AppDimensions.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 42 : 34,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor.withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: isSelected ? 0.92 : 1,
                        end: isSelected ? 1.08 : 1,
                      ),
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Icon(
                        item.icon,
                        size: 22,
                        color: isSelected ? selectedColor : unselectedColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    style:
                        Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected ? selectedColor : unselectedColor,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          letterSpacing: 0.1,
                        ) ??
                        TextStyle(
                          color: isSelected ? selectedColor : unselectedColor,
                        ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isSelected ? 1 : 0.78,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 18 : 6,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor
                          : selectedColor.withValues(alpha: 0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
