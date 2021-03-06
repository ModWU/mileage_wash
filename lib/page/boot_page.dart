import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/common/util/scroll_behavior.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/page/app_handler.dart';
import 'package:mileage_wash/page/route_generator.dart';
import 'package:mileage_wash/resource/strings.dart';
import 'package:mileage_wash/resource/styles.dart';

import 'boot_manager.dart';

class BootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> with BootManager {
  ThemeData? _themeData;
  Locale? _locale;
  AppHandler? _appHandler;
  GlobalKey<NavigatorState>? _navigationKey;

  @override
  void initState() {
    super.initState();
    _appHandler = AppHandler();
    _navigationKey = GlobalKey<NavigatorState>();
    _themeData = ThemeAttrs.get(theme.value);
    _locale = LanguageCodes.getLocaleByLanguage(language.value);
    theme.addListener(_themeChanged);
    language.addListener(_languageChanged);
  }

  @override
  void dispose() {
    theme.removeListener(_themeChanged);
    language.removeListener(_languageChanged);
    _appHandler?.dispose();

    _themeData = null;
    _locale = null;
    _appHandler = null;
    _navigationKey = null;
    super.dispose();
  }

  void _themeChanged() {
    setState(() {
      _themeData = ThemeAttrs.get(theme.value);
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    print('boot reassemble');
  }

  void _languageChanged() {
    setState(() {
      _locale = LanguageCodes.getLocaleByLanguage(language.value);
    });
  }

  Locale? _handleLocales(
      List<Locale>? locales, Iterable<Locale> supportedLocales) {
    List<Locale>? currentLocales;
    if (locales?.isNotEmpty == true) {
      for (final Locale locale in locales!) {
        if (S.delegate.isSupported(locale)) {
          currentLocales ??= <Locale>[];
          currentLocales.add(locale);
        }
      }
    }

    final Locale locale = currentLocales?.isNotEmpty == true
        ? currentLocales!.first
        : LanguageCodes.defaultLocale;

    return locale;
  }

  @override
  Widget build(BuildContext context) {
    Logger.log('boot build');
    return MaterialApp(
      localizationsDelegates: _delegates,
      restorationScopeId: 'root',
      navigatorKey: _navigationKey!,
      supportedLocales: S.delegate.supportedLocales,
      locale: _locale,
      localeListResolutionCallback: _handleLocales,
      theme: _themeData,
      scrollBehavior: const IOSScrollBehavior(),
      onGenerateRoute: (RouteSettings settings) =>
          RouteGenerator.generate(settings),
      initialRoute: RouteGenerator.initial,
    );
  }

  @override
  TextStyle get bodyText => _themeData!.textTheme.bodyText1!;

  @override
  ThemeData get themeData => _themeData!;

  @override
  Locale? get locale => _locale;

  @override
  AppHandler get appHandler => _appHandler!;
}

const List<LocalizationsDelegate<dynamic>> _delegates =
    <LocalizationsDelegate<dynamic>>[
  /*GlobalCupertinoLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,*/
  ...GlobalMaterialLocalizations.delegates,
  S.delegate,
];
