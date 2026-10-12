import '/resources/widgets/buttons/partials/transparency_button_widget.dart';
import '/resources/widgets/buttons/partials/secondary_button_widget.dart';
import '/resources/widgets/buttons/partials/primary_button_widget.dart';
import '/resources/widgets/buttons/partials/text_only_button_widget.dart';
import '/resources/widgets/buttons/partials/gradient_button_widget.dart';
import '/resources/widgets/buttons/partials/rounded_button_widget.dart';
import '/resources/widgets/buttons/partials/outlined_button_widget.dart' as app;
import '/resources/widgets/buttons/partials/icon_button_widget.dart' as app;
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
export 'package:nylo_framework/nylo_framework.dart'
    show ButtonAnimationStyle, ButtonSplashStyle, ButtonSplashType;

/* Buttons
|--------------------------------------------------------------------------
| Button.primary / Button.secondary / Button.textOnly reproduce the store's
| original PrimaryButton / SecondaryButton / LinkButton. They size themselves
| from the screen width, so no `height` is passed by default.
| An async `onPressed` (or a `submitForm` tuple) locks the button and shows the
| AppLoaderWidget inside it until the future completes.
| https://nylo.dev/docs/7.x/button
|-------------------------------------------------------------------------- */

/// Default button height for the boilerplate button styles
final double _buttonHeight = 52.0;

class Button {
  /// Primary button
  static Widget primary({
    required String text,
    VoidCallback? onPressed,
    (dynamic, Function(dynamic data))? submitForm,
    Function(dynamic error)? onFailure,
    bool showToastError = true,
    Color? color,
    Color? textColor,
    LoadingStyle? loadingStyle,
    double? width,
    double? height,
  }) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      submitForm: submitForm,
      onFailure: onFailure,
      showToastError: showToastError,
      loadingStyle: loadingStyle,
      backgroundColor: color,
      contentColor: textColor,
      width: width,
      height: height,
    );
  }

  /// Secondary button
  static Widget secondary({
    required String text,
    VoidCallback? onPressed,
    (dynamic, Function(dynamic data))? submitForm,
    Function(dynamic error)? onFailure,
    bool showToastError = true,
    Color? color,
    Color? textColor,
    LoadingStyle? loadingStyle,
    double? width,
    double? height,
  }) {
    return SecondaryButton(
      text: text,
      onPressed: onPressed,
      submitForm: submitForm,
      onFailure: onFailure,
      showToastError: showToastError,
      loadingStyle: loadingStyle,
      backgroundColor: color,
      contentColor: textColor,
      width: width,
      height: height,
    );
  }

  /// Text only button - the store's "link" button
  static Widget textOnly({
    required String text,
    VoidCallback? onPressed,
    (dynamic, Function(dynamic data))? submitForm,
    Function(dynamic error)? onFailure,
    bool showToastError = true,
    Color? textColor,
    bool? selected,
    LoadingStyle? loadingStyle,
    double? width,
    double? height,
  }) {
    return TextOnlyButton(
      text: text,
      onPressed: onPressed,
      submitForm: submitForm,
      onFailure: onFailure,
      showToastError: showToastError,
      loadingStyle: loadingStyle,
      contentColor: textColor,
      selected: selected,
      width: width,
      height: height,
    );
  }

  /// Outlined button
  static Widget outlined({
    required String text,
    VoidCallback? onPressed,
    (dynamic, Function(dynamic data))? submitForm,
    Function(dynamic error)? onFailure,
    bool showToastError = true,
    Color? borderColor,
    Color? textColor,
    double? width,
  }) {
    return app.OutlinedButton(
      text: text,
      onPressed: onPressed,
      submitForm: submitForm,
      onFailure: onFailure,
      showToastError: showToastError,
      loadingStyle: LoadingStyle.skeletonizer(),
      borderColor: borderColor,
      textColor: textColor,
      width: width,
      height: _buttonHeight,
      animationStyle: ButtonAnimationStyle.clickable(),
      splashStyle: ButtonSplashStyle.highlight(),
    );
  }

  /// Icon button
  static Widget icon({
    required String text,
    VoidCallback? onPressed,
    (dynamic, Function(dynamic data))? submitForm,
    Function(dynamic error)? onFailure,
    bool showToastError = true,
    required Widget icon,
    Color? color,
    double? width,
  }) {
    return app.IconButton(
      text: text,
      onPressed: onPressed,
      submitForm: submitForm,
      onFailure: onFailure,
      showToastError: showToastError,
      loadingStyle: LoadingStyle.skeletonizer(),
      icon: icon,
      backgroundColor: color,
      width: width,
      height: _buttonHeight,
      animationStyle: ButtonAnimationStyle.clickable(),
      splashStyle: ButtonSplashStyle.highlight(),
    );
  }

  /// Gradient button
  static Widget gradient({
    required String text,
    VoidCallback? onPressed,
    (dynamic, Function(dynamic data))? submitForm,
    Function(dynamic error)? onFailure,
    bool showToastError = true,
    List<Color>? gradientColors,
    double? width,
  }) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      submitForm: submitForm,
      onFailure: onFailure,
      showToastError: showToastError,
      loadingStyle: LoadingStyle.skeletonizer(),
      gradientColors: gradientColors,
      width: width,
      height: _buttonHeight,
      animationStyle: ButtonAnimationStyle.clickable(),
      splashStyle: ButtonSplashStyle.highlight(),
    );
  }

  /// Rounded button
  static Widget rounded({
    required String text,
    VoidCallback? onPressed,
    (dynamic, Function(dynamic data))? submitForm,
    Function(dynamic error)? onFailure,
    bool showToastError = true,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    double? width,
  }) {
    return RoundedButton(
      text: text,
      onPressed: onPressed,
      submitForm: submitForm,
      onFailure: onFailure,
      showToastError: showToastError,
      loadingStyle: LoadingStyle.skeletonizer(),
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      width: width,
      height: _buttonHeight,
      animationStyle: ButtonAnimationStyle.clickable(),
      splashStyle: ButtonSplashStyle.highlight(),
    );
  }

  /// Transparency button
  static Widget transparency({
    required String text,
    VoidCallback? onPressed,
    (dynamic, Function(dynamic data))? submitForm,
    Function(dynamic error)? onFailure,
    bool showToastError = true,
    Color? color,
    double? width,
  }) {
    return TransparencyButton(
      text: text,
      onPressed: onPressed,
      submitForm: submitForm,
      onFailure: onFailure,
      showToastError: showToastError,
      loadingStyle: LoadingStyle.skeletonizer(),
      contentColor: color,
      width: width,
      height: _buttonHeight,
      animationStyle: ButtonAnimationStyle.clickable(),
      splashStyle: ButtonSplashStyle.highlight(),
    );
  }
}
