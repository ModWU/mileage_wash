import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  PermissionHandler._();

  //检查权限如果没有则申请
  static Future<bool> request(List<Permission> permissions) async {
    // 腾讯地图需要的权限
    /*Manifest.permission.ACCESS_COARSE_LOCATION,
    Manifest.permission.ACCESS_FINE_LOCATION,
    Manifest.permission.ACCESS_BACKGROUND_LOCATION,  //target为Q时，动态请求后台定位权限
    Manifest.permission.READ_PHONE_STATE,
    Manifest.permission.WRITE_EXTERNAL_STORAGE

    Permission.location,
      Permission.phone,
      Permission.storage,
    */
    permissions = await _check(permissions);

    if (permissions.isNotEmpty) {
      for (final Permission permission in permissions) {
        if (!(await permission.request().isGranted)) {
          return false;
        }
      }
    }
    return true;
  }

  static Future<bool> check(List<Permission> permissions) async {
    return (await _check(permissions)).isNotEmpty;
  }

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
