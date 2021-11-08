import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mileage_wash/common/log/app_log.dart';

class PluginServer {
  PluginServer._();

  static late final PluginServer instance = PluginServer._();

  late final JPush _jPush = JPush();

  Future<void> initialize() async {
    try {
      _jPush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
        Logger.log('flutter JPush => onReceiveNotification message: $message');
      }, onOpenNotification: (Map<String, dynamic> message) async {
        Logger.log('flutter JPush => onOpenNotification message: $message');
      }, onReceiveMessage: (Map<String, dynamic> message) async {
        Logger.log('flutter JPush => onReceiveMessage message: $message');
      }, onReceiveNotificationAuthorization:
              (Map<String, dynamic> message) async {
        Logger.log(
            'flutter JPush => onReceiveNotificationAuthorization message: $message');
      });
    } on PlatformException catch (error, stack) {
      Logger.reportDartError(error, stack);
    }

    _jPush.setup(
      appKey: '6c4f471bbbd289871ab25829',
      channel: 'developer-default',
      production: true,
      debug: kDebugMode,
    );

    _jPush.applyPushAuthority(
        const NotificationSettingsIOS(sound: true, alert: true, badge: true));

    _jPush.getRegistrationID().then((String registrationId) {
      Logger.log(
          'flutter JPush => getRegistrationID registrationId: $registrationId');
    });
  }
}
