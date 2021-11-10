import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mileage_wash/state/order_push_state.dart';

@immutable
class NotificationOrderInfo implements Comparable<NotificationOrderInfo> {
  const NotificationOrderInfo({
    required this.orderNumber,
    required this.carAddress,
    required this.carNumber,
    required this.appointmentTime,
    required this.orderPushState,
  });

  factory NotificationOrderInfo.fromJson(Map<String, dynamic> data) {
    assert(data.containsKey('appointmentTime'));
    assert(data.containsKey('carAddress'));
    assert(data.containsKey('carNumber'));
    assert(data.containsKey('orderNumber'));
    assert(data.containsKey('orderState'));

    final String appointmentTime = data['appointmentTime']! as String;
    final String carAddress = data['carAddress']! as String;
    final String carNumber = data['carNumber']! as String;
    final String orderNumber = data['orderNumber']! as String;
    final String orderState = data['orderState']! as String;

    return NotificationOrderInfo(
      appointmentTime: DateTime.parse(appointmentTime),
      carAddress: carAddress,
      carNumber: carNumber,
      orderNumber: orderNumber,
      orderPushState: OrderPushState(orderState),
    );
  }

  final String orderNumber;
  final String carAddress;
  final String carNumber;
  final OrderPushState orderPushState;
  final DateTime appointmentTime;

  @override
  int get hashCode {
    return hashValues(
        orderNumber, carAddress, carNumber, appointmentTime, orderPushState);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is NotificationOrderInfo &&
        other.orderNumber == orderNumber &&
        other.carAddress == carAddress &&
        other.carAddress == carAddress &&
        other.appointmentTime == appointmentTime &&
        other.orderPushState == orderPushState;
  }

  @override
  String toString() =>
      'NotificationOrderInfo(orderNumber: $orderNumber, carAddress: $carAddress, carAddress: $carAddress, appointmentTime: $appointmentTime, orderPushState: $orderPushState)';

  @override
  int compareTo(NotificationOrderInfo other) =>
      other.appointmentTime.compareTo(appointmentTime);
}
