import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';
import 'package:mileage_wash/server/app_server.dart';
import 'package:mileage_wash/state/app_state.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void bootApp(Widget app) {
  _runOnLogger(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppServer.initialize();
    await AppState.initialize();
    runApp(MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<HomeWaitingNotifier>(
            create: (_) => HomeWaitingNotifier()),
        ChangeNotifierProvider<HomeWashingNotifier>(
            create: (_) => HomeWashingNotifier()),
        ChangeNotifierProvider<HomeDoneNotifier>(
            create: (_) => HomeDoneNotifier()),
        ChangeNotifierProvider<HomeCancelledNotifier>(
            create: (_) => HomeCancelledNotifier())
      ],
      child: _buildConfiguration(app),
    ));
  });
}

Widget _buildConfiguration(Widget app) {
  return ScreenUtilInit(
    builder: () {
      return RefreshConfiguration(
        headerBuilder: () => const WaterDropHeader(
          waterDropColor: Colors.blue,
        ),
        footerBuilder: () => CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = const Text('pull up load');
            } else if (mode == LoadStatus.loading) {
              body = const CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = const Text('Load Failed! Click retry!');
            } else if (mode == LoadStatus.canLoading) {
              body = const Text('release to load more');
            } else {
              body = const Text('No more data');
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        child: app,
      );
    },
    designSize: const Size(750, 1334),
  );
}

String _stringify(Object? exception) {
  try {
    return exception.toString();
  } catch (e) {
    // intentionally left empty.
  }
  return 'Error';
}

void _runOnLogger(VoidCallback runner) {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    Logger.reportWidgetError(details);
    String message = '';
    assert(() {
      message =
          '${_stringify(details.exception)}\nSee also: https://flutter.dev/docs/testing/errors';
      return true;
    }());
    final Object exception = details.exception;
    return ErrorWidget.withDetails(
        message: message, error: exception is FlutterError ? exception : null);
  };
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.reportFlutterError(details);
  };
  runZonedGuarded<Future<void>>(
    () async {
      runner();
    },
    (Object error, StackTrace stack) {
      Logger.reportDartError(error, stack);
    },
    zoneValues: <String, String>{'name': 'app'},
    zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
      Logger.logByZoneDelegate(self, parent, zone, line);
    }),
  );
}
