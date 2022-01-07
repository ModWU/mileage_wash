import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mileage_wash/common/listener/ob.dart';

class SimpleImageReviewPage extends StatefulWidget {
  SimpleImageReviewPage(
      {required this.photos, this.initialIndex = 0, this.animation})
      : assert(photos.isNotEmpty),
        assert(initialIndex >= 0 && initialIndex < photos.length);

  final List<String> photos;
  final int initialIndex;
  final Animation<double>? animation;

  @override
  State<StatefulWidget> createState() => _SimpleImageReviewPageState();
}

class _SimpleImageReviewPageState extends State<SimpleImageReviewPage> {
  Observer<int>? _currentPage;

  ExtendedPageController? _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = ExtendedPageController(initialPage: widget.initialIndex);
    _currentPage = Observer<int>(null);

    if (widget.animation != null) {
      widget.animation!.addStatusListener(_onAnimationStatus);
      widget.animation!.addListener(_onAnimation);
    } else {
      _currentPage!.value = widget.initialIndex + 1;
    }
  }

  void _onAnimation() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: ColorTween(
              begin: const Color(0xFFFFFFFF), end: const Color(0xFF000000))
          .lerp(widget.animation!.value),
      systemNavigationBarDividerColor: null,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  void _onAnimationStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        _currentPage!.value = _pageController!.page!.round() + 1;
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: <SystemUiOverlay>[SystemUiOverlay.bottom]);
        break;

      case AnimationStatus.reverse:
        _currentPage!.value = null;
        break;
    }
  }

  @override
  void dispose() {
    widget.animation?.removeListener(_onAnimation);
    widget.animation?.removeStatusListener(_onAnimationStatus);
    _currentPage = null;
    _pageController?.dispose();
    _pageController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      final List<String> photos = widget.photos;
      final int photoLength = photos.length;
      final Size screenSize = MediaQuery.of(context).size;
      final bool isFitWidth = screenSize.width <= screenSize.height;
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Center(
                child: Hero(
              tag: '${photos[widget.initialIndex]}_${widget.initialIndex}',
              createRectTween: (Rect? begin, Rect? end) {
                // return MaterialRectArcTween(begin: begin, end: end);
                return MaterialRectCenterArcTween(begin: begin, end: end);
              },
              child: ExtendedImageGesturePageView.builder(
                itemBuilder: (BuildContext context, int index) {
                  final String imageUrl = photos[index];

                  final Widget child = ExtendedImage.network(
                    imageUrl,
                    fit: BoxFit.contain,//isFitWidth ? BoxFit.fitWidth : BoxFit.fitHeight,
                    cache: true,
                    mode: ExtendedImageMode.gesture,
                    filterQuality: FilterQuality.high,
                    initGestureConfigHandler: (ExtendedImageState state) {
                      return GestureConfig(
                        minScale: 0.2,
                        animationMinScale: 0.2,
                        maxScale: 5.0,
                        animationMaxScale: 5,
                        speed: 1.0,
                        inertialSpeed: 100.0,
                        initialScale: 1.0,
                        cacheGesture: false,
                        inPageView: true,
                        initialAlignment: InitialAlignment.center,
                      );
                    },
                    /*loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.completed:
                          return ExtendedRawImage(
                            image: state.extendedImageInfo?.image,
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
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
                    },*/
                  );
                  return child;
                },
                itemCount: photoLength,
                onPageChanged: (int index) {
                  _currentPage!.value = index + 1;
                },
                controller: _pageController!,
                scrollDirection: Axis.horizontal,
              ),
            )),
            ObWidget<int>(
              builder: (Observer<int>? observer) {
                final int? currentPage = observer?.value;
                return currentPage == null
                    ? const SizedBox()
                    : Positioned(
                        bottom: 86.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32.w, vertical: 16.w),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            child: Text(
                              '$currentPage/$photoLength',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32.sp,
                              ),
                            ),
                          ),
                        ),
                      );
              },
              observer: _currentPage!,
            )
          ],
        ),
      );
    });
  }
}
