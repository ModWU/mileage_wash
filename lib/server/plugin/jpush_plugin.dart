import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/server/plugin/third_party_plugin.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';

class JPushPlugin with BasePluginMiXin {
  late final JPush jPush = JPush();

  bool? _isCallStop;

  @override
  Future<bool> initialize() async {
    Logger.log('JPushPlugin => initialize');

    jPush.setup(
      appKey: 'a2364d3faeb79aeaff6cbe4e',
      channel: 'developer-default',
      production: true,
      debug: kDebugMode,
    );

    jPush.applyPushAuthority(
        const NotificationSettingsIOS(sound: true, alert: true, badge: true));

    final String registrationId = await jPush.getRegistrationID();

    Logger.log('JPushPlugin => registrationId: $registrationId');

    return true;
  }

  @override
  Future<bool> onLogin(BuildContext context) async {
    Logger.log('JPushPlugin => onLogin');

    final bool? isCallStop = _isCallStop;

    if (isCallStop != null && !isCallStop) {
      return true;
    }

    if (isCallStop ?? false) {
      Logger.log('JPushPlugin => onLogin => resumePush start');
      jPush.resumePush();
      Logger.log('JPushPlugin => onLogin => resumePush end');
    }

    _isCallStop = false;

    //final String registrationId = await jPush.getRegistrationID();

    //Logger.log('JPushPlugin => onLogin => registrationId: $registrationId');

    final String phoneNumber = AppData().loginInfo!.phoneNumber;
    /*final Map<dynamic, dynamic> setAliasData = await jPush.setAlias(phoneNumber);*/
    jPush.setAlias(phoneNumber);

    //Logger.log('JPushPlugin => onLogin => setAlias: setAliasData: $setAliasData');

    try {
      final bool notificationEnabled = await jPush.isNotificationEnabled();
      Logger.log('onLogout => notificationEnabled: $notificationEnabled');

      if (!notificationEnabled) {
        ToastUtils.showToast(
            S.of(context).system_setting_open_notification_tips);
        jPush.openSettingsForNotification();
      }
      return true;
    } catch (error, stack) {
      Logger.reportDartError(error, stack);
      return false;
    }
  }

  @override
  Future<bool> onLogout(BuildContext context) async {
    Logger.log('JPushPlugin => onLogout => _isCallStop: $_isCallStop');
    final bool? isCallStop = _isCallStop;
    if (isCallStop == null || isCallStop) {
      return true;
    }
    Logger.log('JPushPlugin => onLogout => deleteAlias start');
    final Map<dynamic, dynamic> deleteAliasData = await jPush.deleteAlias();
    Logger.log('JPushPlugin => onLogout => deleteAlias end => deleteAliasData: $deleteAliasData');
    jPush.stopPush();
    Logger.log('JPushPlugin => onLogout => stopPush end');
    _isCallStop = true;
    return true;
  }
}
