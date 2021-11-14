import 'package:flutter/material.dart';
import 'package:mileage_wash/server/plugin/jpush_plugin.dart';
import 'package:mileage_wash/server/plugin/tencent_map_plugin.dart';

abstract class PluginInterface {
  Future<bool> initialize();
  Future<bool> onLogin(BuildContext context);
  Future<bool> onLogout(BuildContext context);
  Future<bool> checkPermission();
  Future<bool> requestPermission([BuildContext? context]);
}

mixin BasePluginMiXin implements PluginInterface {
  @override
  Future<bool> checkPermission() => Future<bool>.value(true);
  @override
  Future<bool> requestPermission([BuildContext? context]) => Future<bool>.value(true);
}

class ThirdPartyPlugin with BasePluginMiXin {
  ThirdPartyPlugin._();

  static late final ThirdPartyPlugin instance = ThirdPartyPlugin._();

  late final List<PluginInterface> _plugins = <PluginInterface>[
    JPushPlugin(),
    TencentMapPlugin()
  ];

  static T find<T extends PluginInterface>() {
    return instance._plugins
        .singleWhere((PluginInterface plugin) => plugin is T) as T;
  }

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
    bool isSuccess = true;
    for (final PluginInterface pluginInterface in _plugins) {
      if (!(await visitor(pluginInterface))) {
        isSuccess = false;
      }
    }
    return isSuccess;
  }

  @override
  Future<bool> onLogout(BuildContext context) {
    return _visitPlugins(
        (PluginInterface pluginInterface) => pluginInterface.onLogout(context));
  }

  @override
  Future<bool> checkPermission() {
    return _visitPlugins(
        (PluginInterface pluginInterface) => pluginInterface.checkPermission());
  }

  @override
  Future<bool> requestPermission([BuildContext? context]) {
    return _visitPlugins((PluginInterface pluginInterface) =>
        pluginInterface.requestPermission());
  }
}
