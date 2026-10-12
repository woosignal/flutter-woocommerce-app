import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class _SubmitFormHolder {
  (dynamic, Function(dynamic data))? submitForm;
  Function(dynamic error)? onFailure;
  _SubmitFormHolder({this.submitForm, this.onFailure});
}

/* StatefulAppButton
|--------------------------------------------------------------------------
| Base class for every button in the app. It wires the button up to Nylo's
| [ButtonState] so an async `onPressed` (or a `submitForm` tuple) locks the
| button and swaps it for [loadingStyle] until the future completes.
|
| Two documented deviations from the Nylo boilerplate:
|   1. [buildButton] receives the `pressed` callback. Label StoreMax's buttons
|      are real ElevatedButton/InkWell widgets so they keep Material's ripple
|      and disabled styling, and they must own the tap themselves. The base
|      only hands `pressed` to the partial when no animation/splash wrapper is
|      installed, because those wrappers add their own tap handler.
|   2. [height] is nullable. The primary/secondary/text buttons size themselves
|      from the screen width, exactly as the pre-v7 buttons did.
|-------------------------------------------------------------------------- */
abstract class StatefulAppButton extends StatelessWidget with FormSubmittable {
  final String text;
  final VoidCallback? onPressed;
  final _SubmitFormHolder _submitHolder;
  final bool showToastError;
  final LoadingStyle? loadingStyle;
  final double? width;
  final double? height;
  final ButtonAnimationStyle? animationStyle;
  final ButtonSplashStyle? splashStyle;

  (dynamic, Function(dynamic data))? get submitForm => _submitHolder.submitForm;
  Function(dynamic error)? get onFailure => _submitHolder.onFailure;

  StatefulAppButton({
    super.key,
    required this.text,
    this.onPressed,
    (dynamic, Function(dynamic data))? submitForm,
    Function(dynamic error)? onFailure,
    this.showToastError = true,
    this.loadingStyle,
    this.width,
    this.height,
    this.animationStyle,
    this.splashStyle,
  }) : _submitHolder =
            _SubmitFormHolder(submitForm: submitForm, onFailure: onFailure);

  @override
  Widget withSubmitForm(
    (dynamic, Function(dynamic data)) submitForm, {
    Function(dynamic error)? onFailure,
  }) {
    _submitHolder.submitForm = submitForm;
    if (onFailure != null) _submitHolder.onFailure = onFailure;
    return this;
  }

  /// Build the actual button widget.
  /// [pressed] is null when the button must not react to taps.
  Widget buildButton(BuildContext context, VoidCallback? pressed);

  /// Build the button as it looks while its action is running.
  /// Defaults to the button with its tap handler removed.
  Widget buildLoadingButton(BuildContext context) => buildButton(context, null);

  /// Make a purely visual button body respond to taps.
  /// Partials that already contain an ElevatedButton/InkWell do not need this.
  Widget tappable(VoidCallback? pressed, {required Widget child}) =>
      GestureDetector(
        onTap: pressed,
        behavior: HitTestBehavior.opaque,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return ButtonState(
      onSubmit: (onPressed, submitForm),
      onFailure: onFailure,
      showToastError: showToastError,
      loadingStyle: loadingStyle ??
          LoadingStyle.normal(child: Builder(builder: buildLoadingButton)),
      child: (VoidCallback? pressed) {
        final bool hasAnimation = animationStyle != null &&
            animationStyle!.type != ButtonAnimationType.none;
        final bool hasSplash =
            splashStyle != null && splashStyle!.type != ButtonSplashType.none;

        Widget result =
            buildButton(context, (hasAnimation || hasSplash) ? null : pressed);

        // Apply splash styling to the button
        if (hasSplash) {
          Widget inkWell = InkWell(
            // Only add tap handler if no animation (animation wrapper handles tap otherwise)
            onTap: hasAnimation ? null : pressed,
            borderRadius:
                splashStyle?.borderRadius ?? BorderRadius.circular(14),
            splashColor: splashStyle?.getSplashColor(
                context, Theme.of(context).colorScheme.onSurface),
            highlightColor: splashStyle?.getHighlightColor(
                context, Theme.of(context).colorScheme.onSurface),
            splashFactory: splashStyle?.splashFactory,
            overlayColor: splashStyle?.getOverlayColor(),
            child: result,
          );
          result = Material(
            color: Colors.transparent,
            child: height == null
                ? inkWell
                : SizedBox(height: height, child: inkWell),
          );
        }

        // Apply animation wrapper (includes splash if both are set)
        if (hasAnimation) {
          return AnimatedButtonWrapper(
            animationStyle: animationStyle!,
            onPressed: pressed,
            child: result,
          );
        }

        return result;
      },
    );
  }
}
