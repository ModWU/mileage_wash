import 'package:flutter/material.dart';

@immutable
abstract class AbsStateWithIndex<T> {
  const AbsStateWithIndex(this.value, {required this.index});
  final T value;
  final int index;

  @override
  String toString() => value.toString();

  @override
  int get hashCode {
    return hashValues(value, index);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is AbsStateWithIndex<T> &&
        other.value == value &&
        other.index == index;
  }
}

@immutable
abstract class AbsState<T> {
  const AbsState(this.value);
  final T value;

  @override
  String toString() => value.toString();

  @override
  int get hashCode {
    return value.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is AbsState<T> && other.value == value;
  }
}
