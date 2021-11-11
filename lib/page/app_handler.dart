import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mileage_wash/common/listener/data_notifier.dart';
import 'package:mileage_wash/common/util/app_utils.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/notification_order_info.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';

enum NotificationType { loginPop, notificationPop, notification }

class AppHandler with DataNotifier {
  AppHandler();

  DateTime? _lastPopTime;

  void addLoginPopListener(VoidCallback listener) {
    addListener(NotificationType.loginPop, listener);
  }

  void addNotificationPopListener(VoidCallback listener) {
    addListener(NotificationType.notificationPop, listener);
  }

  void addNotificationListener(
      void Function(NotificationOrderInfo notificationOrderInfo,
              bool isEnterNotificationPage)
          listener) {
    addListener(NotificationType.notification, listener);
  }

  void doLoginPop() {
    notifyListeners(NotificationType.loginPop);
  }

  void doNotificationPop() {
    notifyListeners(NotificationType.notificationPop);
  }

  void doNotification(NotificationOrderInfo notificationOrderInfo,
      bool isEnterNotificationPage) {
    notifyListeners(NotificationType.notification, notificationOrderInfo,
        isEnterNotificationPage);
  }

  Future<bool> isAllowBack(BuildContext context) async {
    if (_lastPopTime == null ||
        DateTime.now().difference(_lastPopTime!) > const Duration(seconds: 2)) {
      _lastPopTime = DateTime.now();
      ToastUtils.showToast(S.of(context).exit_tip_twice_click);
      return false;
    } else {
      _lastPopTime = DateTime.now();
    }
    AppUtils.exit();
    return false;
  }

  @override
  void dispose() {
    NotificationType.values.forEach(removeAllListenerByKey);
    _lastPopTime = null;
    super.dispose();
  }
}
