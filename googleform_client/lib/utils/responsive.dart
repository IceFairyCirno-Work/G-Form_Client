import 'package:flutter/material.dart';

/// Shared responsive layout helpers for adapting UI across phone and tablet sizes.
class Responsive {
  Responsive._();

  static const double smallScreenBreakpoint = 360;
  static const double tabletBreakpoint = 600;

  /// True when logical width is below [smallScreenBreakpoint].
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width < smallScreenBreakpoint;
  }

  /// True when the shortest side is at least [tabletBreakpoint] (tablet / large layout).
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;
  }

  /// True when the device is in landscape orientation.
  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Grid column count based on available width and minimum item width.
  static int getAdaptiveGridCount(
    BuildContext context, {
    double minItemWidth = 160,
    int minColumns = 2,
    int maxColumns = 4,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final count = (screenWidth / minItemWidth).floor();
    return count.clamp(minColumns, maxColumns);
  }

  /// Question-type picker columns: 2 on narrow screens, 3 otherwise.
  static int getQuestionTypeGridCount(BuildContext context) {
    return isSmallScreen(context) ? 2 : 3;
  }

  /// Vertical spacer height for centered layouts (e.g. login screen).
  static double getLandscapeAwareSpacer(
    BuildContext context, {
    double portrait = 60,
    double landscape = 20,
  }) {
    return isLandscape(context) ? landscape : portrait;
  }

  /// Pie chart diameter as a fraction of parent width, clamped to sensible bounds.
  static double getPieChartSize(double maxWidth) {
    return (maxWidth * 0.35).clamp(100.0, 160.0);
  }
}
