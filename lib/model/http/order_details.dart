import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class OrderDetails {
  const OrderDetails({
    this.num,
    this.adsName,
    this.adsDetail,
    this.shortName,
    this.carNumber,
    this.washDate,
    this.userRemark,
    this.photo,
    this.beginPhoto,
    this.endPhoto,
    this.state,
    this.washType,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> data) {
    final String? num = data['num'] as String?;
    final String? adsName = data['ads_name'] as String?;
    final String? adsDetail = data['ads_detail'] as String?;
    final String? shortName = data['short_name'] as String?;
    final String? carNumber = data['car_number'] as String?;
    final String? washDate = data['wash_date'] as String?;
    final String? userRemark = data['user_remark'] as String?;
    final String? photo = data['photo'] as String?;
    final String? beginPhoto = data['begin_photo'] as String?;
    final String? endPhoto = data['end_photo'] as String?;
    final int? state = data['state'] as int?;
    final String? washType = data['wash_type'] as String?;

    return OrderDetails(
      num: num,
      adsName: adsName,
      adsDetail: adsDetail,
      shortName: shortName,
      carNumber: carNumber,
      washDate: washDate,
      userRemark: userRemark,
      photo: photo,
      beginPhoto: beginPhoto,
      endPhoto: endPhoto,
      state: state,
      washType: washType,
    );
  }

  final String? num; //订单号
  final String? adsName; //地址名
  final String? adsDetail; //地址详情
  final String? shortName; //车位号
  final String? carNumber; //车牌号
  final String? washDate; //预约日期
  final String? userRemark; //备注
  final String? photo; //车位照片。多张以逗号分隔
  final String? beginPhoto; //清洗前的照片。多张以分号分隔
  final String? endPhoto; //清洗后的照片。多张以分号分隔
  final int? state; //订单状态。待清洗（2）黄色，清洗中（3）黄色，清洗完成（4）绿色，已取消（6）灰色
  final String? washType; //洗车类型

  @override
  int get hashCode {
    return hashValues(
      num,
      adsName,
      adsDetail,
      shortName,
      carNumber,
      washDate,
      userRemark,
      photo,
      beginPhoto,
      endPhoto,
      state,
      washType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OrderDetails &&
        other.num == num &&
        other.adsName == adsName &&
        other.adsDetail == adsDetail &&
        other.shortName == shortName &&
        other.carNumber == carNumber &&
        other.washDate == washDate &&
        other.userRemark == userRemark &&
        other.photo == photo &&
        other.beginPhoto == beginPhoto &&
        other.endPhoto == endPhoto &&
        other.state == state &&
        other.washType == washType;
  }

  @override
  String toString() =>
      'OrderDetails(num: $num, adsName: $adsName, adsDetail: $adsDetail, shortName: $shortName, carNumber: $carNumber, washDate: $washDate, userRemark: $userRemark, photo: $photo, beginPhoto: $beginPhoto, endPhoto: $endPhoto, state: $state, washType: $washType)';
}
