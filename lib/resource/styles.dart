import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class TextAttrs {
  const TextAttrs._();

  static const TextStyle home_light_body = TextStyle(
    color: Colors.black,
    fontSize: 14.6,
  );

  static const TextStyle home_light_headline6 = TextStyle(
    color: Colors.black,
    fontSize: 15.8,
  );

  static const TextStyle home_dark_body = TextStyle(
    color: Colors.white,
    fontSize: 14.6,
  );
}

enum ThemeStyle {
  normal,
  light,
  dark,
}

class ThemeAttrs {
  const ThemeAttrs._();

  static final ThemeData defaultThemeStyle = ThemeData(
    backgroundColor: ColorAttrs.lightBackgroundColor,
    scaffoldBackgroundColor: ColorAttrs.bodyBackgroundColor,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ColorAttrs.lightBackgroundColor,
      selectedItemColor: ColorAttrs.home_nav_selected_light_color,
      unselectedItemColor: ColorAttrs.home_nav_unselected_light_color,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      selectedIconTheme: IconThemeData(
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        size: 24,
      ),
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    //indicatorColor: Colors.red,
    //primaryColor: Colors.red,
    primarySwatch: Colors.brown,
    colorScheme: const ColorScheme(
      primary: Colors.blue,
      primaryVariant: Colors.blueAccent,
      onPrimary: Colors.white,
      secondary: Colors.red,
      secondaryVariant: Colors.redAccent,
      onSecondary: Colors.white,
      surface: Colors.green,
      onSurface: Colors.greenAccent,
      background: Colors.grey,
      onBackground: Colors.blueGrey,
      error: Colors.red,
      onError: Colors.yellowAccent,
      brightness: Brightness.light,
    ),
    tabBarTheme: const TabBarTheme(
      unselectedLabelColor: ColorAttrs.home_tab_unselected_light_color,
      labelColor: ColorAttrs.home_tab_selected_light_color,
      labelPadding: EdgeInsets.symmetric(horizontal: 9.4),
      labelStyle: TextStyle(
        fontSize: 14,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorAttrs.lightBackgroundColor,
      elevation: 0.4,
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 26),
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarDividerColor: null,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      toolbarTextStyle: TextAttrs.home_light_body,
    ),
    radioTheme: RadioThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.blue;
        }
        return Colors.grey;
      }),
    ),
  );

  static ThemeData get(ThemeStyle style) {
    final ThemeData defaultThemeData = defaultThemeStyle;
    switch (style) {
      case ThemeStyle.light:
        return defaultThemeData;

      case ThemeStyle.dark:
        return defaultThemeData.copyWith();

      case ThemeStyle.normal:
      default:
        return defaultThemeData;
    }
  }
}

class SystemUiOverlayAttrs {
  const SystemUiOverlayAttrs._();

  static const SystemUiOverlayStyle light = SystemUiOverlayStyle(
    systemNavigationBarColor: ColorAttrs.systemNavigationBarColor,
    systemNavigationBarDividerColor: null,
    statusBarColor: null,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle dark = SystemUiOverlayStyle(
    systemNavigationBarColor: ColorAttrs.systemNavigationBarColor,
    systemNavigationBarDividerColor: null,
    statusBarColor: null,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );
}
