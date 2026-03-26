import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

abstract final class DesignTokens {
  static const Color seedColor = AppColors.seed;
  static const double cardRadius = 20;
  static const double screenRadius = 28;
  static const double inputRadius = 18;
  static const double buttonRadius = 18;
  static const double shellHeaderHeight = 168;
  static const double shellHeaderCurveDepth = 26;
  static const double shellHeaderHorizontalPadding = AppDimensions.lg;
  static const double shellHeaderTopSpacing = AppDimensions.sm;
  static const double shellHeaderBottomSpacing = 20;
  static const double pageMaxWidth = 1200;
  static const double authCardMaxWidth = 440;
  static const EdgeInsets pagePadding = EdgeInsets.all(AppDimensions.lg);
  static const EdgeInsets screenPadding = EdgeInsets.all(AppDimensions.lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(AppDimensions.lg);
  static const double appBarHeight = 64;
  static const Duration shortAnimation = Duration(milliseconds: 180);
  static const Duration mediumAnimation = Duration(milliseconds: 280);
}
