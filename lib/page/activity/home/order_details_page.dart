import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mileage_wash/common/util/string_utils.dart';
import 'package:mileage_wash/common/util/text_utils.dart';
import 'package:mileage_wash/constant/http_apis.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/http/order_details.dart';
import 'package:mileage_wash/resource/strings.dart';
import 'package:mileage_wash/state/order_state.dart';
import 'package:mileage_wash/ui/page/simple_image_review_page.dart';

class OrderDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OrderDetails orderDetails =
        ModalRoute.of(context)!.settings.arguments! as OrderDetails;

    final String leadingURI = '${HTTPApis.carImgURL}/';

    final List<String>? photos =
        StringUtils.splitTrim(orderDetails.photo, ',', leading: leadingURI);

    final List<String>? beginPhotos = StringUtils.splitTrim(
        orderDetails.beginPhoto, ';',
        leading: leadingURI);
    final List<String>? endPhotos =
        StringUtils.splitTrim(orderDetails.endPhoto, ';', leading: leadingURI);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(S.of(context).order_details_title),
        elevation: 0,
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: Container(
              padding: const EdgeInsets.all(8),
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxHeight: double.infinity,
              ),
              child: Column(
                children: <Widget>[
                  _buildOrderDataTable(context, orderDetails),
                  const SizedBox(height: 12),
                  if (photos != null)
                    _buildPhoto(context,
                        S.of(context).order_details_car_photo_title, photos),
                  if (beginPhotos != null)
                    _buildPhoto(
                        context,
                        S.of(context).order_details_wash_before_title,
                        beginPhotos),
                  if (endPhotos != null)
                    _buildPhoto(
                        context,
                        S.of(context).order_details_wash_after_title,
                        endPhotos),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhoto(BuildContext context, String title, List<String> photos) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title),
          const SizedBox(height: 14),
          GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: photos.length,
              itemBuilder: (BuildContext context, int index) {
                final String imageUrl = photos[index];
                return Hero(
                  tag: '${imageUrl}_$index',
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    imageBuilder:
                        (BuildContext context, ImageProvider imageProvider) =>
                            GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).push(
                          PageRouteBuilder<SimpleImageReviewPage>(
                              pageBuilder: (BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secondaryAnimation) =>
                                  SimpleImageReviewPage(
                                      initialIndex: index,
                                      photos: photos,
                                      animation: animation),
                              transitionsBuilder: (BuildContext context,
                                  Animation<double> animation,
                                  Animation<double> secondaryAnimation,
                                  Widget child) {
                                return FadeTransition(
                                  opacity: Tween<double>(begin: 0, end: 1)
                                      .animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.fastOutSlowIn,
                                  )),
                                  child: child,
                                );
                              }),
                        );

                        /*  await Navigator.of(context).push(
                        MaterialPageRoute<SimpleImageReviewPage>(
                            builder: (BuildContext context) =>
                                SimpleImageReviewPage(
                                    initialIndex: index, photos: photos)));*/

                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                            overlays: <SystemUiOverlay>[
                              SystemUiOverlay.top,
                              SystemUiOverlay.bottom
                            ]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    placeholder: (
                      BuildContext context,
                      String url,
                    ) =>
                        const SizedBox(),
                    errorWidget: (
                      BuildContext context,
                      String url,
                      dynamic error,
                    ) =>
                        Container(
                      color: Colors.black12,
                      child: Icon(
                        Icons.error,
                        size: 88.w,
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  String? _getAddress(String? adsName, String? adsDetail) {
    final bool hasAdsName = !StringUtils.isTrimEmpty(adsName);
    final bool hasAdsDetail = !StringUtils.isTrimEmpty(adsDetail);

    if (hasAdsName && hasAdsDetail) {
      return adsName! + ' ' + adsDetail!;
    }

    if (!hasAdsName && !hasAdsDetail) {
      return null;
    }

    return hasAdsName ? adsName! : adsDetail!;
  }

  Widget _buildOrderDataTable(BuildContext context, OrderDetails orderDetails) {
    final String? address =
        _getAddress(orderDetails.adsName, orderDetails.adsDetail);

    final List<TitleStyleData> titles = <TitleStyleData>[
      TitleStyleData(S.of(context).order_details_order_number_title,
          StringUtils.toSafeStr(orderDetails.num)),
      TitleStyleData(S.of(context).order_details_address_title,
          StringUtils.toSafeStr(address)),
      TitleStyleData(S.of(context).order_details_carport_number_title,
          StringUtils.toSafeStr(orderDetails.shortName)),
      TitleStyleData(S.of(context).order_details_license_plate_number_title,
          StringUtils.toSafeStr(orderDetails.carNumber)),
      TitleStyleData(S.of(context).order_details_appointment_time_title,
          StringUtils.toSafeStr(orderDetails.washDate)),
      TitleStyleData(S.of(context).order_details_user_remark_title,
          StringUtils.toSafeStr(orderDetails.userRemark))
    ];

    double maxTitleWith = 0;
    for (final TitleStyleData titleStyleData in titles) {
      maxTitleWith = max(
          maxTitleWith,
          titleStyleData
              .updateTextStyle(const TextStyle(fontSize: 15.8))
              .width);
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: IntrinsicColumnWidth()
      },
      children: <TableRow>[
        for (int i = 0; i < titles.length; i++)
          _info(
            context,
            maxTitleWith,
            titles[i],
            thirdChild:
                i == 0 ? _buildState(context, orderDetails.state) : null,
          ),
      ],
    );
  }

  Widget? _buildState(BuildContext context, int? state) {
    if (state == null) {
      return null;
    }

    final OrderState orderState = OrderState.findByHttpCode(state);
    Color color = Colors.white;
    String title = '';
    if (orderState == OrderState.waiting) {
      color = Colors.yellow;
      title = S.of(context).home_tab_waiting;
    } else if (orderState == OrderState.washing) {
      color = Colors.yellow;
      title = S.of(context).home_tab_washing;
    } else if (orderState == OrderState.done) {
      color = Colors.green;
      title = S.of(context).home_tab_done;
    } else if (orderState == OrderState.cancelled) {
      color = Colors.grey;
      title = S.of(context).home_tab_cancelled;
    }

    return Text(
      title,
      style: TextStyle(
        color: color,
      ),
    );
  }

  TableRow _info(
      BuildContext context, double maxTitleWith, TitleStyleData titleStyleData,
      {Widget? thirdChild}) {
    return TableRow(children: <Widget>[
      Container(
        padding: const EdgeInsets.all(4),
        child: titleStyleData.getText(context, maxTitleWith),
      ),
      Container(
        padding: const EdgeInsets.all(4),
        child: Text(
          titleStyleData.data,
          style: const TextStyle(fontSize: 15.8),
        ),
      ),
      thirdChild ?? const SizedBox(),
    ]);
  }
}

