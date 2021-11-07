import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mileage_wash/common/http/http_result.dart';
import 'package:mileage_wash/common/http/http_utils.dart';
import 'package:mileage_wash/constant/http_apis.dart';
import 'package:mileage_wash/model/http/upload_result.dart';

class UploadDao {
  UploadDao._();

  static Future<UploadResult> uploadPhoto({
    required String type,
    required File file,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    final Response<HttpResult> response =
        await HttpUtil.uploadFile<HttpResult>(HTTPApis.upload, file,
            data: <String, dynamic>{
              'type': type,
            },
            cancelToken: cancelToken,
            onSendProgress: onSendProgress);

    final HttpResult httpResult = response.data!;

    final Map<String, dynamic> uploadResultData =
        httpResult.data as Map<String, dynamic>;

    final UploadResult uploadResult =
        UploadResult.fromJson(uploadResultData, type);

    return uploadResult;
  }
}
