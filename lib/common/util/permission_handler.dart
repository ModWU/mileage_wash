import 'package:flutter/material.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  PermissionHandler._();

  //检查权限如果没有则申请
  static Future<bool> request(List<Permission> permissions,
      [BuildContext? context]) async {
    /*
    例如：腾讯地图需要的权限
    Manifest.permission.ACCESS_COARSE_LOCATION,
    Manifest.permission.ACCESS_FINE_LOCATION,
    Manifest.permission.ACCESS_BACKGROUND_LOCATION,  //target为Q时，动态请求后台定位权限
    Manifest.permission.READ_PHONE_STATE,
    Manifest.permission.WRITE_EXTERNAL_STORAGE

    对应 =>
    Permission.location,
    Permission.phone,
    Permission.storage,
    */
    permissions = await _check(permissions);

    bool allowAll = true;
    if (permissions.isNotEmpty) {
      for (final Permission permission in permissions) {
        // 直接请求权限
        PermissionStatus status = await permission.request();
        if (status.isPermanentlyDenied) {
          // The user opted to never again see the permission request dialog for this
          // app. The only way to change the permission's status now is to let the
          // user manually enable it in the system settings.
          if (context != null) {
            ToastUtils.showToast(
                S.of(context).permission_permanently_denied_tips(permission));
          }
          await openAppSettings();
          // 打开设置返回之后再次请求
          status = await permission.request();
          if (!status.isGranted) {
            allowAll = false;
          }
        } else if (!status.isGranted) {
          allowAll = false;
        }
      }
    }
    Logger.log(
        'PermissionHandler => request => permissions: $permissions, allowAll: $allowAll');
    return allowAll;
  }

  // 返回true代表权限都授予了，否则存在没有授予的权限
  static Future<bool> check(List<Permission> permissions) async {
    return (await _check(permissions)).isEmpty;
  }

  // 返回没有授予的权限集合
  static Future<List<Permission>> _check(List<Permission> permissions) async {
    permissions = permissions.toList();

    for (int i = permissions.length - 1; i >= 0; i--) {
      final Permission permission = permissions[i];

      if ((await permission.status).isGranted) {
        permissions.remove(permission);
      }
    }
    return permissions;
  }
}
