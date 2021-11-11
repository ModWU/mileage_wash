import 'package:flutter/material.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/common/util/error_utils.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/server/dao/login_dao.dart';

import '../plugin_server.dart';

class LoginController {
  LoginController._();

  static Future<bool> login(
    BuildContext context, {
    required String username,
    required String password,
  }) async {
    try {
      await LoginDao.login(username: username, password: password);
      await PluginServer.instance.startOnLogin(context);
      return true;
    } catch (error, stack) {
      Logger.reportDartError(error, stack);
      ErrorUtils.showToastWhenHttpError(error, S.of(context).login_error);
    }
    return false;
  }

  static Future<bool> logout(BuildContext context) async {
    try {
      await LoginDao.logout(AppData.instance.loginInfo!);
      await PluginServer.instance.stopOnLogout(context);
      return true;
    } catch (error, stack) {
      Logger.reportDartError(error, stack);
      ErrorUtils.showToastWhenHttpError(error, S.of(context).logout_error);
    }
    return false;
  }
}
