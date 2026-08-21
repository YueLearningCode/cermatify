import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Uploads public images with a restricted Cloudinary unsigned upload preset.
///
/// An unsigned preset is intentionally used here because a Flutter Web bundle
/// cannot safely contain a Cloudinary API secret. Configure and restrict the
/// preset in Cloudinary, then provide it at build/run time:
///
/// `--dart-define=CLOUDINARY_UPLOAD_PRESET=your_restricted_preset`
class MediaUploadService {
  MediaUploadService({Dio? dio}) : _dio = dio ?? Dio();

  static const String _cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'dvxsmpz3m',
  );
  static const String _uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
  );

  final Dio _dio;

  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (_uploadPreset.isEmpty) {
      throw StateError(
        'CLOUDINARY_UPLOAD_PRESET belum dikonfigurasi. '
        'Gunakan restricted unsigned upload preset; jangan masukkan API secret ke aplikasi.',
      );
    }

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'upload_preset': _uploadPreset,
    });

    final response = await _dio.post<Map<String, dynamic>>(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final secureUrl = response.data?['secure_url']?.toString();

    if (secureUrl == null || !secureUrl.startsWith('https://')) {
      throw StateError('Cloudinary tidak mengembalikan URL gambar yang valid.');
    }

    return secureUrl;
  }
}
