# Todo Flutter Web Cermatify

Dokumen ini menjadi checklist utama untuk menyiapkan Cermatify versi web tanpa membuat ulang aplikasi. Kode aplikasi tetap berada di `lib/`, sedangkan `web/` digunakan untuk konfigurasi host browser dan PWA.

## Target rilis

Aplikasi dianggap siap dirilis ketika:

- Build web release berhasil tanpa error.
- Login, registrasi, dashboard, chat, profil, order, dan upload berjalan di browser.
- Tampilan nyaman digunakan pada mobile browser, tablet, laptop, dan desktop.
- Tidak ada credential rahasia di dalam bundle web.
- Hak akses customer, mentor, dan admin dilindungi oleh Firebase Rules atau backend.
- Deployment dapat dilakukan otomatis dan dapat diulang.

## P0 — Keamanan sebelum pengembangan lanjutan

- [ ] Rotate/revoke API secret Cloudinary yang pernah dimasukkan ke source code.
- [x] Hapus `apiSecret` Cloudinary dari seluruh kode Flutter.
- [x] Hapus signed upload yang menyimpan API secret di aplikasi klien.
- [x] Implementasikan dukungan restricted unsigned upload preset tanpa API secret.
- [ ] Buat dan batasi unsigned upload preset di dashboard Cloudinary.
- [x] Hapus log yang mencetak bearer token atau data autentikasi.
- [x] Tambahkan pola file credential lokal ke `.gitignore`.
- [x] Tambahkan draft Firestore Security Rules untuk role `customer`, `mentor`, dan `admin`.
- [x] Validasi sintaks Firestore Security Rules dengan Firebase Emulator.
- [x] Uji Firestore Security Rules menggunakan Firebase Emulator Suite.
- [x] Lindungi operasi admin melalui Firestore Rules, bukan hanya melalui tampilan atau route Flutter.

Kriteria selesai:

- Tidak ada `apiSecret`, private key, password, atau bearer token dalam source dan `build/web/main.dart.js`.
- Pengguna biasa tidak dapat membaca atau mengubah data admin melalui request langsung.

## P1 — Standarisasi Flutter dan dependency

- [x] Tentukan satu versi Flutter untuk lokal dan CI, yaitu `3.44.4`.
- [x] Tambahkan `.fvmrc` untuk mendokumentasikan versi Flutter yang wajib dipakai.
- [x] Selaraskan batas Dart SDK di `pubspec.yaml` dengan kebutuhan `pubspec.lock`.
- [x] Jalankan `flutter pub get` menggunakan versi Flutter yang telah ditetapkan.
- [x] Periksa dependency yang outdated atau tidak lagi dipakai.
- [x] Pertahankan target awal pada Flutter Web JavaScript; tunda Wasm sampai dependency kompatibel.

Kriteria selesai:

- Mesin developer dan GitHub Actions menggunakan versi Flutter yang sama.
- `flutter pub get` menghasilkan lockfile yang konsisten.

## P1 — Refactor upload agar lintas platform

- [x] Inventarisasi seluruh penggunaan `dart:io`, `File`, dan `Image.file`.
- [x] Ganti state file dari `File`/`Rxn<File>` menjadi model upload lintas platform.
- [x] Gunakan `await XFile.readAsBytes()` untuk membaca gambar.
- [x] Gunakan `Image.memory()` untuk preview gambar yang dipilih.
- [x] Ganti `MultipartFile.fromFile()` menjadi `MultipartFile.fromBytes()`.
- [x] Gunakan nama file multipart yang dibuat dan dibersihkan aplikasi.
- [x] Hilangkan pemeriksaan `existsSync()` pada alur browser.
- [x] Tambahkan validasi MIME type gambar.
- [x] Tambahkan batas ukuran file sebesar 5 MB.
- [x] Pertahankan kompresi/resize melalui konfigurasi `image_picker`.
- [x] Sembunyikan pilihan kamera pada web dan pertahankan galeri/file picker.
- [x] Refactor upload foto profil.
- [x] Refactor upload bukti pembayaran order.
- [x] Refactor upload bukti pembayaran kuesioner.
- [x] Refactor upload bukti pembayaran Sourcelink.

Kriteria selesai:

- Tidak ada import `dart:io` yang ikut dalam alur aplikasi web.
- Semua fitur upload dapat memilih, menampilkan preview, mengunggah, dan menghapus gambar melalui browser.
- Fitur yang sama tetap berjalan pada Android/iOS.

## P1 — Firebase Web

