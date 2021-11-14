import 'package:flutter/material.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/common/util/error_utils.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';
import 'package:mileage_wash/server/dao/login_dao.dart';
import 'package:mileage_wash/server/plugin/third_party_plugin.dart';

class LoginController {
  LoginController._();

  static Future<bool> login(
    BuildContext context, {
    required String username,
    required String password,
  }) async {
    try {
      await LoginDao.login(username: username, password: password);
      await ThirdPartyPlugin.instance.onLogin(context);
      return true;
    } catch (error, stack) {
      Logger.reportDartError(error, stack);
      ErrorUtils.showToastWhenHttpError(error, S.of(context).login_error);
    }
    return false;
  }

  static Future<bool> logout(BuildContext context) async {
    try {
      await LoginDao.logout(AppData().loginInfo!);
      // 清除数据
      await ThirdPartyPlugin.instance.onLogout(context);
      HomeNotifier.clearAll(context);
      return true;
    } catch (error, stack) {
      Logger.reportDartError(error, stack);
      ErrorUtils.showToastWhenHttpError(error, S.of(context).logout_error);
    }
    return false;
  }
}
