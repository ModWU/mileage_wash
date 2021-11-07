import 'package:flutter/material.dart';

@immutable
class CarState {
  const CarState._(this.value);

  final int value;

  @override
  String toString() => 'CarStatus(value: $value)';

  @override
  int get hashCode {
    return value.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CarState && other.value == value;
  }

  static const CarState carWell = CarState._(1);

  static const CarState hasScratch = CarState._(2);

  static const CarState hasCollision = CarState._(3);
}
