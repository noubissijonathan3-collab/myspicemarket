import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'image_picker_service_native.dart'
    if (dart.library.js_interop) 'image_picker_service_web.dart';

class ImagePickerService {
  static Future<Uint8List?> pickImage(
      {double? maxWidth, double? maxHeight, int? quality}) {
    return platformPickImage(maxWidth: maxWidth, maxHeight: maxHeight, quality: quality);
  }
}
