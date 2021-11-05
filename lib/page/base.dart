import 'package:flutter/material.dart';
import 'package:mileage_wash/page/app_notifier.dart';
import '../state/app_state.dart';
import 'boot_manager.dart';

@optionalTypeArgs
mixin BootMiXin<T extends StatefulWidget> on State<T> {
  BootContext get bootContext => BootContext.get();

  AppNotifier get appNotifier => bootContext.appNotifier;

  @protected
  void pageChanged() {}

  @protected
  void themeChanged() {}

  bool isPageAt(PageCategory page) {
    return bootContext.isPageAt(page);
  }

  @override
  void initState() {
    super.initState();
    bootContext.page.addListener(pageChanged);
    bootContext.theme.addListener(themeChanged);
  }

  @override
  void dispose() {
    bootContext.page.removeListener(pageChanged);
    bootContext.theme.removeListener(themeChanged);
    super.dispose();
  }
}
