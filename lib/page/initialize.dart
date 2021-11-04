import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';
import 'package:mileage_wash/state/app_state.dart';
import 'package:mileage_wash/server/app_server.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

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
      child: app,
    ));
  });
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
