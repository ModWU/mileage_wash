import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mileage_tencent/mileage_tencent.dart';
import 'package:mileage_wash/common/http/dio_manager.dart';
import 'package:mileage_wash/constant/route_ids.dart';
import 'package:mileage_wash/page/activity/activity_page.dart';
import 'package:mileage_wash/page/boot_manager.dart';
import 'package:mileage_wash/page/login/login_page.dart';
import 'package:mileage_wash/server/interceptor/token_interceptor.dart';

import '../plugin_server.dart';

mixin ActivityController on State<ActivityPage> {
  TokenInterceptor? _tokenInterceptor;

  @override
  void initState() {
    super.initState();
    _tokenInterceptor = TokenInterceptor(_onTokenExpired);
    DioManager.dio.interceptors.insert(0, _tokenInterceptor!);
  }

  Future<void> _onTokenExpired(int code, String oldToken) async {
    await PluginServer.instance.stopOnLogout(context);
    await Navigator.of(context)
        .pushNamed(RouteIds.login, arguments: LoginNavigationWay.pop);
    BootContext.get().appHandler.doLoginPop();
  }

  @override
  void dispose() {
    DioManager.dio.interceptors.remove(_tokenInterceptor);
    super.dispose();
  }
}
