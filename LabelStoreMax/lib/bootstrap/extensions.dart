import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/themes/styles/color_styles.dart';
import 'package:nylo_framework/nylo_framework.dart';

extension NyText on Text {
  /// Sets the color from your [ColorStyles] or [Color].
  Text setColor(
      BuildContext context, Color Function(ColorStyles color) newColor,
      {String? themeId}) {
    return copyWith(
        style: TextStyle(
            color: newColor(ThemeColor.get(context, themeId: themeId))));
  }
}

/// Check if the [Product] is new.
extension DateTimeExtension on DateTime? {
  bool? isAfterOrEqualTo(DateTime dateTime) {
    final date = this;
    if (date != null) {
      final isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
      return isAtSameMomentAs | date.isAfter(dateTime);
    }
    return null;
  }

  bool? isBeforeOrEqualTo(DateTime dateTime) {
    final date = this;
    if (date != null) {
      final isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
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
      final isAfter = date.isAfterOrEqualTo(fromDateTime) ?? false;
      final isBefore = date.isBeforeOrEqualTo(toDateTime) ?? false;
      return isAfter && isBefore;
    }
    return null;
  }
}