import 'dart:io';

import 'dart:ui';

import 'package:flutter/cupertino.dart';

class PackageNames {
  PackageNames._();

  //腾讯地图
  static const PackageName tencentMap = PackageName(android: 'com.tencent.map');

  //百度地图
  static const PackageName baiduMap =
      PackageName(android: 'com.baidu.BaiduMap');

  //高德地图
  static const PackageName miniMap =
      PackageName(android: 'com.autonavi.minimap');
}

@immutable
class PackageName {
  const PackageName({this.android, this.ios});

  final String? android;
  final String? ios;

  String get platform => Platform.isAndroid ? android! : ios!;

  @override
  int get hashCode {
    return hashValues(android, ios);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is PackageName && other.android == android && other.ios == ios;
  }

  @override
  String toString() => 'PackageName(android: $android, ios: $ios)';
}
