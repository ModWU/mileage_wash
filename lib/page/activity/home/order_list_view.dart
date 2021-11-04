import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mileage_wash/common/listener/ob.dart';
import 'package:mileage_wash/constant/route_ids.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';
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
    with AutomaticKeepAliveClientMixin {
  RefreshController? _refreshController;
  ScrollController? _scrollController;

  final double _itemHeight = 106;

  final int _cacheScreenLength = 2;

  final Observer<bool> _isLoading = true.ob;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _scrollController = ScrollController();

    widget.homeStateListener.addTabClickListener(_onTabClick);
  }

  void _onTabClick(int clickIndex, int previousIndex) {
    final T homeNotifier = context.read<T>();

    if (clickIndex == homeNotifier.state.index && previousIndex == clickIndex) {
      _scrollController!.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final T homeNotifier = context.read<T>();
    final double screenHeight = MediaQuery.of(context).size.height;
    HomeController.queryOrderList(context,
            orderState: homeNotifier.state,
            curPage: 0,
            pageSize: (screenHeight / _itemHeight).ceil() * _cacheScreenLength,
            allowThrowError: true)
        .then((List<OrderInfo>? orderInfoList) {
      if (mounted) {
        homeNotifier.refreshData(orderInfoList!);
        _isLoading.value = false;
      }
    }).catchError((Object error) {
      print(
          "didChangeDependenciesdidChangeDependencies123: ${homeNotifier.orderData}");
      if (mounted) {
        setState(() {
          _isLoading.value = false;
        });
      }
    });
  }

  @override
  void dispose() {
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
    HomeController.queryOrderList(context,
            orderState: homeNotifier.state,
            curPage: 0,
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
    HomeController.queryOrderList(context,
            orderState: homeNotifier.state,
            curPage: homeNotifier.curPage! + 1,
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
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
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
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            '${orderInfo.adsName} ${orderInfo.adsDetail}',
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          orderInfo.shortName,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          orderInfo.washDate,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 13,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          orderInfo.carNumber,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 13,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (homeNotifier is HomeWaitingNotifier) ...<Widget>[
                    const Icon(
                      Icons.assistant_navigation,
                      size: 34,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 32),
                  ]
                ],
              ),
            ),
            if (homeNotifier is HomeWaitingNotifier ||
                homeNotifier is HomeWashingNotifier)
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteIds.washingReview,
                        arguments: orderInfo);
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.2)))),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                      maximumSize: MaterialStateProperty.all<Size>(
                          const Size.fromWidth(58)),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 8))),
                  child: Align(
                    heightFactor: 5,
                    child: Text(
                      _getButtonText(homeNotifier),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.6,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
            if (homeNotifier is HomeCancelledNotifier ||
                homeNotifier is HomeDoneNotifier)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _getButtonText(homeNotifier),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _splitDate(homeNotifier is HomeDoneNotifier
                          ? orderInfo.endDate!
                          : orderInfo.cancelDate!),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8.6,
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
