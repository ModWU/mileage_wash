import 'dart:ui';

import 'package:flutter/cupertino.dart';

@immutable
class HttpResultException implements Exception {

  const HttpResultException(
      {required this.code, required this.error, required this.data});

  final int code;
  final String error;
  final dynamic data;

  @override
  int get hashCode {
    return hashValues(
      code,
      error,
      data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is HttpResultException &&
        other.code == code &&
        other.error == error &&
        other.data == other.data;
  }

  @override
  String toString() => 'HttpResultException(code: $code, error: $error, data: $data)';

}