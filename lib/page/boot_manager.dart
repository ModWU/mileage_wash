import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mileage_wash/resource/styles.dart';
import 'app_state.dart';
import 'boot_page.dart';

abstract class BootContext {
  factory BootContext.get() => _BootContextRefManager.bootContextInstance!;

  AppState<PageCategory> get page;
  AppState<ThemeStyle> get theme;
  AppState<String> get language;

  void changeThemeStyle(ThemeStyle value);
  void changeLanguage(String languageCode);

  Listenable bindListeners(Object key, List<Listenable> listeners);
  Listenable unbindListeners(Object key);

  bool isPageAt(PageCategory page);
  TextStyle get bodyText;
  ThemeData get themeData;
  Locale? get locale;
}

mixin BootManager on State<BootPage> implements BootContext {
  @override
  AppState<PageCategory> get page => AppState.page;

  @override
  AppState<ThemeStyle> get theme => AppState.theme;

  @override
  AppState<String> get language => AppState.language;

  @override
  Listenable bindListeners(Object key, List<Listenable> listeners) =>
      AppState.bindListeners(key, listeners);

  @override
  Listenable unbindListeners(Object key) => AppState.unbindListeners(key);

  @override
  bool isPageAt(PageCategory pageValue) {
    return pageValue == page.value;
  }

  @override
  void initState() {
    super.initState();
    _BootContextRefManager.addInstance(this);
    assert(AppState.initialized);
  }

  @override
  void dispose() {
    if (_BootContextRefManager.removeInstance(this)) {
      AppState.doDispose();
      _BootContextRefManager.dispose();
    }
    super.dispose();
  }

  @override
  void changeThemeStyle(ThemeStyle value) {
    theme.value = value;
  }

  @override
  void changeLanguage(String value) {
    language.value = value;
  }

}

class _BootContextRefManager {
  _BootContextRefManager._();

  static BootContext? _bootContextInstance;
  static Map<int, BootContext>? bootContextRefCache;

  static BootContext? get bootContextInstance =>
      bootContextRefCache?[_bootContextInstance?.hashCode];

  static void addInstance(BootContext instance) {
    bootContextRefCache ??= <int, BootContext>{};
    bootContextRefCache![instance.hashCode] = instance;
    _bootContextInstance = instance;
  }

  static bool removeInstance(BootContext instance) {
    bootContextRefCache?.remove(instance.hashCode);
    return bootContextRefCache?.isEmpty ?? true;
  }

  static void dispose() {
    _bootContextInstance = null;
    bootContextRefCache = null;
  }
}
