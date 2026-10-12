import 'package:flutter/material.dart';
import '/resources/themes/color_styles.dart';
import 'package:nylo_framework/nylo_framework.dart';

extension NyText on Text {
  /// Sets the color from your [ColorStyles] or [Color].
  Text setColor(
      BuildContext context, Color Function(ColorStyles color) newColor,
      {String? themeId}) {
    return copyWith(
        style: TextStyle(
            color: newColor(
                nyColorStyle<ColorStyles>(context, themeId: themeId))));
  }
}

/// Check if the [Product] is new.
extension DateTimeExtension on DateTime? {
  bool? isAfterOrEqualTo(DateTime dateTime) {
    final date = this;
    if (date != null) {
      final bool isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
      return isAtSameMomentAs | date.isAfter(dateTime);
    }
    return null;
  }

  bool? isBeforeOrEqualTo(DateTime dateTime) {
    final date = this;
    if (date != null) {
      final bool isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
      return isAtSameMomentAs | date.isBefore(dateTime);
    }
    return null;
  }

  bool? isBetween(
    DateTime fromDateTime,
    DateTime toDateTime,
  ) {
    final date = this;
    if (date != null) {
      final bool isAfter = date.isAfterOrEqualTo(fromDateTime) ?? false;
      final bool isBefore = date.isBeforeOrEqualTo(toDateTime) ?? false;
      return isAfter && isBefore;
    }
    return null;
  }
}

/// [BuildContext] Extensions
///
/// NOTE: named [NyColorStyles], not `NyApp` - an extension called `NyApp`
/// shadows Nylo v7's `NyApp` class and breaks `NyApp.materialApp`.
extension NyColorStyles on BuildContext {
  /// Get the current theme color
  ColorStyles get color => nyColorStyle<ColorStyles>(this);
}
