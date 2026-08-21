import 'dart:typed_data';

import 'package:cermatify/app/data/models/selected_image_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('SelectedImageData', () {
    test('reads bytes and supplies a safe non-empty filename', () async {
      final file = XFile.fromData(Uint8List.fromList([1, 2, 3]), mimeType: 'image/png', name: 'proof payment?.png');

      final image = await SelectedImageData.fromXFile(file);

      expect(image.bytes, Uint8List.fromList([1, 2, 3]));
      expect(image.filename, isNotEmpty);
      expect(image.extension, 'jpg');
    });

    test('derives an extension from MIME type when filename has none', () {
      final image = SelectedImageData(
        bytes: Uint8List.fromList([1]),
        filename: 'browser-image',
        mimeType: 'image/png',
      );

      expect(image.extension, 'png');
    });

    test('rejects a non-image MIME type', () async {
      final file = XFile.fromData(Uint8List.fromList([1]), mimeType: 'text/plain', name: 'not-an-image.txt');

      await expectLater(SelectedImageData.fromXFile(file), throwsA(isA<FormatException>()));
    });

    test('rejects images larger than 5 MB', () async {
      final file = XFile.fromData(
        Uint8List(SelectedImageData.maxSizeInBytes + 1),
        mimeType: 'image/jpeg',
        name: 'large.jpg',
      );

      await expectLater(SelectedImageData.fromXFile(file), throwsA(isA<FormatException>()));
    });
  });
}
