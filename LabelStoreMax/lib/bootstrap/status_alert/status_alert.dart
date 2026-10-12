//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/bootstrap/status_alert/utils/status_allert_manager.dart';
import '/bootstrap/status_alert/widgets/status_alert_base_widget.dart';
import 'models/status_alert_media_configuration.dart';
import 'models/status_alert_text_configuration.dart';

class StatusAlert {
  static void show(
    BuildContext context, {
    String? title,
    String? subtitle,
    Color? backgroundColor,
    double blurPower = 15,
    double? maxWidth,
    StatusAlertTextConfiguration? titleOptions,
    StatusAlertTextConfiguration? subtitleOptions,
    PopupMediaConfiguration? configuration,
    Alignment alignment = Alignment.center,
    bool dismissOnBackgroundTap = false,
    EdgeInsets margin = const EdgeInsets.all(40.0),
    EdgeInsets padding = const EdgeInsets.all(30.0),
    Duration duration = const Duration(milliseconds: 1300),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(10.0)),
  }) {
    StatusAlertTextConfiguration? titleConfig = titleOptions;
    StatusAlertTextConfiguration? subtitleConfig = subtitleOptions;
    if (titleConfig == null) {
      titleConfig = StatusAlertTextConfiguration();
      titleConfig.style = titleConfig.style.copyWith(
        fontSize: 23,
        fontWeight: FontWeight.w600,
      );
    }

    if (subtitleConfig == null) {
      subtitleConfig = StatusAlertTextConfiguration();
      subtitleConfig.style = subtitleConfig.style.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );
    }

    StatusAlertManager.createView(
      context: context,
      dismissOnBackgroundTap: dismissOnBackgroundTap,
      child: StatusAlertBaseWidget(
        title: title,
        margin: margin,
        padding: padding,
        duration: duration,
        subtitle: subtitle,
        alignment: alignment,
        blurPower: blurPower,
        maxWidth: maxWidth,
        borderRadius: borderRadius,
        titleOptions: titleConfig,
        onHide: StatusAlertManager.dismiss,
        configuration: configuration,
        subtitleOptions: subtitleConfig,
        backgroundColor: backgroundColor,
      ),
    );
  }

  static void hide() => StatusAlertManager.dismiss();

  static bool get isVisible => StatusAlertManager.isVisible;
}
