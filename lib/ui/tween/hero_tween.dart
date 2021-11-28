import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class OffsetRectCenterArcTween extends RectTween {
  /// Creates a [Tween] for animating [Rect]s along a circular arc.
  ///
  /// The [begin] and [end] properties must be non-null before the tween is
  /// first used, but the arguments can be null if the values are going to be
  /// filled in later.
  OffsetRectCenterArcTween({
    Rect? begin,
    Rect? end,
    this.widthOffset = 0,
    this.heightOffset = 0,
  }) : super(begin: begin, end: end);

  bool _dirty = true;
  final double widthOffset;
  final double heightOffset;

  void _initialize() {
    assert(begin != null);
    assert(end != null);
    _centerArc = MaterialPointArcTween(
      begin: begin!.center,
      end: end!.center,
    );
    _dirty = false;
  }

  /// If [begin] and [end] are non-null, returns a tween that interpolates along
  /// a circular arc between [begin]'s [Rect.center] and [end]'s [Rect.center].
  MaterialPointArcTween? get centerArc {
    if (begin == null || end == null) return null;
    if (_dirty) _initialize();
    return _centerArc;
  }

  late MaterialPointArcTween _centerArc;

  @override
  set begin(Rect? value) {
    if (value != begin) {
      super.begin = value;
      _dirty = true;
    }
  }

  @override
  set end(Rect? value) {
    if (value != end) {
      super.end = value;
      _dirty = true;
    }
  }

  @override
  Rect lerp(double t) {
    if (_dirty) _initialize();
    if (t == 0.0) return begin!;
    if (t == 1.0) return end!;

    final double beginWidth = max(0, begin!.width + widthOffset);
    final double beginHeight = max(0, begin!.height + heightOffset);

    final Offset center = _centerArc.lerp(t);
    final double width = lerpDouble(beginWidth, end!.width, t)!;
    final double height = lerpDouble(beginHeight, end!.height, t)!;
    return Rect.fromLTWH(
        center.dx - width / 2.0, center.dy - height / 2.0, width, height);
  }

  @override
  String toString() {
    return 'OffsetRectCenterArcTween($begin \u2192 $end; centerArc=$centerArc; widthOffset=$widthOffset, heightOffset=$heightOffset)';
  }
}

class SizeRectCenterArcTween extends RectTween {
  /// Creates a [Tween] for animating [Rect]s along a circular arc.
  ///
  /// The [begin] and [end] properties must be non-null before the tween is
  /// first used, but the arguments can be null if the values are going to be
  /// filled in later.
  SizeRectCenterArcTween({
    Rect? begin,
    Rect? end,
    double? width,
    double? height,
  })  : assert(width == null || width >= 0),
        assert(height == null || height >= 0),
        _width = width,
        _height = height,
        super(begin: begin, end: end);

  bool _dirty = true;
  final double? _width;
  final double? _height;

  void _initialize() {
    assert(begin != null);
    assert(end != null);
    _centerArc = MaterialPointArcTween(
      begin: begin!.center,
      end: end!.center,
    );
    _dirty = false;
  }

  /// If [begin] and [end] are non-null, returns a tween that interpolates along
  /// a circular arc between [begin]'s [Rect.center] and [end]'s [Rect.center].
  MaterialPointArcTween? get centerArc {
    if (begin == null || end == null) return null;
    if (_dirty) _initialize();
    return _centerArc;
  }

  late MaterialPointArcTween _centerArc;

  @override
  set begin(Rect? value) {
    if (value != begin) {
      super.begin = value;
      _dirty = true;
    }
  }

  @override
  set end(Rect? value) {
    if (value != end) {
      super.end = value;
      _dirty = true;
    }
  }

  @override
  Rect lerp(double t) {
    if (_dirty) _initialize();
    if (t == 0.0) return begin!;
    if (t == 1.0) return end!;

    final double beginWidth = _width ?? begin!.width;
    final double beginHeight = _height ?? begin!.height;

    final Offset center = _centerArc.lerp(t);
    final double width = lerpDouble(beginWidth, end!.width, t)!;
    final double height = lerpDouble(beginHeight, end!.height, t)!;
    return Rect.fromLTWH(
        center.dx - width / 2.0, center.dy - height / 2.0, width, height);
  }

  @override
  String toString() {
    return 'SizeRectCenterArcTween($begin \u2192 $end; centerArc=$centerArc; width=$_width, height=$_height)';
  }
}
