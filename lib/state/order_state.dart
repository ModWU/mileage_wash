import 'dart:ui';

class OrderState {
  const OrderState._(this.index, {required this.httpRequestCode});

  final int index;
  final int httpRequestCode;

  @override
  String toString() =>
      'OrderState(index: $index, httpRequestCode: $httpRequestCode)';

  @override
  int get hashCode {
    return hashValues(index, httpRequestCode);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OrderState &&
        other.index == index &&
        other.httpRequestCode == httpRequestCode;
  }

  static const OrderState waiting = OrderState._(0, httpRequestCode: 2);

  static const OrderState washing = OrderState._(1, httpRequestCode: 3);

  static const OrderState done = OrderState._(2, httpRequestCode: 4);

  static const OrderState cancelled = OrderState._(3, httpRequestCode: 6);
}
