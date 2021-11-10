import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mileage_wash/common/listener/data_notifier.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';


class PluginServer with DataNotifier {
  PluginServer._();

  static late final PluginServer instance = PluginServer._();

  late final JPush jPush = JPush();

  Future<void> initialize() async {
    await _initJPush();
  }

  Future<void> _initJPush() async {
    Logger.log('JPush => initJPush');

    jPush.setup(
      appKey: 'a2364d3faeb79aeaff6cbe4e',
      channel: 'developer-default',
      production: true,
      debug: kDebugMode,
    );

    jPush.applyPushAuthority(
        const NotificationSettingsIOS(sound: true, alert: true, badge: true));

    final String registrationId = await jPush.getRegistrationID();

    if (AppData.instance.isLogin) {
      jPush.setWakeEnable(enable: true);
    }

    Logger.log('JPush => registrationId: $registrationId');
  }

  Future<void> startOnLogin([BuildContext? context]) async {
    Logger.log('JPush => startOnLogin');
    final String phoneNumber = AppData.instance.loginInfo!.phoneNumber;
    Logger.log('JPush => setAlias: $phoneNumber');
    jPush.setAlias(phoneNumber);
    jPush.resumePush();

    if (context != null) {
      try {
        final bool notificationEnabled = await jPush.isNotificationEnabled();
        Logger.log('JPush => notificationEnabled: $notificationEnabled');

        if (!notificationEnabled) {
          ToastUtils.showToast(
              S.of(context).system_setting_open_notification_tips);
          jPush.openSettingsForNotification();
        }
      } catch (error, stack) {
        Logger.reportDartError(error, stack);
      }
    }
  }

  Future<void> stopOnLogout(BuildContext context) async {
    Logger.log('JPush => stopOnLogout');
    //_jPush.cleanTags();
    jPush.setWakeEnable(enable: false);
    jPush.stopPush();
  }
}
