import 'package:flutter/material.dart';
import 'package:mileage_wash/constant/route_ids.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/page/login/login_page.dart';

import 'activity/activity_page.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      case RouteIds.login:
        return MaterialPageRoute<LoginPage>(
          builder: (BuildContext context) => LoginPage(),
          settings: settings,
        );

      case RouteIds.activity:
        return MaterialPageRoute<LoginPage>(
          builder: (BuildContext context) => ActivityPage(),
          settings: settings,
        );

      default:
        return null;
    }
  }

  static String get initial {
    if (!AppData.instance.isLogin) {
      return RouteIds.login;
    }
    return RouteIds.activity;
  }
}
