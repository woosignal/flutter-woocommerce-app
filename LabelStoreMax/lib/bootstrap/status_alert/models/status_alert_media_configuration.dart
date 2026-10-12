//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';

@immutable
abstract class PopupMediaConfiguration {
  const PopupMediaConfiguration();
}

@immutable
class FlareConfiguration extends PopupMediaConfiguration {
  /// Name of the Flare file to be loaded from the AssetBundle.
  final String filename;

  /// The name of the artboard to display.
  final String? artboard;

  /// The name of the animation to play.
  final String? animation;

  /// When true, the animation will be applied at the end of its duration.
  final bool snapToEnd;

  /// The BoxFit strategy used to scale the Flare content into the
  /// bounds of this widget.
  final BoxFit fit;

  /// The alignment that will be applied in conjuction to the [fit] to align
  /// the Flare content within the bounds of this widget.
  final Alignment alignment;

  /// When true, animations do not advance.
  final bool isPaused;

  /// When true, the Flare content will be clipped against the bounds of this
  /// widget.
  final bool shouldClip;

  // /// The [FlareController] used to drive animations/mixing/procedural hierarchy
  // /// manipulation of the Flare contents.
  // final FlareController? controller;
  //
  // /// Callback invoked when [animation] has completed. If [animation] is looping
  // /// this callback is never invoked.
  // final FlareCompletedCallback? callback;

  /// The color to override any fills/strokes with.
  final Color? color;

  /// The name of the node to use to determine the bounds of the content.
  /// When null it will default to the bounds of the artboard.
  final String? boundsNode;

  /// When true the intrinsic size of the artboard will be used as the
  /// dimensions of this widget.
  final bool sizeFromArtboard;

  /// Margin for [FlareActor]
  final EdgeInsets margin;

  /// Size of animated [FlareActor]
  final Size size;

  const FlareConfiguration(
    this.filename, {
    this.boundsNode,
    this.animation,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.isPaused = false,
    this.snapToEnd = false,
    // this.controller,
    // this.callback,
    this.color,
    this.shouldClip = true,
    this.sizeFromArtboard = false,
    this.artboard,
    this.margin = const EdgeInsets.all(24.0),
    this.size = const Size(150, 150),
  });
}

@immutable
class IconConfiguration extends PopupMediaConfiguration {
  /// Key
  final Key? key;

  /// The icon to display.
  final IconData icon;

  /// The size of the icon in logical pixels.
  final double? size;

  /// The color to use when drawing the icon.
  final Color? color;

  /// Semantic label for the icon.
  final String? semanticLabel;

  /// The text direction to use for rendering the icon.
  final TextDirection? textDirection;

  /// Margin for [Icon]
  final EdgeInsets margin;

  const IconConfiguration({
    this.key,
    this.margin = const EdgeInsets.all(0.0),
    this.size,
    this.icon = Icons.done,
    this.color,
    this.semanticLabel,
    this.textDirection,
  });
}

@immutable
class ImageConfiguration extends PopupMediaConfiguration {
  const ImageConfiguration();
}

@immutable
class WidgetConfiguration extends PopupMediaConfiguration {
  /// The widget to be displayed.
  /// All in your hands!!!
  ///
  /// _____＼＿ﾍ(︶ω︶)
  ///
  final Widget widget;

  const WidgetConfiguration({
    required this.widget,
  });
}
