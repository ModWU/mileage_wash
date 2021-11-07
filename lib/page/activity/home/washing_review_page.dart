import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mileage_wash/common/listener/ob.dart';
import 'package:mileage_wash/common/util/text_utils.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/model/http/upload_result.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';
import 'package:mileage_wash/server/controller/home_controller.dart';
import 'package:mileage_wash/state/car_state.dart';
import 'package:mileage_wash/ui/utils/loading_utils.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';

class WashingReviewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WashingReviewPageState();
}

class _WashingReviewPageState extends State<WashingReviewPage> {
  late Size _appBarBottomTextSize;

  CarState? _carState = CarState.carWell;

  List<PhotoUploadProgress>? _photos;

  final GlobalKey _picturePickerKey = GlobalKey();

  final ImagePicker _picker = ImagePicker();

  late final OrderInfo _orderInfo;

  late final HomeNotifier _homeNotifier;

  final Observer<bool> _loading = false.ob;

  CancelToken? _saveOrderCancelToken;

  int get _photoLength => _photos?.length ?? 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appBarBottomTextSize = TextUtils.measureSize(_getAppBarBottomTextSpan,
        maxWidth: 1.sw - 22 * 2);

    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    assert(arguments.containsKey('orderInfo'));
    assert(arguments.containsKey('homeNotifier'));

