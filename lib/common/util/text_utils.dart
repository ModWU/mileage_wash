import 'dart:ui';

import 'package:flutter/material.dart';

class TextUtils {
  TextUtils._();

  static Size measureSize(
    TextSpan textSpan, {
    double maxWidth = double.infinity,
    double minWidth = 0.0,
    TextDirection textDirection = TextDirection.ltr,
    double textScaleFactor = 1.0,
    int? maxLines,
    String? ellipsis,
    Locale? locale,
    StrutStyle? strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    TextHeightBehavior? textHeightBehavior,
    TextAlign textAlign = TextAlign.start,
  }) {
    final TextPainter textPainter = TextPainter(
        text: textSpan,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor,
        maxLines: maxLines,
        ellipsis: ellipsis,
        locale: locale,
        strutStyle: strutStyle,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        textAlign: textAlign)
      ..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.size;
  }
}
