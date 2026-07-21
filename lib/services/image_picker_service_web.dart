import 'dart:typed_data';

Future<Uint8List?> platformPickImage(
    {double? maxWidth, double? maxHeight, int? quality}) {
  throw UnsupportedError('Image picking is not supported on web');
}
