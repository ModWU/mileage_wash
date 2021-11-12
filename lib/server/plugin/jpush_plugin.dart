import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/server/plugin/third_party_plugin.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

class JPushPlugin implements PluginInterface {
  late final JPush jPush = JPush();

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
    final String phoneNumber = AppData.instance.loginInfo!.phoneNumber;
    Logger.log('JPushPlugin => setAlias: $phoneNumber');
    jPush.setAlias(phoneNumber);
    jPush.resumePush();

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
    Logger.log('JPushPlugin => onLogout');
    jPush.deleteAlias();
    jPush.setWakeEnable(enable: false);
    jPush.stopPush();
    return true;
  }

  @override
  List<Permission>? get permissions => null;
}
