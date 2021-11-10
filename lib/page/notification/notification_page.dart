import 'package:flutter/material.dart';
import 'package:mileage_wash/common/util/time_utils.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/notification_order_info.dart';
import 'package:mileage_wash/model/notifier/order_push_notifier.dart';
import 'package:mileage_wash/state/order_push_state.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: Text(S.of(context).notification_title),
      ),
      body: Builder(
        builder: (BuildContext context) {
          final OrderPushNotifier orderPushNotifier =
              context.watch<OrderPushNotifier>();
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              final Widget child = _NotificationItem(
                orderPushNotifier.getNotificationInfo(index)!,
                margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
              );
              return index == 0 || index == orderPushNotifier.size - 1
                  ? Padding(
                      padding: index == 0
                          ? const EdgeInsets.only(top: 8)
                          : const EdgeInsets.only(bottom: 16),
                      child: child)
                  : child;
            },
            itemCount: orderPushNotifier.size,
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem(this.notificationOrderInfo, {this.margin});

  final NotificationOrderInfo notificationOrderInfo;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child:
                Text(S.of(context).title, style: const TextStyle(fontSize: 18)),
          ),
          const Divider(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 4),
                Text(
                    notificationOrderInfo.orderPushState == OrderPushState.add
                        ? S.of(context).notification_item_add_tips
                        : S.of(context).notification_item_cancel_tips,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth()
                  },
                  children: <TableRow>[
                    _info(S.of(context).notification_item_order_number_title,
                        notificationOrderInfo.orderNumber),
                    _info(S.of(context).notification_item_car_address_title,
                        notificationOrderInfo.carAddress),
                    _info(S.of(context).notification_item_car_number_title,
                        notificationOrderInfo.carNumber),
                    _info(
                        S.of(context).notification_item_appointment_time_title,
                        TimeUtils.getStandardTime(
                            notificationOrderInfo.appointmentTime)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(S.of(context).notification_item_order_details_title,
                      style: const TextStyle(fontSize: 15.4)),
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black12,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _info(String title, String value) {
    return TableRow(children: <Widget>[
      Container(
        padding: const EdgeInsets.all(4),
        child: Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 12.8),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(4),
        child: Text(
          value,
          style: const TextStyle(fontSize: 12.8),
        ),
      )
    ]);
  }
}
