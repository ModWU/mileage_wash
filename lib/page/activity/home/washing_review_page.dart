import 'package:flutter/material.dart';
import 'package:mileage_wash/model/http/order_info.dart';

class WashingReviewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WashingReviewPageState();
}

class _WashingReviewPageState extends State<WashingReviewPage> {
  @override
  Widget build(BuildContext context) {
    final OrderInfo orderInfo =
        ModalRoute.of(context)!.settings.arguments as OrderInfo;
    return Center(
      child: Text(orderInfo.shortName),
    );
  }
}
