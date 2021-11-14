import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class OrderInfo {
  const OrderInfo({
    required this.id,
    required this.shortName,
    required this.adsName,
    required this.adsDetail,
    required this.washId,
    required this.washName,
    required this.washDate,
    required this.latitude,
    required this.longitude,
    required this.carNumber,
    required this.state,
    this.endDate,
    this.cancelDate,
    this.photo,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> data) {
    assert(data.containsKey('id'));
    assert(data.containsKey('short_name'));
    assert(data.containsKey('ads_name'));
    assert(data.containsKey('ads_detail'));
    assert(data.containsKey('wash_id'));
    assert(data.containsKey('wash_name'));
    assert(data.containsKey('wash_date'));
    assert(data.containsKey('latitude'));
    assert(data.containsKey('longitude'));
    assert(data.containsKey('car_number'));
    assert(data.containsKey('state'));

    final int id = data['id']! as int;
    final String shortName = data['short_name']! as String;
    final String adsName = data['ads_name']! as String;
    final String adsDetail = data['ads_detail']! as String;
    final int washId = data['wash_id']! as int;
    final String washName = data['wash_name']! as String;
    final String washDate = data['wash_date']! as String;
    final String latitude = data['latitude']! as String;
    final String longitude = data['longitude']! as String;
    final String carNumber = data['car_number']! as String;
    final int state = data['state']! as int;

    final String? endDate = data['end_date'] as String?;
    final String? cancelDate = data['cancel_date'] as String?;
    final String? photo = data['photo'] as String?;

    return OrderInfo(
      id: id,
      shortName: shortName,
      adsName: adsName,
      adsDetail: adsDetail,
      washId: washId,
      washName: washName,
      washDate: washDate,
      latitude: latitude,
      longitude: longitude,
      carNumber: carNumber,
      state: state,
      endDate: endDate,
      cancelDate: cancelDate,
      photo: photo,
    );
  }

  final int id;
  final String shortName;
  final String adsName;
  final String adsDetail;
  final int washId;
  final String washName;
  final String washDate;
  final String latitude;
  final String longitude;
  final String carNumber;
  final int state;
  final String? endDate;
  final String? cancelDate;
  final String? photo;

  @override
  int get hashCode {
    return hashValues(
      id,
      shortName,
      adsName,
      adsDetail,
      washId,
      washName,
      washDate,
      latitude,
      longitude,
      carNumber,
      state,
      endDate,
      cancelDate,
      photo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OrderInfo &&
        other.id == id &&
        other.shortName == shortName &&
        other.adsName == adsName &&
        other.adsDetail == adsDetail &&
        other.washId == washId &&
        other.washName == washName &&
        other.washDate == washDate &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.carNumber == carNumber &&
        other.state == state &&
        other.endDate == endDate &&
        other.cancelDate == cancelDate &&
        other.photo == photo;
  }

  @override
  String toString() =>
      'OrderInfo(id: $id, shortName: $shortName, adsName: $adsName, adsDetail: $adsDetail, washId: $washId, washName: $washName, washDate: $washDate, latitude: $latitude, longitude: $longitude, carNumber: $carNumber, state: $state, endDate: $endDate, cancelDate: $cancelDate, photo: $photo)';
}