    _orderInfo = arguments['orderInfo']! as OrderInfo;
    _homeNotifier = arguments['homeNotifier']! as HomeNotifier;
  }

  String get _httpRequestPhotoType {
    if (_homeNotifier is HomeWaitingNotifier) {
      return 'beginPhoto';
    } else if (_homeNotifier is HomeWashingNotifier) {
      return 'endPhoto';
    }

    throw 'homeNotifier type "${_homeNotifier.runtimeType}" error';
  }

  String get _httpRequestPhotoListType {
    if (_homeNotifier is HomeWaitingNotifier) {
      return 'beginPhoto';
    } else if (_homeNotifier is HomeWashingNotifier) {
      return 'endPhoto';
    }

    throw 'homeNotifier type "${_homeNotifier.runtimeType}" error';
  }

  TextSpan get _getAppBarBottomTextSpan {
    return TextSpan(
        text: S.of(context).washing_review_tip,
        style: TextStyle(color: Colors.grey, fontSize: 24.sp));
  }

  Text _getTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Future<void> _uploadPhoto(XFile photo, StateSetter setState) async {
    final PhotoUploadProgress photoUploadProgress =
        PhotoUploadProgress(photo, CancelToken());

    setState(() {
      _photos ??= <PhotoUploadProgress>[];
      _photos!.add(photoUploadProgress);

      _uploadPhotoToServer(photoUploadProgress);
    });
  }

  void _uploadPhotoToServer(PhotoUploadProgress photoUploadProgress,
      {CancelToken? cancelToken}) {
    if (cancelToken != null) {
      photoUploadProgress.updateCancelToken(CancelToken());
    }
    HomeController.uploadPhoto(
      context,
      type: _httpRequestPhotoType,
      file: photoUploadProgress.xFile,
      cancelToken: photoUploadProgress.cancelToken,
      allowThrowError: true,
      onSendProgress: (int count, int total) {
        if (mounted) {
          photoUploadProgress.value = count / total;
        }
      },
    ).then((UploadResult? uploadResult) {
      if (mounted) {
        photoUploadProgress.result = uploadResult!.photo;
      }
    }).catchError((Object error) {
      if (mounted) {
        photoUploadProgress.value = -1;
      }
    });
  }

  Widget _buildPicturePicker(BuildContext context, StateSetter setState) {
    return GestureDetector(
      onTap: () async {
        if (_photoLength >= 9) {
          ToastUtils.showToast(
              S.of(context).washing_review_car_pick_picture_limit_error);
          return;
        }

        try {
          final XFile? pickedFile = await _picker.pickImage(
            source: ImageSource.camera,
          );
          if (pickedFile != null) {
            _uploadPhoto(pickedFile, setState);
          }
        } catch (e) {
          ToastUtils.showToast(
              S.of(context).washing_review_car_pick_photo_error);
        }
      },
      child: Container(
        key: _picturePickerKey,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(6.w)),
          border: Border.all(width: 1, color: Colors.grey.withOpacity(0.4)),
        ),
        child: const Icon(
          Icons.add_a_photo_outlined,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildPhoto(BuildContext context, int index, StateSetter setState) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ObWidget<double>(
            builder: (Observer<double>? observer) {
              double progress = observer?.value ?? 0;
              return progress > 0
                  ? Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image.file(
                          File(_photos![index].xFile.path),
                          fit: BoxFit.cover,
                          frameBuilder: (BuildContext context, Widget child,
                              int? frame, bool wasSynchronouslyLoaded) {
                            if (frame == null) {
                              return Container(
                                color: Colors.black12,
                                child: UnconstrainedBox(
                                  child: SizedBox(
                                    width: 66.w,
                                    height: 66.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3.2.w,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                child,
                                Container(
                                  color: Colors.black
                                      .withOpacity(0.5 - 0.5 * progress),
                                ),
                              ],
                            );
                          },
                        ),
                        Ink(
                          color: Colors.black.withOpacity(0.5 - 0.5 * progress),
                        ),
                        if (progress < 1.0)
                          Center(
                            child: Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28.sp,
                              ),
                            ),
                          )
                      ],
                    )
                  : Container(
                      color: Colors.black12,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            S
                                .of(context)
                                .washing_review_car_photo_upload_fail_tip,
                            style:
                                TextStyle(fontSize: 24.sp, color: Colors.grey),
                          ),
                          SizedBox(height: 12.w),
                          GestureDetector(
                            onTap: () {
                              if (progress == -1) {
                                progress = -2;
                                _uploadPhotoToServer(_photos![index],
                                    cancelToken: CancelToken());
                              }
                            },
                            child: Icon(
                              Icons.refresh,
                              color: Colors.grey,
                              size: 46.w,
                            ),
                          ),
                        ],
                      ),
                    );
            },
            initialValue: _photos![index]),
        Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (!_photos![index].cancelToken.isCancelled) {
                    _photos![index].cancelToken.cancel();
                  }
                  _photos!.removeAt(index);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.all(Radius.circular(4.w)),
                ),
                padding: EdgeInsets.all(14.w),
                child: Icon(
                  Icons.close,
                  size: 32.w,
                  color: Colors.white70,
                ),
              ),
            )),
      ],
    );
  }

  @override
  void dispose() {
    if (_photos != null) {
      for (final PhotoUploadProgress photo in _photos!) {
        if (!photo.cancelToken.isCancelled) {
          photo.cancelToken.cancel();
        }
      }
      _photos = null;
    }

    if (_saveOrderCancelToken != null && !_saveOrderCancelToken!.isCancelled) {
      _saveOrderCancelToken!.cancel();
      _saveOrderCancelToken = null;
    }

    super.dispose();
  }

  bool get _isWaitingNotifier => _homeNotifier is HomeWaitingNotifier;

  Widget _buildWashReview() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_isWaitingNotifier)
                  _getTitle(S.of(context).washing_review_car_status_title),
                if (_isWaitingNotifier)
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: Colors.black,
                    ),
                    child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return Row(
                        children: <Widget>[
                          Radio<CarState>(
                            value: CarState.carWell,
                            groupValue: _carState,
                            onChanged: (CarState? value) {
                              setState(() {
                                _carState = value;
                              });
                            },
                          ),
                          Text(S.of(context).washing_review_car_status_well),
                          Radio<CarState>(
                            value: CarState.hasScratch,
                            groupValue: _carState,
                            onChanged: (CarState? value) {
                              setState(() {
                                _carState = value;
                              });
                            },
                          ),
                          Text(S.of(context).washing_review_car_status_scratch),
                          Radio<CarState>(
                            value: CarState.hasCollision,
                            groupValue: _carState,
                            onChanged: (CarState? value) {
                              setState(() {
                                _carState = value;
                              });
                            },
                          ),
                          Text(S
                              .of(context)
                              .washing_review_car_status_collision),
                        ],
                      );
                    }),
                  ),
                SizedBox(height: 12.h),
                _getTitle(S.of(context).washing_review_car_photo_upload_title),
                SizedBox(height: 18.h),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          S.of(context).washing_review_car_photo_upload_tip,
                          style: TextStyle(fontSize: 24.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 18.h),
                        Expanded(
                          child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return GridView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 20.0,
                                    crossAxisSpacing: 10.0,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: _photoLength + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index == _photoLength) {
                                      return _buildPicturePicker(
                                          context, setState);
                                    }
                                    return _buildPhoto(
                                        context, index, setState);
                                  });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 120.h, top: 28.h),
          child: TextButton(
            onPressed: _onSubmit,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16)),
              shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)))),
              minimumSize: MaterialStateProperty.all(Size(1.sw - 48.w, 0)),
            ),
            child: Text(
              S.of(context).washing_review_car_submit_button,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).washing_review_title,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_appBarBottomTextSize.height + 24.h),
          child: Container(
            height: _appBarBottomTextSize.height + 24.h,
            width: _appBarBottomTextSize.width,
            child: Text.rich(_getAppBarBottomTextSpan),
          ),
        ),
      ),
      body: LoadingUtils.build(child: _buildWashReview(), observer: _loading),
    );
  }

  void _onSubmit() {
    if (_photoLength <= 0) {
      ToastUtils.showToast(S.of(context).washing_review_car_submit_no_data);
      return;
    }

    final List<PhotoUploadProgress> photos = _photos!;

    final List<String> photoList = <String>[];

    for (final PhotoUploadProgress photo in photos) {
      final double progress = photo.value ?? 0;
      if (progress < 0) {
        ToastUtils.showToast(
            S.of(context).washing_review_car_submit_progress_error);
        return;
      } else if (progress < 1 || photo.result == null) {
        ToastUtils.showToast(
            S.of(context).washing_review_car_submit_progress_uploading_tip);
        return;
      }

      photoList.add(photo.result!);
    }

    assert(photoList.isNotEmpty);

    _saveOrderCancelToken = CancelToken();

    HomeController.saveOrder(context,
            orderInfo: _orderInfo,
            filePaths: photoList,
            allowThrowError: false,
            carState: _carState!,
            cancelToken: _saveOrderCancelToken,
            photoListType: _httpRequestPhotoListType)
        .then((_) {
      Navigator.of(context).pop();
    });
  }
}

class PhotoUploadProgress extends Observer<double> {
  PhotoUploadProgress(this.xFile, this.cancelToken) : super(0);

  final XFile xFile;
  late CancelToken cancelToken;
  String? result;

  void updateCancelToken(CancelToken value) {
    if (value == cancelToken) {
      return;
    }
    cancelToken = value;
  }
}
