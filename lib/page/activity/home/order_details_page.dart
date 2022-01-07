import 'dart:math';

import 'package:extended_image/extended_image.dart';
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
import 'package:mileage_wash/ui/tween/hero_tween.dart';

class OrderDetailsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OrderDetailsPage();
}

class _OrderDetailsPage extends State<OrderDetailsPage> {
  Map<String, double?>? _imageSizeRadios;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _imageSizeRadios = null;
    super.dispose();
  }

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
                final String imageKey = '${title}_${imageUrl}_$index';
                return Hero(
                  tag: '${imageUrl}_$index',
                  createRectTween: (Rect? begin, Rect? end) {
                    // return MaterialRectArcTween(begin: begin, end: end);
                    final Size size = MediaQuery.of(context).size;
                    final double imageRadio = _imageSizeRadios == null ||
                            !_imageSizeRadios!.containsKey(imageKey)
                        ? 1.0
                        : (_imageSizeRadios![imageKey] ?? 0);

                    final double screenRadio = size.width / size.height;

                    final bool fitWidth = imageRadio > screenRadio;

                    final double fitSize = fitWidth
                        ? size.width / imageRadio
                        : size.height * imageRadio;

                    return SizeRectCenterArcTween(
                        begin: begin,
                        end: end,
                        height: fitWidth ? fitSize : null,
                        width: !fitWidth ? fitSize : null);
                  },
                  child: ExtendedImage.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    cache: true,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.completed:
                          final ImageInfo? imageInfo = state.extendedImageInfo;
                          if (imageInfo != null) {
                            _imageSizeRadios ??= <String, double?>{};
                            _imageSizeRadios![imageKey] =
                                imageInfo.image.width / imageInfo.image.height;
                          }
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.of(context).push(
                                  PageRouteBuilder<SimpleImageReviewPage>(
                                      pageBuilder: (BuildContext context,
                                              Animation<double> animation,
                                              Animation<double>
                                                  secondaryAnimation) =>
                                          SimpleImageReviewPage(
                                              initialIndex: index,
                                              photos: photos,
                                              animation: animation),
                                      transitionsBuilder: (BuildContext context,
                                          Animation<double> animation,
                                          Animation<double> secondaryAnimation,
                                          Widget child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      }));

                              SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.manual,
                                  overlays: <SystemUiOverlay>[
                                    SystemUiOverlay.top,
                                    SystemUiOverlay.bottom
                                  ]);
                            },
                            child: ExtendedRawImage(
                              image: state.extendedImageInfo?.image,
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                            ),
                          );

                        case LoadState.failed:
                          return Container(
                            color: Colors.grey,
                            child: Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 88.w,
                            ),
                          );
                        case LoadState.loading:
                          return const SizedBox();
                      }
                    },
                    mode: ExtendedImageMode.none,
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
      TitleStyleData(S.of(context).order_details_wash_type,
          StringUtils.toSafeStr(orderDetails.washType)),
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
