import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mileage_wash/common/listener/ob.dart';
import 'package:mileage_wash/constant/route_ids.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';
import 'package:mileage_wash/page/base.dart';
import 'package:mileage_wash/server/controller/home_controller.dart';
import 'package:mileage_wash/ui/utils/loading_utils.dart';
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
    return Card(
      margin: EdgeInsets.only(top: 12.w),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Tooltip(
                          message:
                              '${orderInfo.adsName} ${orderInfo.adsDetail}',
                          textStyle:
                              TextStyle(fontSize: 26.sp, color: Colors.white),
                          margin: EdgeInsets.symmetric(horizontal: 12.w),
                          padding: EdgeInsets.symmetric(
                              vertical: 4.w, horizontal: 12.w),
                          child: Text(
                            '${orderInfo.adsName} ${orderInfo.adsDetail}',
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 28.sp),
                          ),
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
                        SizedBox(height: 8.h),
                        Text(
                          orderInfo.carNumber,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 26.sp,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.h),
                  if (homeNotifier is HomeWaitingNotifier) ...<Widget>[
                    GestureDetector(
                      onTap: () async {
                        await Navigator.of(context)
                            .pushNamed(RouteIds.notification);
                        _refresh();
                      },
                      child: Icon(
                        Icons.assistant_navigation,
                        size: 72.w,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(width: 68.w),
                  ]
                ],
              ),
            ),
            if (homeNotifier is HomeWaitingNotifier ||
                homeNotifier is HomeWashingNotifier)
              TextButton(
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(
                        RouteIds.washingReview,
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
      ),
    );
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
              itemExtent: _itemHeight,
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
