# Audit REST API untuk Flutter Web

Tanggal audit: 24 Agustus 2026.

## Keputusan

REST API lama `https://cermatify.my.id/api/v1` tidak digunakan oleh aplikasi
aktif dan telah dihapus dari client Flutter. Fitur autentikasi dan data aplikasi
saat ini menggunakan Firebase secara langsung, sedangkan upload gambar
menggunakan Cloudinary melalui `MediaUploadService`.

## Bukti

- `AuthService`, `AuthRepository`, `AuthProvider`, dan `HttpService` tidak
  memiliki pemanggil dari controller, view, binding, maupun service aktif.
- `ApiConstant.baseUrl` hanya digunakan oleh `HttpService` yang tidak pernah
  dibuat oleh alur aplikasi aktif.
- Pemeriksaan DNS pada 24 Agustus 2026 menghasilkan `NXDOMAIN` untuk
  `cermatify.my.id`.
- Karena hostname tidak dapat di-resolve, request HTTPS dan preflight CORS
  `OPTIONS` tidak dapat mencapai server.

## Pembersihan

Komponen berikut dihapus:

- Konstanta `API_BASE_URL` dan `IMAGE_BASE_URL`.
- REST auth provider, repository, service, dan HTTP client lama.
- Model `UserModel` yang hanya digunakan oleh REST layer.
- Dependency `flutter_secure_storage` dan `pretty_dio_logger` yang tidak lagi
  memiliki pemakai.

Dependency `dio` tetap digunakan untuk restricted unsigned upload ke
Cloudinary.

## Dampak terhadap CORS

Konfigurasi CORS untuk API lama tidak diperlukan karena client tidak lagi
mengirim request ke domain tersebut. Jika REST API baru ditambahkan di masa
depan, backend wajib mengizinkan origin development dan production, menangani
preflight `OPTIONS`, serta mengizinkan header dan method yang benar-benar
digunakan aplikasi.
