import 'package:flutter/material.dart';
import 'package:mileage_wash/common/http/dio_manager.dart';
import 'package:mileage_wash/constant/route_ids.dart';
import 'package:mileage_wash/page/activity/activity_page.dart';
import 'package:mileage_wash/server/interceptor/token_interceptor.dart';

mixin ActivityController on State<ActivityPage> {

  TokenInterceptor? _tokenInterceptor;

  @override
  void initState() {
    super.initState();
    _tokenInterceptor = TokenInterceptor(_onTokenExpired);
    DioManager.dio.interceptors.add(_tokenInterceptor!);
  }

  void _onTokenExpired(int code, String oldToken) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        RouteIds.login, (Route<dynamic> route) => false);
  }

  @override
  void dispose() {
    DioManager.dio.interceptors.remove(_tokenInterceptor);
    super.dispose();
  }
}
