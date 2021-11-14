import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mileage_wash/common/listener/ob.dart';
import 'package:mileage_wash/constant/http_apis.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';

class OrderDetailsPage extends StatelessWidget {
  final Observer<int> _currentPage = Observer<int>(1);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: <SystemUiOverlay>[SystemUiOverlay.bottom]);
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    assert(arguments.containsKey('orderInfo'));
    assert(arguments.containsKey('homeNotifier'));

    final OrderInfo orderInfo = arguments['orderInfo']! as OrderInfo;
    final List<String> photoList = orderInfo.photo!.split(',');
    final int photoLength = photoList.length;
    final HomeNotifier homeNotifier =
        arguments['homeNotifier']! as HomeNotifier;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView(
            children: photoList.map<Widget>((String photo) {
              print('build ==> $photo');
              return CachedNetworkImage(
                imageUrl: '${HTTPApis.carImgUrl}/${photo.trim()}',
                imageBuilder:
                    (BuildContext context, ImageProvider imageProvider) =>
                        Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        Colors.red,
                        BlendMode.colorBurn,
                      ),
                    ),
                  ),
                ),
                placeholder: (
                  BuildContext context,
                  String url,
                ) =>
                    UnconstrainedBox(
                  child: SizedBox(
                    width: 78.w,
                    height: 78.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 1.6,
                    ),
                  ),
                ),
                errorWidget: (
                  BuildContext context,
                  String url,
                  dynamic error,
                ) =>
                    UnconstrainedBox(
                  child: Icon(
                    Icons.error,
                    size: 88.w,
                  ),
                ),
              );
            }).toList(),
            onPageChanged: (int index) {
              _currentPage.value = index + 1;
            },
          ),
          Positioned(
            bottom: 86.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.w),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: ObWidget<int>(
                  builder: (Observer<int>? observer) {
                    final int currentPage = observer?.value ?? 1;
                    return Text(
                      '${currentPage}/$photoLength',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.sp,
                      ),
                    );
                  },
                  initialValue: _currentPage,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
