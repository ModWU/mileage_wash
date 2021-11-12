import 'package:flutter/material.dart';
import 'package:mileage_wash/server/plugin/jpush_plugin.dart';
import 'package:mileage_wash/server/plugin/tencent_map_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class PluginInterface {
  Future<bool> initialize();
  Future<bool> onLogin(BuildContext context);
  Future<bool> onLogout(BuildContext context);
  List<Permission>? get permissions;
}

class ThirdPartyPlugin implements PluginInterface {
  ThirdPartyPlugin._();

  static late final ThirdPartyPlugin instance = ThirdPartyPlugin._();

  late final Map<PluginType, PluginInterface> _plugins =
      <PluginType, PluginInterface>{
    PluginType.jPush: JPushPlugin(),
    PluginType.tencentMap: TencentMapPlugin(),
  };

  @override
  Future<bool> initialize() async {
    return _visitPlugins(
        (PluginInterface pluginInterface) => pluginInterface.initialize());
  }

  @override
  Future<bool> onLogin(BuildContext context) async {
    return _visitPlugins(
        (PluginInterface pluginInterface) => pluginInterface.onLogin(context));
  }

  Future<bool> _visitPlugins(
      Future<bool> Function(PluginInterface pluginInterface) visitor) async {
    bool isSuccess = false;
    for (final PluginInterface pluginInterface in _plugins.values) {
      isSuccess = await visitor(pluginInterface);
    }
    return isSuccess;
  }

  @override
  Future<bool> onLogout(BuildContext context) {
    return _visitPlugins(
        (PluginInterface pluginInterface) => pluginInterface.onLogout(context));
  }

  @override
  List<Permission>? get permissions {
    final List<Permission> permissions = <Permission>[];
    for (final PluginInterface pluginInterface in _plugins.values) {
      final List<Permission>? pluginPermissions = pluginInterface.permissions;
      if (pluginPermissions != null) {
        permissions.addAll(pluginPermissions);
      }
    }
    return permissions;
  }
}

enum PluginType { jPush, tencentMap }
