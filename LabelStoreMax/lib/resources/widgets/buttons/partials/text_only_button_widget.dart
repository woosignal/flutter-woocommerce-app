import 'package:flutter/material.dart';
import '/resources/widgets/buttons/abstract/app_button.dart';

/// A flat, borderless action - "Cancel", "Back to Home", the sort options.
/// Renders the same InkWell the pre-v7 `LinkButton` did.
/// Set [selected] to draw the label in bold.
class TextOnlyButton extends StatefulAppButton {
  final Color? contentColor;
  final bool? selected;

  TextOnlyButton({
    super.key,
    required super.text,
    super.onPressed,
    super.submitForm,
    super.onFailure,
    super.showToastError = true,
    super.loadingStyle,
    super.animationStyle,
    super.splashStyle,
    this.contentColor,
    this.selected,
    super.width,
    super.height,
  });

  @override
  Widget buildButton(BuildContext context, VoidCallback? pressed) {
    final double screenWidth = MediaQuery.of(context).size.width;
    TextStyle? textStyle = selected == true
        ? Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodyLarge;
    if (contentColor != null) {
      textStyle = textStyle?.copyWith(color: contentColor);
    }
    return InkWell(
      onTap: pressed,
      child: Container(
        height: height ?? (screenWidth >= 385 ? 55 : 49),
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Center(
            child: Text(
          text,
          textAlign: TextAlign.center,
          style: textStyle,
        )),
      ),
    );
  }
}
