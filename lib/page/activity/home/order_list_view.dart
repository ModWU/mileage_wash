import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mileage_wash/common/listener/ob.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/common/util/string_utils.dart';
import 'package:mileage_wash/constant/route_ids.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/http/order_details.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/model/notification_order_info.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';
import 'package:mileage_wash/page/base.dart';
import 'package:mileage_wash/resource/assets_image.dart';
import 'package:mileage_wash/server/controller/home_controller.dart';
import 'package:mileage_wash/server/plugin/tencent_map_plugin.dart';
import 'package:mileage_wash/server/plugin/third_party_plugin.dart';
import 'package:mileage_wash/ui/utils/loading_utils.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'home_page.dart';

class OrderListView<T extends HomeNotifier> extends StatefulWidget {
  const OrderListView(this.homeStateListener);

  final HomeStateListener homeStateListener;

  @override
  State<StatefulWidget> createState() => OrderListState<T>();
}

class OrderListState<T extends HomeNotifier> extends State<OrderListView<T>>
    with BootMiXin, AutomaticKeepAliveClientMixin {
  RefreshController? _refreshController;
  ScrollController? _scrollController;

  final double _itemHeight = 180.h;

  final int _cacheScreenLength = 2;

  final Observer<bool> _isLoading = true.ob;

  final Observer<bool> _showStickDetailsLogo = true.ob;

  bool _isClickJumpMap = false;

  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _scrollController = ScrollController();

    widget.homeStateListener.addTabClickListener(_onTabClick);
  }

  @override
  void onLoginPop() {
    _refresh();
  }

  @override
  void onNotificationPop() {
    _refresh();
  }

  @override
  void onNotification(NotificationOrderInfo notificationOrderInfo,
      bool isEnterNotificationPage) {
    Logger.log(
        'OrderListState#$T => onNotification ${T == HomeWaitingNotifier}');
    if (!isEnterNotificationPage && (T == HomeWaitingNotifier)) {
      _refresh();
    }
  }

  void _refresh() {
    final T homeNotifier = context.read<T>();
    if (widget.homeStateListener.isTabAt(homeNotifier.index)) {
      _scrollController?.jumpTo(0);
      _isLoading.value = true;
      _refreshData(homeNotifier, onFinished: () {
        _isLoading.value = false;
      });
    }
  }

  void _onTabClick(int clickIndex, int previousIndex) {
    if (previousIndex == clickIndex) {
      final T homeNotifier = context.read<T>();
      if (clickIndex == homeNotifier.state.index) {
        _scrollController!.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final T homeNotifier = context.read<T>();
    final double screenHeight = MediaQuery.of(context).size.height;
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel();
    }

    _cancelToken = CancelToken();

    HomeController.queryOrderList(context,
            orderState: homeNotifier.state,
            curPage: 0,
            cancelToken: _cancelToken,
            pageSize: (screenHeight / _itemHeight).ceil() * _cacheScreenLength,
            allowThrowError: true)
        .then((List<OrderInfo>? orderInfoList) {
      if (mounted) {
        homeNotifier.refreshData(orderInfoList!);
        _isLoading.value = false;
      }
    }).catchError((Object error) {
      if (mounted) {
        setState(() {
          _isLoading.value = false;
        });
      }
    });
  }

  @override
  void dispose() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel();
    }
    _cancelToken = null;

    widget.homeStateListener.removeListener(_onTabClick);

    _refreshController?.dispose();
    _scrollController?.dispose();

    _refreshController = null;
    _scrollController = null;
    super.dispose();
  }

  bool _isAllowPullUp(T homeNotifier, double maxHeight) {
    final int visibleCapacity = (maxHeight / _itemHeight).ceil();

    final int orderSize = homeNotifier.size;
    return orderSize >= visibleCapacity;
  }

  Future<void> _onRefresh() async {
    final T homeNotifier = context.read<T>();
    _refreshController!.resetNoData();

    _refreshData(homeNotifier, onCompleted: () {
      _refreshController!.refreshCompleted();
    }, onNoData: () {
      _refreshController!.loadNoData();
      _refreshController!.refreshCompleted();
    }, onFailed: () {
      _refreshController!.refreshFailed();
    });
  }

  Future<void> _onLoading() async {
    final T homeNotifier = context.read<T>();

    if (_isAllowPullUp(homeNotifier, _viewportDimension)) {
      _loadMoreData(homeNotifier, onCompleted: () {
        _refreshController!.loadComplete();
      }, onNoData: () {
        _refreshController!.loadNoData();
      }, onFailed: () {
        _refreshController!.loadFailed();
      });
    } else {
      _refreshController!.loadComplete();
    }
  }

  void _refreshData(T homeNotifier,
      {VoidCallback? onCompleted,
      VoidCallback? onNoData,
      VoidCallback? onFailed,
      VoidCallback? onFinished}) {
    final int cacheSize = _cacheSize;
    _cancelToken = CancelToken();
    HomeController.queryOrderList(context,
            orderState: homeNotifier.state,
            curPage: 0,
            cancelToken: _cancelToken,
            pageSize: cacheSize,
            allowThrowError: true)
        .then((List<OrderInfo>? orderInfoList) {
      if (mounted) {
        homeNotifier.refreshData(orderInfoList!);
        if (orderInfoList.length >= cacheSize) {
          onCompleted?.call();
        } else {
          onNoData?.call();
        }
        onFinished?.call();
      }
    }).catchError((Object error) {
      if (mounted) {
        onFailed?.call();
        onFinished?.call();
      }
    });
  }

  void _loadMoreData(T homeNotifier,
      {VoidCallback? onCompleted,
      VoidCallback? onNoData,
      VoidCallback? onFailed}) {
    final int cacheSize = _cacheSize;
    _cancelToken = CancelToken();
    HomeController.queryOrderList(context,
            orderState: homeNotifier.state,
            curPage: homeNotifier.curPage! + 1,
            cancelToken: _cancelToken,
            pageSize: cacheSize,
            allowThrowError: true)
        .then((List<OrderInfo>? orderInfoList) {
      if (mounted) {
        homeNotifier.addData(orderInfoList!);
        if (orderInfoList.length >= cacheSize) {
          onCompleted?.call();
        } else {
          onNoData?.call();
        }
      }
    }).catchError((Object error) {
      if (mounted) {
        onFailed?.call();
      }
    });
  }

  int get _cacheSize => _computerCacheSize();

  double get _viewportDimension {
    final ScrollController scrollController = _scrollController!;
    assert(scrollController.hasClients);
    assert(scrollController.position.hasViewportDimension);
    final double viewportDimension =
        scrollController.position.viewportDimension;
    assert(viewportDimension > 0);

    return viewportDimension;
  }

  int _computerCacheSize() {
    final int numPerScreen = (_viewportDimension / _itemHeight).ceil();
    assert(numPerScreen > 0);

    return numPerScreen * _cacheScreenLength;
  }

  String _getButtonText(T homeNotifier) {
    switch (homeNotifier.runtimeType) {
      case HomeWaitingNotifier:
        return S.of(context).home_order_item_waiting_btn;
      case HomeWashingNotifier:
        return S.of(context).home_order_item_washing_btn;
      case HomeDoneNotifier:
        return S.of(context).home_order_item_done_btn;
      case HomeCancelledNotifier:
        return S.of(context).home_order_item_cancelled_btn;
    }

    throw 'Wrong type $T';
  }

  Widget _buildOrderItemView(BuildContext context, int index, T homeNotifier,
      BoxConstraints constraints) {
    final OrderInfo orderInfo = homeNotifier.orderData![index];
    return GestureDetector(
      onTap: () async {
        _isLoading.value = true;
        _cancelToken = CancelToken();
        final OrderDetails? orderDetails = await HomeController.getOrderDetails(
            context,
            id: orderInfo.id,
            cancelToken: _cancelToken);
        _isLoading.value = false;

        if (orderDetails != null) {
          await Navigator.of(context)
              .pushNamed(RouteIds.orderDetails, arguments: orderDetails);
          _refresh();
        }
      },
      /* onLongPress: () {
        _showStickDetailsLogo.value = false;
      },
      onLongPressCancel: () {
        _showStickDetailsLogo.value = true;
      },
      onLongPressUp: () {
        _showStickDetailsLogo.value = true;
      },*/
      child: IntrinsicHeight(
        child: Card(
          margin: EdgeInsets.only(top: 12.w),
          child: Stack(
            children: <Widget>[
              if (!StringUtils.isEmptySplitTrim(orderInfo.photo, ','))
                _buildStickDetailsLogo(),
              _buildOrderItemContent(context, index, homeNotifier),
              /*ColorFiltered(
                colorFilter:
                    const ColorFilter.mode(Colors.transparent, BlendMode.srcOut),
                child: _buildOrderItemContent(context, index, homeNotifier),
              )*/
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickDetailsLogo() {
    return Positioned(
        child: ObWidget<bool>(
            builder: (Observer<bool>? observer) {
              final bool isShow = observer?.value ?? true;
              return Offstage(
                offstage: !isShow,
                child: Container(
                  width: 88.w,
                  height: 88.w,
                  child: Image.asset(AssetsImage.stickDetailsLogo,
                      fit: BoxFit.contain),
                ),
              );
            },
            initialValue: _showStickDetailsLogo));
  }

  Widget _buildOrderItemContent(
      BuildContext context, int index, T homeNotifier) {
    final OrderInfo orderInfo = homeNotifier.orderData![index];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.w),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      /* Tooltip(
                        message: '${orderInfo.adsName} ${orderInfo.adsDetail}',
                        textStyle:
                            TextStyle(fontSize: 26.sp, color: Colors.white),
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                        padding: EdgeInsets.symmetric(
                            vertical: 4.w, horizontal: 12.w),
                        child: Text(
                          '${orderInfo.adsName} ${orderInfo.adsDetail}',
                          style: TextStyle(fontSize: 28.sp),
                        ),
                      ),*/
                      Text(
                        '${orderInfo.adsName} ${orderInfo.adsDetail}',
                        style: TextStyle(fontSize: 28.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        orderInfo.shortName,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis, fontSize: 22.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        orderInfo.washDate,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 26.sp,
                            color: Colors.grey),
                      ),
                      if (orderInfo.carNumber != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            orderInfo.carNumber!,
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 26.sp,
                                color: Colors.grey),
                          ),
                        )
                    ],
                  ),
                ),
                SizedBox(width: 8.h),
                if (homeNotifier is HomeWaitingNotifier) ...<Widget>[
                  GestureDetector(
                    /*onTap: () async {
                          showModalBottomSheet<dynamic>(
                              builder: (BuildContext context) {
                                return Container(
                                  height: 260.h,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            _jumpToMapByClick(
                                                context,
                                                (TencentMapPlugin
                                                        tencentMapPlugin) =>
                                                    tencentMapPlugin
                                                        .jumpToTencentMapApp(
                                                            context,
                                                            orderInfo.latitude,
                                                            orderInfo
                                                                .longitude));
                                          },
                                          style: ButtonStyle(
                                            minimumSize:
                                                MaterialStateProperty.all<Size>(
                                                    Size.infinite),
                                          ),
                                          child: Text(
                                            S.of(context).map_tencent_title,
                                            style: TextStyle(fontSize: 32.sp),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        height: 1,
                                        color: Colors.black12,
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () async {
                                            _jumpToMapByClick(
                                                context,
                                                (TencentMapPlugin
                                                        tencentMapPlugin) =>
                                                    tencentMapPlugin
                                                        .jumpToMiniMapApp(
                                                            context,
                                                            orderInfo.latitude,
                                                            orderInfo
                                                                .longitude));
                                          },
                                          style: ButtonStyle(
                                            minimumSize:
                                                MaterialStateProperty.all<Size>(
                                                    Size.infinite),
                                          ),
                                          child: Text(
                                              S.of(context).map_mini_title,
                                              style:
                                                  TextStyle(fontSize: 32.sp)),
                                        ),
                                      ),
                                      const Divider(
                                        height: 1,
                                        color: Colors.black12,
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () async {
                                            _jumpToMapByClick(
                                                context,
                                                (TencentMapPlugin
                                                        tencentMapPlugin) =>
                                                    tencentMapPlugin
                                                        .jumpToBaiduMapApp(
                                                            context,
                                                            orderInfo.latitude,
                                                            orderInfo
                                                                .longitude));
                                          },
                                          style: ButtonStyle(
                                            minimumSize:
                                                MaterialStateProperty.all<Size>(
                                                    Size.infinite),
                                          ),
                                          child: Text(
                                              S.of(context).map_baidu_title,
                                              style:
                                                  TextStyle(fontSize: 32.sp)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              context: context,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25.w),
                                      topRight: Radius.circular(25.w))));
                        },*/
                    child: Icon(
                      Icons.assistant_navigation,
                      size: 88.w,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(width: 48.w),
                ]
              ],
            ),
          ),
          if (homeNotifier is HomeWaitingNotifier ||
              homeNotifier is HomeWashingNotifier)
            TextButton(
                onPressed: () async {
                  await Navigator.of(context).pushNamed(RouteIds.washingReview,
                      arguments: <String, dynamic>{
                        'homeNotifier': homeNotifier,
                        'orderInfo': orderInfo,
                      });
                  _refresh();
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.w)))),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                    fixedSize: MaterialStateProperty.all<Size>(
                        Size(98.w, _itemHeight - 72.h)),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 0.w))),
                child: Text(
                  _getButtonText(homeNotifier),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                )),
          if (homeNotifier is HomeCancelledNotifier ||
              homeNotifier is HomeDoneNotifier)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _getButtonText(homeNotifier),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 26.sp,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    _splitDate(homeNotifier is HomeDoneNotifier
                        ? orderInfo.endDate!
                        : orderInfo.cancelDate!),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.8.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Future<void> _jumpToMapByClick(
      BuildContext context,
      Future<bool> Function(TencentMapPlugin tencentMapPlugin)
          sendJumpCallback) async {
    if (_isClickJumpMap) {
      return;
    }
    _isClickJumpMap = true;
    final TencentMapPlugin tencentMapPlugin =
        ThirdPartyPlugin.find<TencentMapPlugin>();
    bool isSuccess = true;
    if (!(await tencentMapPlugin.checkPermission())) {
      isSuccess = await tencentMapPlugin.requestPermission();
      /*if (isSuccess) {
        isSuccess = await tencentMapPlugin.createMap();
      }*/
    }

    if (!isSuccess) {
      _isClickJumpMap = false;
      ToastUtils.showToast(S.of(context).map_jump_error);
      Navigator.of(context).pop();
      return;
    }

    isSuccess = await sendJumpCallback(tencentMapPlugin);
    _isClickJumpMap = false;
    if (isSuccess) {
      Navigator.of(context).pop();
    }
  }

  String _splitDate(String date) {
    final String dateStr = date.trim();
    return dateStr.splitMapJoin(RegExp(r'\s+'), onMatch: (Match match) => '\n');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final T homeNotifier = context.watch<T>();

      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Offstage(
            offstage: homeNotifier.hasData || (_isLoading.value ?? false),
            child: const Center(
              child: Text(
                'Empty Data',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ),
          ),
          SmartRefresher(
            key: ValueKey<String>('smart_refresher_$T'),
            enablePullDown: true,
            enablePullUp: _isAllowPullUp(homeNotifier, constraints.maxHeight),
            controller: _refreshController!,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(
              controller: _scrollController!,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return _buildOrderItemView(
                    context, index, homeNotifier, constraints);
              },
              //itemExtent: _itemHeight,
              itemCount: homeNotifier.size,
            ),
          ),
          ObWidget<bool>(
              initialValue: _isLoading,
              builder: (Observer<bool>? observer) {
                final bool isLoading = observer?.value ?? false;
                return Offstage(
                  offstage: !isLoading,
                  child: const LoadingWidget(),
                );
              })
        ],
      );
    });
  }

  @override
  bool get wantKeepAlive => false;
}
