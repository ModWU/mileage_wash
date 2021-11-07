import 'dart:convert' as json;
import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class UploadResult {
  const UploadResult({
    required this.code,
    required this.photo,
  });

  factory UploadResult.fromJson(Map<String, dynamic> jsonMap, String photoKey) {
    assert(jsonMap.containsKey('code'));
    assert(jsonMap.containsKey(photoKey));

    final String code = jsonMap['code']! as String;
    final String photo = jsonMap[photoKey]! as String;

    return UploadResult(
      code: code,
      photo: photo,
    );
  }

  final String code;
  final String photo;

  @override
  int get hashCode {
    return hashValues(code, photo);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is UploadResult && other.code == code && other.photo == photo;
  }

  @override
  String toString() => 'UploadResult(code: $code, photo: $photo)';
}
