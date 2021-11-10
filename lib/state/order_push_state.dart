import 'package:flutter/material.dart';

@immutable
class OrderPushState {
  factory OrderPushState(String value) {
    if (value == OrderPushState.add.value) {
      return add;
    } else if (value == OrderPushState.cancel.value) {
      return cancel;
    }
    throw 'OrderPushState Type value[$value] error';
  }

  const OrderPushState._(this.value);

  final String value;

  @override
  String toString() => 'OrderPushState(value: $value)';

  @override
  int get hashCode {
    return value.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OrderPushState && other.value == value;
  }

  static const OrderPushState add = OrderPushState._('2');

  static const OrderPushState cancel = OrderPushState._('6');
}
