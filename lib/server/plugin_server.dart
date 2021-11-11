import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mileage_tencent/mileage_tencent.dart';
import 'package:mileage_wash/common/listener/data_notifier.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';

class PluginServer with DataNotifier {
  PluginServer._();

  static late final PluginServer instance = PluginServer._();

  late final JPush jPush = JPush();

  PlatformViewController? _mapViewController;
  PlatformViewController? get mapViewController => _mapViewController;

  late final FlutterMileageTencent _flutterMileageTencent =
      FlutterMileageTencent(hashCode);

  bool _isMapActivated = false;
  bool get isMapActivated => _isMapActivated;

  Future<void> initialize() async {
    await _initJPush();

    if (AppData.instance.isLogin) {
      await _initMap();
    }
  }

  Future<void> _initMap() async {
    if (_mapViewController != null) {
      _mapViewController?.dispose();
      _mapViewController = null;
    }

    if (Platform.isAndroid) {
      final SurfaceAndroidViewController androidViewController =
          PlatformViewsService.initSurfaceAndroidView(
        id: _flutterMileageTencent.viewId,
        viewType: FlutterMileageTencent.viewType,
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
      );
      _mapViewController = androidViewController;
      androidViewController.create();
    }

    _flutterMileageTencent.setListener((CallbackType type, dynamic arguments) {
      if (type == CallbackType.activate) {
        if (arguments['isSuccess'] == true) {
          _isMapActivated = true;
        }
      } else if (type == CallbackType.onLocationChanged) {
        final double latitude = arguments['latitude'] as double;
        final double longitude = arguments['longitude'] as double;
        _onLocationChanged(latitude, longitude);
      }
    });
  }

  Future<bool> _jumpToMapApp(
    BuildContext context,
    String latitude,
    String longitude,
    Future<bool> Function(String latitude, String longitude) callback,
  ) async {
    if (!_isMapActivated) {
      ToastUtils.showToast(S.of(context).map_not_activated_tips);
      return false;
    }
    return callback(latitude, longitude);
  }

  Future<bool> jumpToTencentMapApp(
    BuildContext context,
    String latitude,
    String longitude,
  ) async {
    return _jumpToMapApp(context, latitude, longitude,
        (String latitude, String longitude) async {
      if (!(await _flutterMileageTencent.isAvailable('com.tencent.map'))) {
        ToastUtils.showToast(S.of(context).map_tencent_not_installed_tips);
        return false;
      }

      return _flutterMileageTencent.jumpToMapByData(
          'qqmap://map/routeplan?type=drive&to=我的终点&tocoord=$latitude,$longitude');
    });
  }

  Future<bool> jumpToBaiduMapApp(
    BuildContext context,
    String latitude,
    String longitude,
  ) async {
    return _jumpToMapApp(context, latitude, longitude,
        (String latitude, String longitude) async {
      if (!(await _flutterMileageTencent.isAvailable('com.baidu.BaiduMap'))) {
        ToastUtils.showToast(S.of(context).map_baidu_not_installed_tips);
        return false;
      }
      return _flutterMileageTencent.jumpToMapByIntent('intent://map/direction?'
          'destination=latlng:$latitude,$longitude'
          '|name:我的终点'
          '&mode=driving&'
          '&src=appname#Intent;scheme=bdapp;package=com.baidu.BaiduMap;end');
    });
  }

  Future<bool> jumpToMiniMapApp(
    BuildContext context,
    String latitude,
    String longitude,
  ) async {
    return _jumpToMapApp(context, latitude, longitude,
        (String latitude, String longitude) async {
      if (!(await _flutterMileageTencent.isAvailable('com.autonavi.minimap'))) {
        ToastUtils.showToast(S.of(context).map_mini_not_installed_tips);
        return false;
      }
      return _flutterMileageTencent.jumpToMapByData(
          'androidamap://navi?sourceApplication=appname&poiname=fangheng&lat=$latitude&lon=$longitude&dev=1&style=2');
    });
  }

  void _onLocationChanged(double latitude, double longitude) {
    print('_onLocationChanged => latitude: $latitude, longitude: $longitude');
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

    await _initMap();
  }

  Future<void> stopOnLogout(BuildContext context) async {
    Logger.log('JPush => stopOnLogout');
    //_jPush.cleanTags();
    jPush.deleteAlias();
    jPush.setWakeEnable(enable: false);
    jPush.stopPush();

    _mapViewController?.dispose();
    _mapViewController = null;
  }
}
