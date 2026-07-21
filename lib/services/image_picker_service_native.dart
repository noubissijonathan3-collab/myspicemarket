import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

const _channel = MethodChannel('com.example.myspicemarket/imagepicker');

Future<Uint8List?> platformPickImage(
    {double? maxWidth, double? maxHeight, int? quality}) async {
  try {
    final path = await _channel.invokeMethod<String>('pickImage');
    if (path == null) return null;
    return File(path).readAsBytes();
  } on PlatformException catch (e) {
    throw Exception('Failed to pick image: ${e.message}');
  }
}
