import 'package:mileage_wash/server/state/state.dart';

class OrderState extends AbsStateWithIndex<int> {
  const OrderState._(int value, int index) : super(value, index: index);

  static const OrderState waiting = OrderState._(2, 0);

  static const OrderState washing = OrderState._(3, 1);

  static const OrderState done = OrderState._(4, 2);

  static const OrderState cancelled = OrderState._(6, 3);
}