> Pending sementara sejak 24 Agustus 2026 karena Firebase tidak dapat diakses.
> Checklist yang memerlukan Console atau koneksi Firebase dilanjutkan setelah
> layanan tersedia kembali.

- [x] Verifikasi konfigurasi Firebase Web di `firebase_options.dart`.
- [ ] Tambahkan `localhost` ke Firebase Authorized Domains untuk development.
- [ ] Tambahkan `yuelearningcode.github.io` ke Firebase Authorized Domains.
- [ ] Tambahkan custom domain produksi jika akan digunakan.
- [ ] Uji login customer melalui browser.
- [ ] Uji login mentor dan status verifikasinya.
- [ ] Uji login admin dan proteksi datanya.
- [ ] Uji registrasi customer dan mentor.
- [ ] Uji persistence session setelah refresh dan browser ditutup.
- [ ] Uji logout dan pastikan session benar-benar dibersihkan.
- [x] Tambahkan bootstrap Firebase App Check reCAPTCHA v3 untuk web.
- [x] Tambahkan Auth persistence `LOCAL` untuk web.
- [ ] Daftarkan reCAPTCHA v3 dan aplikasi web pada Firebase App Check Console.
- [ ] Tambahkan GitHub Actions variable `FIREBASE_RECAPTCHA_SITE_KEY`.
- [ ] Pantau metrik, lalu aktifkan enforcement App Check di Firebase Console.
- [x] Uji Firestore Rules menggunakan Firebase Emulator atau Rules Playground.

Kriteria selesai:

- Seluruh role dapat login sesuai kewenangannya.
- Refresh halaman tidak merusak session.
- Request Firestore yang tidak sah ditolak oleh server.

## P1 — Backend API dan CORS

- [x] Putuskan REST API `cermatify.my.id/api/v1` tidak lagi digunakan.
- [x] Tandai pemulihan DNS/domain tidak berlaku karena REST API tidak digunakan.
- [x] Jika tidak digunakan, hapus service, repository, dependency, dan konstanta yang menjadi dead code.
- [x] Hapus override `API_BASE_URL` dan `IMAGE_BASE_URL` yang tidak lagi diperlukan.
- [x] Tandai konfigurasi CORS API lama tidak berlaku karena tidak ada request client.
- [x] Tandai header `Authorization` dan multipart API lama tidak berlaku.
- [x] Konfirmasi preflight tidak dapat dijalankan karena domain lama berstatus NXDOMAIN.
- [x] Pastikan error upload/network aktif ditampilkan melalui snackbar kepada pengguna.

Kriteria selesai:

- Tidak ada endpoint yang mengarah ke domain mati.
- Request browser tidak gagal karena DNS, mixed content, sertifikat, atau CORS.

## P2 — Responsive layout

- [x] Tetapkan breakpoint:
  - [x] Mobile: `< 600 px`.
  - [x] Tablet: `600–1023 px`.
  - [x] Desktop: `>= 1024 px`.
- [x] Buat widget layout/shell responsif yang digunakan bersama.
- [x] Pertahankan bottom navigation pada mobile dan tablet.
- [x] Gunakan `NavigationRail` pada desktop.
- [x] Batasi lebar konten utama hingga 1440 px.
- [x] Buat jumlah kolom fitur Home mengikuti lebar layar.
- [x] Audit `Row` pada tab utama dan pastikan konten teks memakai `Expanded`/scroll yang sesuai.
- [ ] Audit seluruh dialog pada layar pendek dan sempit.
- [ ] Sesuaikan tampilan chat menjadi list-room split view pada desktop jika diperlukan.
- [ ] Tambahkan hover state dan mouse cursor pada elemen interaktif.
- [ ] Pastikan semua fungsi dapat digunakan dengan keyboard.
- [ ] Tambahkan focus indicator yang terlihat.
- [ ] Uji layout pada lebar 320, 375, 768, 1024, 1366, dan 1920 px.
- [ ] Uji browser zoom 80%, 100%, 150%, dan 200%.

Kriteria selesai:

- Tidak ada overflow kuning/hitam.
- Konten tetap terbaca dan navigasi nyaman pada seluruh breakpoint.
- UI desktop tidak sekadar menampilkan layout mobile yang diperlebar.

## P2 — Konfigurasi folder `web/` dan PWA

