import 'package:flutter/material.dart';
import 'package:mileage_wash/model/notification_order_info.dart';
import 'package:mileage_wash/page/app_handler.dart';
import '../state/app_state.dart';
import 'boot_manager.dart';

@optionalTypeArgs
mixin BootMiXin<T extends StatefulWidget> on State<T> {
  BootContext get bootContext => BootContext.get();

  AppHandler get appHandler => bootContext.appHandler;

  @protected
  void pageChanged() {}

  @protected
  void themeChanged() {}

  @protected
  void onLoginPop() {}

  @protected
  void onNotificationPop() {}

  @protected
  void onNotification(NotificationOrderInfo notificationOrderInfo,
      bool isEnterNotificationPage) {}

  bool isPageAt(PageCategory page) {
    return bootContext.isPageAt(page);
  }

  @override
  void initState() {
    super.initState();
    bootContext.page.addListener(pageChanged);
    bootContext.theme.addListener(themeChanged);
    appHandler.addLoginPopListener(onLoginPop);
    appHandler.addNotificationPopListener(onNotificationPop);
    appHandler.addNotificationListener(onNotification);
  }

  @override
  void dispose() {
    bootContext.page.removeListener(pageChanged);
    bootContext.theme.removeListener(themeChanged);
    appHandler.removeListener(onLoginPop);
    appHandler.removeListener(onNotificationPop);
    appHandler.removeListener(onNotification);
    super.dispose();
  }
}