class TitleStyleData {
  TitleStyleData(String title, this.data)
      : assert(!StringUtils.isTrimEmpty(title)) {
    _parseTitle(title);
  }

  void _parseTitle(String title) {
    final String titleTrim = title.trim();
    final String sep = title[titleTrim.length - 1];
    if (sep == ':' || sep == '：') {
      final int sepIndex = title.lastIndexOf(sep);
      separator = title.substring(sepIndex);
      this.title = title.substring(0, sepIndex);
    } else {
      this.title = title;
    }
  }

  Size updateTextStyle(TextStyle style) {
    this.style = style;
    size = TextUtils.measureSize(TextSpan(
      style: style,
      text: title,
    ));
    return size;
  }

  Text getText(BuildContext context, double maxTitleWith) {
    final Locale locale = Localizations.localeOf(context);
    if (locale.languageCode == LanguageCodes.zh) {
      final int titleLength = title.length;
      final double padding = titleLength <= 1
          ? (maxTitleWith - size.width) / 2
          : (maxTitleWith - size.width) / (titleLength - 1);
      return Text.rich(
          TextSpan(children: <InlineSpan>[
            ..._organizeTitles(titleLength, title, padding),
            if (separator != null) TextSpan(text: separator),
          ]),
          style: style);
    } else {
      return Text('$title$separator', style: style);
    }
  }

  List<InlineSpan> _organizeTitles(
      int titleLength, String title, double padding) {
    final List<InlineSpan> textSpans = <InlineSpan>[];

    if (titleLength == 1) {
      textSpans.add(WidgetSpan(child: SizedBox(width: padding)));
    }

    for (int i = 0; i < titleLength; i++) {
      final String indexChar = title[i];
      textSpans.add(TextSpan(text: indexChar));
      if (i != titleLength - 1 || titleLength == 1) {
        textSpans.add(WidgetSpan(child: SizedBox(width: padding)));
      }
    }

    return textSpans;
  }

  late final String? separator;
  late final String title;
  late final Size size;
  late final TextStyle style;
  final String data;
}
