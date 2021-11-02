import 'dart:convert' as json;
import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class LoginInfo {
  const LoginInfo(
      {required this.username,
      required this.phoneNumber,
      required this.password,
      required this.token});

  factory LoginInfo.fromJson(String jsonStr) {
    final Map<String, dynamic> loginInfoData =
        json.jsonDecode(jsonStr) as Map<String, dynamic>;
    assert(loginInfoData.containsKey('username'));
    assert(loginInfoData.containsKey('phoneNumber'));
    assert(loginInfoData.containsKey('password'));
    assert(loginInfoData.containsKey('token'));

    final String username = loginInfoData['username'] as String;
    final String phoneNumber = loginInfoData['phoneNumber']! as String;
    final String password = loginInfoData['password']! as String;
    final String token = loginInfoData['token']! as String;

    return LoginInfo(
        username: username,
        phoneNumber: phoneNumber,
        password: password,
        token: token);
  }

  final String username;
  final String phoneNumber;
  final String password;
  final String token;

  String get toJson => json.jsonEncode(<String, dynamic>{
        'phoneNumber': phoneNumber,
        'username': username,
        'password': password,
        'token': token,
      });

  @override
  int get hashCode {
    return hashValues(username, phoneNumber, password, token);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LoginInfo &&
        other.username == username &&
        other.phoneNumber == phoneNumber &&
        other.password == password &&
        other.token == token;
  }

  @override
  String toString() =>
      'LoginInfo(username: $username, phoneNumber: $phoneNumber, password: $password, token: $token)';
}
