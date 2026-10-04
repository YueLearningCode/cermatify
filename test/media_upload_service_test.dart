import 'dart:typed_data';

import 'package:cermatify/app/data/services/media_upload_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'default project upload targets the cloud that owns flutter_upload',
    () async {
      final dio = Dio();
      addTearDown(dio.close);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(
              options.uri.toString(),
              'https://api.cloudinary.com/v1_1/rgovyuw1/image/upload',
            );
            expect(
              (options.data as FormData).fields.single.value,
              'flutter_upload',
            );
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'secure_url':
                      'https://res.cloudinary.com/rgovyuw1/image/upload/profile.png',
                },
              ),
            );
          },
        ),
      );
      final service = MediaUploadService(dio: dio);
      expect(
        await service.uploadImage(
          bytes: Uint8List.fromList([1]),
          filename: 'profile.png',
        ),
        'https://res.cloudinary.com/rgovyuw1/image/upload/profile.png',
      );
    },
  );

  test(
    'unsigned upload sends the configured cloud, preset and file only',
    () async {
      final dio = Dio();
      addTearDown(dio.close);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            expect(
              options.uri.toString(),
              'https://api.cloudinary.com/v1_1/test-cloud/image/upload',
            );
            final form = options.data as FormData;
            expect(form.fields.map((field) => field.key).toList(), [
              'upload_preset',
            ]);
            expect(form.fields.single.value, 'test-preset');
            expect(form.files.single.key, 'file');
            expect(form.files.single.value.filename, 'profile.png');
            final bytes = await form.files.single.value
                .finalize()
                .expand((chunk) => chunk)
                .toList();
            expect(bytes, [1, 2, 3]);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'secure_url':
                      'https://res.cloudinary.com/test-cloud/image/upload/profile.png',
                },
              ),
            );
          },
        ),
      );
      final service = MediaUploadService(
        dio: dio,
        cloudName: ' test-cloud ',
        uploadPreset: ' test-preset ',
      );
      final url = await service.uploadImage(
        bytes: Uint8List.fromList([1, 2, 3]),
        filename: 'profile.png',
      );
      expect(
        url,
        'https://res.cloudinary.com/test-cloud/image/upload/profile.png',
      );
    },
  );

  for (final reason in [
    'Upload preset not found',
    'Unknown API key',
    'Invalid image file',
  ]) {
    test('HTTP 400 exposes the actual provider reason: $reason', () async {
      final dio = Dio();
      addTearDown(dio.close);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 400,
                  data: {
                    'error': {'message': reason},
                  },
                ),
              ),
            );
          },
        ),
      );
      final service = MediaUploadService(dio: dio, uploadPreset: 'test-preset');
      await expectLater(
        service.uploadImage(
          bytes: Uint8List.fromList([1]),
          filename: 'profile.png',
        ),
        throwsA(
          isA<MediaUploadException>()
              .having(
                (error) => error.message,
                'provider reason',
                'Upload ditolak Cloudinary: $reason',
              )
              .having((error) => error.statusCode, 'status', 400),
        ),
      );
    });
  }

  test('provider error header is used when JSON body has no reason', () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 400,
                headers: Headers.fromMap({
                  'x-cld-error': ['Invalid image file'],
                }),
                data: <String, dynamic>{},
              ),
            ),
          );
        },
      ),
    );
    final service = MediaUploadService(dio: dio, uploadPreset: 'test-preset');
    await expectLater(
      service.uploadImage(
        bytes: Uint8List.fromList([1]),
        filename: 'profile.png',
      ),
      throwsA(
        isA<MediaUploadException>().having(
          (error) => error.message,
          'message',
          'Upload ditolak Cloudinary: Invalid image file',
        ),
      ),
    );
  });

  test('missing preset fails before sending a request', () async {
    final dio = Dio();
    addTearDown(dio.close);
    var requests = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests++;
          handler.resolve(
            Response(requestOptions: options, data: <String, dynamic>{}),
          );
        },
      ),
    );
    final service = MediaUploadService(dio: dio, uploadPreset: '');
    await expectLater(
      service.uploadImage(
        bytes: Uint8List.fromList([1]),
        filename: 'profile.png',
      ),
      throwsA(isA<MediaUploadException>()),
    );
    expect(requests, 0);
  });

  test('non-JSON server failure has a concise fallback', () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 502,
                data: '<html>error</html>',
              ),
            ),
          );
        },
      ),
    );
    final service = MediaUploadService(dio: dio, uploadPreset: 'test-preset');
    await expectLater(
      service.uploadImage(
        bytes: Uint8List.fromList([1]),
        filename: 'profile.png',
      ),
      throwsA(
        isA<MediaUploadException>().having(
          (error) => error.message,
          'message',
          'Upload gagal (HTTP 502). Silakan coba kembali.',
        ),
      ),
    );
  });

  test('connection failure does not show Dio internals', () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            ),
          );
        },
      ),
    );
    final service = MediaUploadService(dio: dio, uploadPreset: 'test-preset');
    await expectLater(
      service.uploadImage(
        bytes: Uint8List.fromList([1]),
        filename: 'profile.png',
      ),
      throwsA(
        isA<MediaUploadException>().having(
          (error) => error.message,
          'message',
          'Tidak dapat mengunggah gambar. Periksa koneksi lalu coba kembali.',
        ),
      ),
    );
  });
}