- [x] Perbarui title dan meta description final.
- [x] Tambahkan meta viewport tanpa menonaktifkan zoom browser.
- [x] Verifikasi favicon dan seluruh icon PWA memakai logo Cermatify dan ukuran yang benar.
- [x] Hapus `orientation: portrait-primary` agar desktop dan landscape didukung.
- [x] Sesuaikan `theme_color` dan `background_color` dengan brand Cermatify.
- [x] Verifikasi `manifest.json` dapat dimuat tanpa error.
- [ ] Uji instalasi PWA.
- [ ] Uji service worker dan pembaruan versi setelah deployment baru.
- [x] Pertahankan strategi hash URL agar kompatibel dengan GitHub Pages tanpa rewrite server.
- [x] Tetapkan fallback 404 khusus tidak diperlukan selama menggunakan hash URL.

Kriteria selesai:

- Browser tidak melaporkan error manifest, icon, atau service worker.
- Aplikasi dapat dibuka kembali setelah update deployment tanpa cache rusak.

## P2 — Routing dan navigasi browser

- [ ] Uji seluruh named route GetX.
- [ ] Uji tombol Back dan Forward browser.
- [ ] Uji refresh pada halaman login, dashboard, profil, dan halaman detail.
- [ ] Pastikan route yang memerlukan login memiliki route guard/middleware.
- [ ] Pastikan customer atau mentor tidak dapat membuka route admin secara langsung.
- [ ] Tentukan halaman tujuan ketika session kedaluwarsa.
- [ ] Tambahkan halaman not-found yang sesuai.

Kriteria selesai:

- Refresh dan direct URL tidak menghasilkan halaman kosong atau 404.
- Protected route selalu memvalidasi session dan role.

## P2 — Quality gate dan testing

- [x] Selesaikan dua warning analyzer yang aktif.
- [ ] Kurangi deprecation dan info analyzer secara bertahap.
- [x] Hapus `--no-fatal-warnings` dari CI setelah warning bersih.
- [ ] Tentukan batas kualitas untuk info/deprecation.
- [ ] Tambahkan unit test untuk controller dan formatter penting.
- [ ] Tambahkan widget test untuk login, register, dan navigasi dashboard.
- [ ] Tambahkan integration test untuk alur login sampai logout.
- [ ] Tambahkan integration test untuk upload gambar.
- [ ] Tambahkan smoke test web untuk customer, mentor, dan admin.
- [ ] Uji Chrome, Edge, Firefox, dan Safari.

Kriteria selesai:

- `flutter analyze` tidak menghasilkan error atau warning.
- `flutter test` berhasil.
- Fitur kritis memiliki pengujian otomatis.

## P3 — CI/CD dan deployment

- [ ] Jalankan analyze, test, dan build web pada pull request.
- [ ] Pertahankan build release dengan base href `/cermatify/` selama memakai GitHub Pages repository tersebut.
- [ ] Aktifkan GitHub Pages dengan source GitHub Actions.
- [ ] Verifikasi permission workflow Pages.
- [ ] Tambahkan environment staging bila diperlukan.
- [ ] Simpan konfigurasi deployment non-publik sebagai GitHub Secrets.
- [ ] Deploy build staging.
- [ ] Jalankan smoke test setelah deployment.
- [ ] Dokumentasikan proses rollback.
- [ ] Deploy production setelah checklist penerimaan selesai.

Kriteria selesai:

- Push atau merge yang valid menghasilkan deployment yang dapat diakses.
- Deployment gagal otomatis jika analyze, test, atau build gagal.

## Checklist penerimaan akhir

- [ ] Landing page tampil dengan benar.
- [ ] Login dan registrasi semua role berhasil.
- [ ] Session bertahan setelah refresh.
- [ ] Dashboard customer berfungsi.
- [ ] Dashboard mentor berfungsi.
- [ ] Dashboard admin berfungsi dan terlindungi.
- [ ] Chat berfungsi pada dua akun/browser berbeda.
- [ ] Profil dapat dilihat dan diedit.
- [ ] Upload foto profil berhasil.
- [ ] Order dan upload bukti pembayaran berhasil.
- [ ] Kuesioner dan upload bukti pembayaran berhasil.
- [ ] Paperlink, Complink, dan Sourcelink berhasil.
- [ ] URL eksternal terbuka dengan benar.
- [ ] Tidak ada error penting di browser console.
- [ ] Tidak ada request gagal karena CORS atau DNS.
- [ ] Tidak ada credential rahasia di bundle.
- [ ] Tidak ada layout overflow pada breakpoint yang ditetapkan.
- [ ] Lighthouse accessibility dan best-practices mencapai target tim.
- [ ] Build production dan deployment berhasil.

## Perintah verifikasi

Jalankan dari root proyek Flutter:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href /cermatify/
```

Setelah build, hasil deployment berada di `build/web/`. Folder sumber `web/` tidak di-deploy sebagai aplikasi jadi tanpa melalui proses build Flutter.
