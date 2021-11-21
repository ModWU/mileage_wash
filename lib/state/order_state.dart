import 'dart:ui';
import 'package:flutter/material.dart';

@immutable
class OrderState {
  const OrderState._(this.index, {required this.httpCode});

  static OrderState findByHttpCode(int httpCode) {
    if (httpCode == OrderState.waiting.httpCode) {
      return OrderState.waiting;
    } else if (httpCode == OrderState.washing.httpCode) {
      return OrderState.washing;
    } else if (httpCode == OrderState.done.httpCode) {
      return OrderState.done;
    } else if (httpCode == OrderState.cancelled.httpCode) {
      return OrderState.cancelled;
    }

    throw 'Unsupported httpCode "$httpCode".';
  }

  final int index;
  final int httpCode;

  @override
  String toString() => 'OrderState(index: $index, httpCode: $httpCode)';

  @override
  int get hashCode {
    return hashValues(index, httpCode);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OrderState &&
        other.index == index &&
        other.httpCode == httpCode;
  }

  static const OrderState waiting = OrderState._(0, httpCode: 2);

  static const OrderState washing = OrderState._(1, httpCode: 3);

  static const OrderState done = OrderState._(2, httpCode: 4);

  static const OrderState cancelled = OrderState._(3, httpCode: 6);
}
