import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mileage_tencent/mileage_tencent.dart';
import 'package:mileage_wash/common/listener/ob.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/common/util/permission_handler.dart';
import 'package:mileage_wash/constant/package_names.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/server/dao/order_dao.dart';
import 'package:mileage_wash/server/plugin/third_party_plugin.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

class TencentMapPlugin with BasePluginMiXin {
  PlatformViewController? _mapViewController;
  PlatformViewController? get mapViewController => _mapViewController;

  late final FlutterMileageTencent _flutterMileageTencent =
      FlutterMileageTencent(hashCode);

  bool _isMapActivated = false;
  bool get isMapActivated => _isMapActivated;

  final Observer<String> debugPositionObserver = Observer<String>(null);

  @override
  Future<bool> initialize() async {
    if (AppData().isLogin) {
      //await requestPermission();
      return create();
    }
    return true;
  }

  Future<bool> create() async {
    if (_isMapActivated || !AppData.instance.isLogin) {
      return false;
    }

    Logger.log('TencentMapPlugin.createMap success');

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
        creationParams: 1000 * 60, //间隔多少毫秒定位一次
        creationParamsCodec: const StandardMessageCodec(),
      );
      _mapViewController = androidViewController;
      androidViewController.create();
    }

    _flutterMileageTencent.setListener((CallbackType type, dynamic arguments) {
      if (type == CallbackType.activate) {
        if (arguments['isSuccess'] == true) {
          _isMapActivated = true;
          Logger.log('TencentMapPlugin.activated');
        }
      } else if (type == CallbackType.onLocationChanged) {
        final double latitude = arguments['latitude'] as double;
        final double longitude = arguments['longitude'] as double;
        _onLocationChanged(latitude, longitude);
      }
    });

    return _mapViewController != null;
  }

  void _onLocationChanged(double latitude, double longitude) {
    Logger.log(
        'TencentMapPlugin.onLocationChanged => latitude: $latitude, longitude: $longitude');
    debugPositionObserver
        .alwaysNotifyValue('latitude: $latitude, longitude: $longitude');

    OrderDao.updateAddress(latitude: '$latitude', longitude: '$longitude')
        .catchError((Object error, StackTrace stack) {
      Logger.reportDartError(error, stack);
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
      if (!(await _flutterMileageTencent
          .isAvailable(PackageNames.tencentMap.platform))) {
        ToastUtils.showToast(S.of(context).map_tencent_not_installed_tips);
        return false;
      }

      try {
        final bool isSuccess = await _flutterMileageTencent.jumpToMapByData(
            'qqmap://map/routeplan?type=drive&to=${S.of(context).map_destination_name}&tocoord=$latitude,$longitude');
        return isSuccess;
      } catch (error, stack) {
        Logger.reportDartError(error, stack);
        ToastUtils.showToast(S.of(context).map_jump_error);
      }
      return false;
    });
  }

  Future<bool> jumpToBaiduMapApp(
    BuildContext context,
    String latitude,
    String longitude,
  ) async {
    return _jumpToMapApp(context, latitude, longitude,
        (String latitude, String longitude) async {
      if (!(await _flutterMileageTencent
          .isAvailable(PackageNames.baiduMap.platform))) {
        ToastUtils.showToast(S.of(context).map_baidu_not_installed_tips);
        return false;
      }
      try {
        final bool isSuccess = await _flutterMileageTencent.jumpToMapByIntent(
            'intent://map/direction?'
            'destination=latlng:$latitude,$longitude'
            '|name:${S.of(context).map_destination_name}'
            '&mode=driving&'
            '&src=appname#Intent;scheme=bdapp;package=com.baidu.BaiduMap;end');
        return isSuccess;
      } catch (error, stack) {
        Logger.reportDartError(error, stack);
        ToastUtils.showToast(S.of(context).map_jump_error);
      }
      return false;
    });
  }

  Future<bool> jumpToMiniMapApp(
    BuildContext context,
    String latitude,
    String longitude,
  ) async {
    return _jumpToMapApp(context, latitude, longitude,
        (String latitude, String longitude) async {
      if (!(await _flutterMileageTencent
          .isAvailable(PackageNames.miniMap.platform))) {
        ToastUtils.showToast(S.of(context).map_mini_not_installed_tips);
        return false;
      }
      try {
        final bool isSuccess = await _flutterMileageTencent.jumpToMapByData(
            'androidamap://navi?sourceApplication=appname&poiname=${S.of(context).map_destination_name}&lat=$latitude&lon=$longitude&dev=1&style=2');
        return isSuccess;
      } catch (error, stack) {
        Logger.reportDartError(error, stack);
        ToastUtils.showToast(S.of(context).map_jump_error);
      }
      return false;
    });
  }

  @override
  Future<bool> onLogin(BuildContext context) async {
    //await requestPermission();
    return create();
  }

  @override
  Future<bool> onLogout(BuildContext context) async {
    _isMapActivated = false;
    _mapViewController?.dispose();
    _mapViewController = null;
    return true;
  }

  @override
  Future<bool> requestPermission([BuildContext? context]) =>
      PermissionHandler.request(_permissions, context);

  @override
  Future<bool> checkPermission() => PermissionHandler.check(_permissions);

  late final List<Permission> _permissions = <Permission>[
    Permission.locationAlways,
    Permission.phone,
    Permission.storage,
  ];
}
