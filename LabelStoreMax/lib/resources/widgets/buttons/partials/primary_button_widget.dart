import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '/bootstrap/extensions.dart';
import '/resources/widgets/app_loader_widget.dart';
import '/resources/widgets/buttons/abstract/app_button.dart';

/// The store's main call to action.
/// Renders the same ElevatedButton the pre-v7 `PrimaryButton` did.
class PrimaryButton extends StatefulAppButton {
  final Color? backgroundColor;
  final Color? contentColor;

  PrimaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.submitForm,
    super.onFailure,
    super.showToastError = true,
    super.loadingStyle,
    super.width,
    super.height,
    super.animationStyle,
    super.splashStyle,
    this.backgroundColor,
    this.contentColor,
  });

  @override
  Widget buildButton(BuildContext context, VoidCallback? pressed) =>
      _build(context, pressed);

  @override
  Widget buildLoadingButton(BuildContext context) =>
      _build(context, null, isLoading: true);

  Widget _build(BuildContext context, VoidCallback? pressed,
      {bool isLoading = false}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: height ?? (screenWidth >= 385 ? 55 : 49),
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: backgroundColor ?? context.color.button.background,
          padding: EdgeInsets.all(8),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        onPressed: isLoading ? null : pressed,
        child: isLoading
            ? AppLoaderWidget()
            : AutoSizeText(
                text,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: contentColor ?? context.color.button.content),
                maxLines: (screenWidth >= 385 ? 2 : 1),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}
