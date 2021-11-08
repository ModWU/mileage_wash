import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class NotificationOrderInfo {
  const NotificationOrderInfo({
    required this.orderNumber,
    required this.carAddress,
    required this.carNumber,
    required this.appointmentTime,
  });

  final String orderNumber;
  final String carAddress;
  final String carNumber;
  final String appointmentTime;

  @override
  int get hashCode {
    return hashValues(orderNumber, carAddress, carNumber, appointmentTime);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is NotificationOrderInfo &&
        other.orderNumber == orderNumber &&
        other.carAddress == carAddress &&
        other.carAddress == carAddress &&
        other.appointmentTime == appointmentTime;
  }

  @override
  String toString() =>
      'NotificationOrderInfo(orderNumber: $orderNumber, carAddress: $carAddress, carAddress: $carAddress, appointmentTime: $appointmentTime)';
}
