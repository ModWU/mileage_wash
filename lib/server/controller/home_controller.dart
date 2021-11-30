import 'dart:convert' as json;
import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as audio_players;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/constant/route_ids.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/http/order_details.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/model/http/upload_result.dart';
import 'package:mileage_wash/model/notification_order_info.dart';
import 'package:mileage_wash/model/notifier/order_push_notifier.dart';
import 'package:mileage_wash/page/activity/home/home_page.dart';
import 'package:mileage_wash/page/boot_manager.dart';
import 'package:mileage_wash/server/controller/utils/controller_utils.dart';
import 'package:mileage_wash/server/dao/order_dao.dart';
import 'package:mileage_wash/server/dao/upload_dao.dart';
import 'package:mileage_wash/server/plugin/jpush_plugin.dart';
import 'package:mileage_wash/server/plugin/third_party_plugin.dart';
import 'package:mileage_wash/state/car_state.dart';
import 'package:mileage_wash/state/order_push_state.dart';
import 'package:mileage_wash/state/order_state.dart';
import 'package:provider/provider.dart';

mixin HomeController on State<HomePage> {
  bool _isEnterNotificationPage = false;
  bool get isEnterNotificationPage => _isEnterNotificationPage;

  late final audio_players.AudioCache _audioCache = audio_players.AudioCache();

  late final JPush _jPush = ThirdPartyPlugin.find<JPushPlugin>().jPush;

  static Future<List<OrderInfo>?> queryOrderList(
    BuildContext context, {
    required OrderState orderState,
    required int curPage,
    required int pageSize,
    CancelToken? cancelToken,
    bool allowThrowError = false,
  }) async {
    return ControllerUtils.handleDao(context,
        daoFuture: OrderDao.queryOrderList(
            httpCode: orderState.httpCode,
            curPage: curPage,
            pageSize: pageSize,
            cancelToken: cancelToken),
        allowThrowError: allowThrowError,
        errorTips: S.of(context).order_query_error);
  }

  static Future<OrderDetails?> getOrderDetails(
    BuildContext context, {
    required int id,
    CancelToken? cancelToken,
    bool allowThrowError = false,
  }) async {
    return ControllerUtils.handleDao(context,
        daoFuture: OrderDao.getOrderDetails(id: id, cancelToken: cancelToken),
        allowThrowError: allowThrowError,
        errorTips: S.of(context).order_details_get_error);
  }

  static Future<UploadResult?> uploadPhoto(
    BuildContext context, {
    required String type,
    required XFile file,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    bool allowThrowError = false,
  }) async {
    return ControllerUtils.handleDao(context,
        daoFuture: UploadDao.uploadPhoto(
            type: type,
            file: File(file.path),
            cancelToken: cancelToken,
            onSendProgress: onSendProgress),
        allowThrowError: allowThrowError,
        errorTips: S.of(context).photo_upload_error);
  }

  static Future<int?> saveOrder(
    BuildContext context, {
    required OrderInfo orderInfo,
    required List<String> filePaths,
    required String photoListType,
    required CarState carState,
    CancelToken? cancelToken,
    bool allowThrowError = false,
  }) async {
    return ControllerUtils.handleDao(context,
        daoFuture: OrderDao.saveOrder(
          orderInfo: orderInfo,
          filePaths: filePaths.join(';'),
          photoListType: photoListType,
          carState: carState,
          cancelToken: cancelToken,
        ),
        allowThrowError: allowThrowError,
        errorTips: S.of(context).order_save_error);
  }

  Future<void> openNotificationPage() async {
    final OrderPushNotifier orderPushNotifier =
        context.read<OrderPushNotifier>();
    if (_isEnterNotificationPage || orderPushNotifier.size <= 0) {
      return;
    }

    _isEnterNotificationPage = true;
    _jPush.clearAllNotifications();
    await Navigator.of(context).pushNamed(RouteIds.notification);
    orderPushNotifier.removeAllNotifications();
    BootContext.get().appHandler.doNotificationPop();
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
        _jPush.addEventHandler(
            onReceiveNotification: (Map<String, dynamic> message) async {
          Logger.log('JPush111 => onReceiveNotification message: $message');
          Logger.log(
              'JPush222 => onReceiveMessage containes extras: ${message.containsKey('extras')}');

          if (!message.containsKey('extras')) {
            return;
          }

          final dynamic extrasObj = message['extras']!;

          Logger.log('JPush3333 => onReceiveMessage extrasObj $extrasObj');

          assert(extrasObj is Map<dynamic, dynamic>);
          final Map<dynamic, dynamic> extra =
              extrasObj as Map<dynamic, dynamic>;

          Logger.log('JPush4444 => onReceiveMessage extras $extra');

          final String jPushExtra = extra['cn.jpush.android.EXTRA']! as String;

          Logger.log('JPush5555 => onReceiveMessage jPushExtra $jPushExtra');

          final Map<String, dynamic>? orderPushData =
              json.jsonDecode(jPushExtra) as Map<String, dynamic>?;

          assert(orderPushData != null);

          if (!mounted) {
            return;
          }

          final OrderPushNotifier orderPushNotifier =
              context.read<OrderPushNotifier>();
          final NotificationOrderInfo notificationOrderInfo =
              NotificationOrderInfo.fromJson(orderPushData!);
          orderPushNotifier.push(notificationOrderInfo);

          BootContext.get()
              .appHandler
              .doNotification(notificationOrderInfo, isEnterNotificationPage);

          if (!isEnterNotificationPage) {
            if (notificationOrderInfo.orderPushState == OrderPushState.add) {
              _audioCache.play('order_add_messenger.mp3', isNotification: true);
            } else if (notificationOrderInfo.orderPushState ==
                OrderPushState.cancel) {
              _audioCache.play('order_cancel_messenger.mp3',
                  isNotification: true);
            }
            Logger.log('play mp3');
          }
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
