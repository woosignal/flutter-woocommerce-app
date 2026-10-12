//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';

class StatusAlertTextConfiguration {
  /// The text to display as a [InlineSpan].
  InlineSpan? textSpan;

  /// If non-null, the style to use for this text.
  TextStyle style;

  /// {@macro flutter.painting.textPainter.strutStyle}
  StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  TextAlign textAlign;

  /// The directionality of the text.
  TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  Locale? locale;

  /// Whether the text should break at soft line breaks.
  bool? softWrap;

  /// How visual overflow should be handled.
  TextOverflow? overflow;

  /// The number of font pixels for each logical pixel.
  double? textScaleFactor;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  int? maxLines;

  /// An alternative semantics label for this text.
  String? semanticsLabel;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  TextWidthBasis? textWidthBasis;

  /// Key
  Key? key;

  StatusAlertTextConfiguration({
    this.textSpan,
    this.key,
    this.style = const TextStyle(fontFamily: 'SFNS'),
    this.strutStyle,
    this.textAlign = TextAlign.center,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
  });
}
