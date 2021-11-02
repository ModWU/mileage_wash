import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mileage_wash/common/http/http_exception.dart';
import 'package:mileage_wash/constant/http_result_code.dart';

@immutable
class HttpResult {
  const HttpResult._constructor(
      {required this.code, required this.msg, required this.data});

  factory HttpResult.fromJson(Map<String, dynamic> data) {
    assert(data.containsKey('code'));
    assert(data.containsKey('msg'));

    final int code = data['code']! as int;
    final String msg = data['msg']! as String;

    return HttpResult._constructor(
      code: code,
      msg: msg,
      data: data['data'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = <String, dynamic>{};
    jsonMap['code'] = code;
    jsonMap['msg'] = msg;
    jsonMap['data'] = data;
    return jsonMap;
  }

  final int code;
  final String msg;
  final dynamic data;

  bool get isSuccessful {
    return code == HttpResultCode.success;
  }

  bool get hasData {
    return data != null;
  }

  HttpResultException? get exception {
    HttpResultException? exception;

    if (!isSuccessful) {
      exception = HttpResultException(
        code: code,
        error: msg,
        data: data,
      );
    }

    return exception;
  }

  @override
  int get hashCode {
    return hashValues(
      code,
      msg,
      data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is HttpResult &&
        other.code == code &&
        other.msg == msg &&
        other.data == other.data;
  }

  @override
  String toString() => 'HttpResult(code: $code, msg: $msg, data: $data)';
}
