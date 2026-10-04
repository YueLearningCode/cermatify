import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'app_logger.dart';

class MediaUploadException implements Exception {
  const MediaUploadException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Uploads public images with a restricted Cloudinary unsigned upload preset.
///
/// An unsigned preset is intentionally used here because a Flutter Web bundle
/// cannot safely contain a Cloudinary API secret. The project defaults match
/// its unsigned preset; other environments can override them at build time:
///
/// `--dart-define=CLOUDINARY_UPLOAD_PRESET=your_restricted_preset`
class MediaUploadService {
  MediaUploadService({Dio? dio, String? cloudName, String? uploadPreset})
    : _dio = dio ?? Dio(),
      _configuredCloudName = (cloudName ?? _cloudName).trim(),
      _configuredUploadPreset = (uploadPreset ?? _uploadPreset).trim();

  static const String _cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'rgovyuw1',
  );
  static const String _uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'flutter_upload',
  );

  final Dio _dio;
  final String _configuredCloudName;
  final String _configuredUploadPreset;

  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (_configuredUploadPreset.isEmpty) {
      throw const MediaUploadException(
        'CLOUDINARY_UPLOAD_PRESET belum dikonfigurasi. '
        'Gunakan restricted unsigned upload preset; jangan masukkan API secret ke aplikasi.',
      );
    }

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'upload_preset': _configuredUploadPreset,
    });

    late final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        'https://api.cloudinary.com/v1_1/$_configuredCloudName/image/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      final providerError = data is Map ? data['error'] : null;
      final bodyMessage = providerError is Map
          ? providerError['message']
          : null;
      final detail = bodyMessage is String && bodyMessage.trim().isNotEmpty
          ? bodyMessage
          : error.response?.headers.value('x-cld-error');
      final message = detail is String && detail.trim().isNotEmpty
          ? 'Upload ditolak Cloudinary: ${detail.trim()}'
          : statusCode != null
          ? 'Upload gagal (HTTP $statusCode). Silakan coba kembali.'
          : 'Tidak dapat mengunggah gambar. Periksa koneksi lalu coba kembali.';
      // Log the provider reason, not the file contents or full request.
      AppLogger.info('Cloudinary upload gagal (HTTP $statusCode): $message');
      throw MediaUploadException(message, statusCode: statusCode);
    }
    final secureUrl = response.data?['secure_url']?.toString();

    if (secureUrl == null || !secureUrl.startsWith('https://')) {
      throw const MediaUploadException(
        'Cloudinary tidak mengembalikan URL gambar yang valid.',
      );
    }

    return secureUrl;
  }
}
