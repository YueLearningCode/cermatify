import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class SelectedImageData {
  const SelectedImageData({required this.bytes, required this.filename, this.mimeType});

  static const int maxSizeInBytes = 5 * 1024 * 1024;
  static const Set<String> _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'};

  final Uint8List bytes;
  final String filename;
  final String? mimeType;

  String get extension {
    final value = filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    if (_allowedExtensions.contains(value)) {
      return value;
    }

    return switch (mimeType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/heic' => 'heic',
      'image/heif' => 'heif',
      _ => 'jpg',
    };
  }

  static Future<SelectedImageData> fromXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    final filename = _safeFilename(file.name);
    final mimeType = file.mimeType?.toLowerCase();
    final extension = filename.contains('.') ? filename.split('.').last.toLowerCase() : '';

    if (bytes.isEmpty) {
      throw const FormatException('File gambar kosong.');
    }
    if (bytes.length > maxSizeInBytes) {
      throw const FormatException('Ukuran gambar maksimal 5 MB.');
    }
    if (mimeType != null && !mimeType.startsWith('image/')) {
      throw const FormatException('File yang dipilih bukan gambar.');
    }
    if (mimeType == null && !_allowedExtensions.contains(extension)) {
      throw const FormatException('Format gambar harus JPG, PNG, WebP, HEIC, atau HEIF.');
    }

    return SelectedImageData(bytes: bytes, filename: filename, mimeType: mimeType);
  }

  static String _safeFilename(String filename) {
    final sanitized = filename.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return sanitized.isEmpty ? 'image.jpg' : sanitized;
  }
}
