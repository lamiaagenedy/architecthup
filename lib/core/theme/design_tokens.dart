import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

abstract final class DesignTokens {
  static const Color seedColor = AppColors.primary;
  static const double cardRadius = AppDimensions.radiusCard;
  static const double screenRadius = 28;
  static const double inputRadius = AppDimensions.inputRadius;
  static const double buttonRadius = AppDimensions.radiusButton;
  static const double shellHeaderHeight = 168;
  static const double shellHeaderCurveDepth = 26;
  static const double shellHeaderHorizontalPadding = AppDimensions.lg;
  static const double shellHeaderTopSpacing = AppDimensions.sm;
  static const double shellHeaderBottomSpacing = 20;
  static const double pageMaxWidth = 1200;
  static const double authCardMaxWidth = 440;
  static const EdgeInsets pagePadding = AppDimensions.screenPadding;
  static const EdgeInsets screenPadding = AppDimensions.screenPadding;
  static const EdgeInsets cardPadding = AppDimensions.cardPadding;
  static const double appBarHeight = AppDimensions.appBarHeight;
  static const Duration shortAnimation = Duration(milliseconds: 180);
  static const Duration mediumAnimation = Duration(milliseconds: 280);
}
