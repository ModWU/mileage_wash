import 'dart:convert' as json;
import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as audio_players;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/common/util/error_utils.dart';
import 'package:mileage_wash/constant/route_ids.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/model/http/upload_result.dart';
import 'package:mileage_wash/model/notification_order_info.dart';
import 'package:mileage_wash/model/notifier/order_push_notifier.dart';
import 'package:mileage_wash/page/activity/home/home_page.dart';
import 'package:mileage_wash/page/boot_manager.dart';
import 'package:mileage_wash/server/dao/order_dao.dart';
import 'package:mileage_wash/server/dao/upload_dao.dart';
import 'package:mileage_wash/state/car_state.dart';
import 'package:mileage_wash/state/order_state.dart';
import 'package:provider/provider.dart';

import '../plugin_server.dart';

mixin HomeController on State<HomePage> {
  bool _isEnterNotificationPage = false;
  bool get isEnterNotificationPage => _isEnterNotificationPage;

  late final audio_players.AudioCache _audioCache = audio_players.AudioCache();

  static Future<List<OrderInfo>?> queryOrderList(
    BuildContext context, {
    required OrderState orderState,
    required int curPage,
    required int pageSize,
    CancelToken? cancelToken,
    bool allowThrowError = false,
  }) async {
    try {
      final List<OrderInfo> orderInfo = await OrderDao.queryOrderList(
          orderState: orderState,
          curPage: curPage,
          pageSize: pageSize,
          cancelToken: cancelToken);

      return orderInfo;
    } catch (error, stack) {
      Logger.reportDartError(error, stack);

      if (error is! DioError || error.type != DioErrorType.cancel) {
        ErrorUtils.showToastWhenHttpError(
            error, S.of(context).order_query_error);

        if (allowThrowError) {
          rethrow;
        }
      }
    }
  }

  static Future<UploadResult?> uploadPhoto(
    BuildContext context, {
    required String type,
    required XFile file,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    bool allowThrowError = false,
  }) async {
    try {
      return UploadDao.uploadPhoto(
          type: type,
          file: File(file.path),
          cancelToken: cancelToken,
          onSendProgress: onSendProgress);
    } catch (error, stack) {
      Logger.reportDartError(error, stack);

      if (error is! DioError || error.type != DioErrorType.cancel) {
        ErrorUtils.showToastWhenHttpError(
            error, S.of(context).photo_upload_error);

        if (allowThrowError) {
          rethrow;
        }
      }
    }
    return null;
  }

  static Future<void> saveOrder(
    BuildContext context, {
    required OrderInfo orderInfo,
    required List<String> filePaths,
    required String photoListType,
    required CarState carState,
    CancelToken? cancelToken,
    bool allowThrowError = false,
  }) async {
    try {
      final int data = await OrderDao.saveOrder(
        orderInfo: orderInfo,
        filePaths: filePaths.join(';'),
        photoListType: photoListType,
        carState: carState,
        cancelToken: cancelToken,
      );
    } catch (error, stack) {
      Logger.reportDartError(error, stack);

      if (error is! DioError || error.type != DioErrorType.cancel) {
        ErrorUtils.showToastWhenHttpError(
            error, S.of(context).order_save_error);

        if (allowThrowError) {
          rethrow;
        }
      }
    }
  }

  Future<void> openNotificationPage() async {
    final OrderPushNotifier orderPushNotifier =
        context.read<OrderPushNotifier>();
    if (_isEnterNotificationPage || orderPushNotifier.size <= 0) {
      return;
    }

    _isEnterNotificationPage = true;
    PluginServer.instance.jPush.clearAllNotifications();
    await Navigator.of(context).pushNamed(RouteIds.notification);
    orderPushNotifier.removeAllNotifications();
    BootContext.get().appNotifier.doNotificationPop();
    _isEnterNotificationPage = false;
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _audioCache.fixedPlayer?.notificationService.startHeadlessService();
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      try {
        PluginServer.instance.jPush.addEventHandler(
            onReceiveNotification: (Map<String, dynamic> message) async {
          Logger.log('JPush => onReceiveNotification message: $message');
          if (!isEnterNotificationPage) {
            _audioCache.play('order_messenger.mp3', isNotification: true);
            Logger.log('play mp3');
          }

          Logger.log(
              'JPush => onReceiveMessage containes extras: ${message.containsKey('extras')}');

          if (!message.containsKey('extras')) {
            return;
          }

          final dynamic extrasObj = message['extras']!;

          assert(extrasObj is Map<dynamic, dynamic>);
          final Map<dynamic, dynamic> extra =
              extrasObj as Map<dynamic, dynamic>;

          final String jPushExtra = extra['cn.jpush.android.EXTRA']! as String;

          final Map<String, dynamic>? orderPushData =
              json.jsonDecode(jPushExtra) as Map<String, dynamic>?;

          assert(orderPushData != null);

          if (!mounted) {
            return;
          }

          final OrderPushNotifier orderPushNotifier =
              context.read<OrderPushNotifier>();
          orderPushNotifier
              .push(NotificationOrderInfo.fromJson(orderPushData!));
        }, onOpenNotification: (Map<String, dynamic> message) async {
          Logger.log('JPush => onOpenNotification message: $message');
          openNotificationPage();
        }, onReceiveMessage: (Map<String, dynamic> message) async {
          Logger.log('JPush => onReceiveMessage message: $message');
        }, onReceiveNotificationAuthorization:
                (Map<String, dynamic> message) async {
          Logger.log(
              'JPush => onReceiveNotificationAuthorization message: $message');
        });
      } catch (error, stack) {
        Logger.reportDartError(error, stack);
      }
    });
  }
}
