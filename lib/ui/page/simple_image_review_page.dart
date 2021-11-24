import 'package:cached_network_image/cached_network_image.dart';
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

  PageController? _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPage = Observer<int>(null);

    if (widget.animation != null) {
      widget.animation!.addStatusListener(_onAnimationStatus);
    } else {
      _currentPage!.value = widget.initialIndex + 1;
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        _currentPage!.value = _pageController!.page!.round() + 1;
        break;

      case AnimationStatus.reverse:
        _currentPage!.value = null;
        break;
    }
  }

  @override
  void dispose() {
    widget.animation?.removeStatusListener(_onAnimationStatus);
    _currentPage = null;
    _pageController?.dispose();
    _pageController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: <SystemUiOverlay>[SystemUiOverlay.bottom]);
    final List<String> photos = widget.photos;
    final int photoLength = photos.length;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Hero(
                tag: '${photos[widget.initialIndex]}_${widget.initialIndex}',
                child: PageView.builder(
                  controller: _pageController!,
                  itemBuilder: (BuildContext context, int index) {
                    final String imageUrl = photos[index];
                    // 这里可以解析imageUrl使用不同的image widget，目前只用network widget

                    final Widget child = CachedNetworkImage(
                      imageUrl: imageUrl,
                      imageBuilder:
                          (BuildContext context, ImageProvider imageProvider) =>
                              Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fitWidth,
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
                          Container(
                        color: Colors.grey,
                        child: Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 88.w,
                        ),
                      ),
                    );

                    return child;
                  },
                  itemCount: photoLength,
                  onPageChanged: (int index) {
                    _currentPage!.value = index + 1;
                  },
                ),
              ),
            ),
          ),
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
            initialValue: _currentPage!,
          )
        ],
      ),
    );
  }
}
