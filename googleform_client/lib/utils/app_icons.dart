import 'package:flutter/material.dart';

/// Shared Material Symbols variation defaults for the whole app.
abstract final class AppIcons {
  static const double fill = 0;
  static const double weight = 500;

  static const IconThemeData theme = IconThemeData(
    fill: fill,
    weight: weight,
    opticalSize: 24,
  );

  static Widget icon(IconData icon, {double? size, Color? color}) {
    return Icon(icon, size: size, color: color, fill: fill, weight: weight);
  }
}
