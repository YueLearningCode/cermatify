# Cermatify

Cermatify adalah aplikasi Flutter untuk layanan akademik/digital seperti dashboard pengguna, kuesioner, paperlink, sourcelink, complink, order, chat, profil, serta halaman admin untuk dashboard, kuesioner, order, dan withdraw.

Cermatify bisa dipahami sebagai aplikasi mobile berbasis Flutter yang mempertemukan mahasiswa yang membutuhkan bantuan akademik dengan mentor atau mahasiswa lain yang punya kemampuan relevan. Layanannya berfokus pada tiga produk utama: Cermat Paper, Cermat Competition, dan Cermat Kuesioner.

Secara teknis, Cermatify adalah aplikasi mobile berbasis Flutter yang menggunakan Node.js sebagai backend, Google Cloud sebagai infrastruktur server, dan firebase sebagai database. Flutter digunakan untuk membangun antarmuka aplikasi di sisi pengguna, sedangkan backend bertugas mengelola proses bisnis seperti login, pemilihan layanan, pencocokan mentor, transaksi, dan evaluasi layanan. Data pengguna, mentor, layanan, dan transaksi disimpan secara terstruktur di firebase, sementara keamanan data didukung dengan SSL/TLS.

Secara administrasi, Cermatify memiliki alur operasional mulai dari pendaftaran dan verifikasi pengguna, pemilihan layanan, proses kolaborasi antara pengguna dan mentor, transaksi digital, hingga evaluasi layanan. Admin berperan mengelola data pengguna, mentor, layanan, transaksi, verifikasi, serta menjaga kualitas layanan melalui pemantauan dan evaluasi. Dengan demikian, sistem tidak hanya berjalan sebagai aplikasi teknologi, tetapi juga sebagai ekosistem layanan akademik yang memerlukan tata kelola operasional.

Proyek ini memakai pola GetX. Di dalam setiap fitur biasanya ada 3 bagian:

- `bindings`: mendaftarkan controller/dependency ke GetX.
- `controllers`: menyimpan state, validasi, dan logika fitur.
- `views`: tampilan UI yang dilihat pengguna.

## Status Analisis

Proyek ini adalah proyek Flutter app yang lengkap secara struktur karena memiliki `pubspec.yaml`, `lib/main.dart`, konfigurasi Android, iOS, Web, Windows, macOS, dan Linux.

Namun pada komputer yang dianalisis, perintah `flutter --version` gagal karena `flutter` belum dikenali di PATH. Artinya proyek belum bisa saya jalankan langsung dari terminal ini sampai Flutter SDK dipasang atau path Flutter ditambahkan ke environment variable.

Setelah Flutter SDK tersedia, proyek ini seharusnya bisa dicoba dengan alur standar:

```bash
cd E:\laragon\www\cermatify\cermatify
flutter pub get
flutter run
```

Catatan penting:

- Proyek membutuhkan koneksi internet saat `flutter pub get` pertama kali karena paket diambil dari `pub.dev`.
- Proyek memakai Firebase dan backend API online, sehingga fitur login/data membutuhkan koneksi internet.
- Linux belum dikonfigurasi untuk Firebase pada `lib/firebase_options.dart`, jadi target Linux akan error jika menjalankan kode Firebase saat startup.

## Spesifikasi Project

| Bagian | Nilai |
| --- | --- |
| Nama package | `cermatify` |
| Tipe proyek | Flutter application |
| Versi aplikasi | `1.0.0+1` |
| Dart SDK | `>=3.8.1 <4.0.0` |
| Flutter minimum dari lockfile | `>=3.32.0` |
| Flutter channel saat proyek dibuat | `stable` |
| State management dan routing | GetX |
| Backend API | `https://cermatify.my.id/api/v1` |
| Base URL gambar | `https://cermatify.my.id/` |
| Firebase project id | `cermatify` |
| Android application id | `com.example.cermatify` |
| Android minSdk | `23` |
| Android Java/Kotlin target | Java 11 |
| Android NDK | `27.0.12077973` |
| Gradle wrapper | `8.12` |
| iOS bundle id | `com.example.cermatify` |
| Font tema aplikasi | `Poppins` |

## Dependency Utama

Dependency berikut diambil dari `pubspec.yaml` dan versi terkunci di `pubspec.lock`.

| Package | Fungsi | Versi terkunci |
| --- | --- | --- |
| `get` | Routing, dependency injection, state management | `4.7.2` |
| `firebase_core` | Inisialisasi Firebase | `4.2.1` |
| `firebase_auth` | Autentikasi Firebase | `6.1.2` |
| `cloud_firestore` | Database Firestore | `6.1.0` |
| `dio` | HTTP client | `5.9.0` |
| `http` | HTTP client tambahan | `1.6.0` |
| `pretty_dio_logger` | Logging request/response Dio | `1.4.0` |
| `flutter_secure_storage` | Penyimpanan aman untuk token/data sensitif | `9.2.4` |
| `shared_preferences` | Penyimpanan lokal sederhana | `2.5.3` |
| `image_picker` | Memilih gambar dari galeri/kamera | `1.2.1` |
| `cloudinary` | Integrasi upload/media Cloudinary | `1.2.0` |
| `fl_chart` | Grafik/chart | `0.71.0` |
| `google_fonts` | Font dari Google Fonts | `6.3.2` |
| `intl` | Format tanggal/angka/lokalisasi | `0.20.2` |
| `flutter_svg` | Menampilkan SVG | `2.2.2` |
| `flutter_spinkit` | Loading indicator | `5.2.2` |
| `shimmer` | Skeleton/loading shimmer | `3.0.0` |
| `url_launcher` | Membuka URL/link eksternal | `6.3.2` |
| `qr_flutter` | Generate QR code | `4.1.0` |
| `flutter_launcher_icons` | Generate icon aplikasi | `0.14.4` |
| `flutter_lints` | Aturan lint Flutter | `5.0.0` |

## Cara Menjalankan

### 1. Pasang Flutter SDK

Install Flutter SDK minimal versi `3.32.0`. Setelah itu pastikan command ini berjalan:

```bash
flutter --version
dart --version
```

Jika di Windows command `flutter` belum dikenali, tambahkan folder `flutter\bin` ke PATH.

### 2. Masuk ke folder proyek

```bash
cd E:\laragon\www\cermatify\cermatify
```

### 3. Ambil dependency

```bash
flutter pub get
```

### 4. Cek device yang tersedia

```bash
flutter devices
```

### 5. Jalankan aplikasi

Android emulator/device:

```bash
flutter run
```

Web browser:

```bash
flutter run -d chrome
```

Windows desktop:

```bash
flutter run -d windows
```

### 6. Build release Android

APK debug/release umum:

```bash
flutter build apk
```

App bundle untuk Play Store:

```bash
flutter build appbundle
```

Catatan release Android:

- File `android/app/build.gradle.kts` membaca `android/key.properties` untuk signing release.
- File `key.properties` tidak ada di repository ini. Jika ingin build release signed, buat file tersebut dan isi `keyAlias`, `keyPassword`, `storeFile`, dan `storePassword`.

## Deploy Web ke GitHub Pages

Project ini sudah disiapkan untuk deploy Flutter Web ke GitHub Pages melalui workflow:

```text
.github/workflows/deploy-web.yml
```

Setiap kali branch `main` di-push ke GitHub, workflow akan:

1. Menginstal Flutter `3.44.4` stable.
2. Menjalankan `flutter pub get`.
3. Menjalankan `flutter analyze --no-fatal-infos --no-fatal-warnings`.
4. Build web dengan base href `/cermatify/`.
5. Mengupload hasil `build/web` ke GitHub Pages.

Di GitHub repository, aktifkan Pages melalui:

```text
Settings -> Pages -> Build and deployment -> Source: GitHub Actions
```

Setelah workflow berhasil, aplikasi web biasanya tersedia di:

```text
https://yuelearningcode.github.io/cermatify/
```

## Cara Mengecek Kualitas Project

Setelah Flutter tersedia:

```bash
flutter pub get
flutter analyze
flutter test
```

Saat analisis ini dibuat, saya belum bisa menjalankan command tersebut karena Flutter SDK belum tersedia di PATH komputer ini.

## Alur Aplikasi

Entry point aplikasi ada di `lib/main.dart`.

Alur startup:

1. Flutter binding diinisialisasi.
2. Firebase diinisialisasi memakai `DefaultFirebaseOptions.currentPlatform`.
3. Format tanggal Indonesia `id_ID` diinisialisasi.
4. Aplikasi menjalankan `GetMaterialApp`.
5. Route awal adalah `Routes.LOGIN`.
6. Daftar route didefinisikan di `lib/app/routes/app_pages.dart`.

Route utama:

| Route | Halaman |
| --- | --- |
| `/login` | Login |
| `/register` | Register |
| `/home` | Home |
| `/dashboard` | Dashboard pengguna |
| `/admin-dashboard` | Dashboard admin |
| `/chat` | Chat |
| `/profile` | Profil |
| `/kuesioner` | Kuesioner |
| `/faq` | FAQ |
| `/paperlink` | Paperlink |
| `/complink` | Complink |
| `/sourcelink` | Sourcelink |
| `/order-history` | Riwayat order |
| `/admin-kuesioner` | Manajemen kuesioner admin |

## Struktur Folder

| Folder | Penjelasan |
| --- | --- |
| `.idea/` | Konfigurasi IDE JetBrains/Android Studio. Tidak berisi logika aplikasi. |
| `.vscode/` | Konfigurasi Visual Studio Code. Tidak berisi logika aplikasi. |
| `android/` | Project native Android untuk build APK/AAB, konfigurasi Gradle, manifest, icon, dan Firebase Android. |
| `assets/` | Gambar dan asset statis yang didaftarkan di `pubspec.yaml`. |
| `ios/` | Project native iOS untuk build lewat Xcode, termasuk konfigurasi Firebase iOS. |
| `lib/` | Kode utama aplikasi Flutter/Dart. Ini folder terpenting untuk dipelajari. |
| `linux/` | Project native Linux desktop hasil template Flutter. Firebase belum dikonfigurasi untuk Linux. |
| `macos/` | Project native macOS desktop, termasuk konfigurasi Firebase macOS. |
| `web/` | File pendukung Flutter Web seperti `index.html`, manifest, favicon, dan icon PWA. |
| `windows/` | Project native Windows desktop hasil template Flutter. |

## File Root Project

| File | Penjelasan |
| --- | --- |
| `.gitignore` | Daftar file/folder yang tidak perlu masuk Git, seperti build output dan file lokal. |
| `.metadata` | Metadata Flutter, termasuk revision Flutter stable saat proyek dibuat. Jangan diedit manual. |
| `analysis_options.yaml` | Konfigurasi lint/analyzer Dart. Proyek memakai aturan dari `flutter_lints`. |
| `cermatify.iml` | File modul IDE IntelliJ/Android Studio. |
| `firebase.json` | Konfigurasi Firebase CLI untuk project ini. |
| `pubspec.yaml` | File utama konfigurasi Flutter: nama project, versi app, SDK, dependency, dan asset. |
| `pubspec.lock` | Versi pasti semua dependency yang terkunci setelah `flutter pub get`. |
| `README.md` | Dokumentasi project yang sedang kamu baca. |
| `.DS_Store` | File metadata macOS. Aman diabaikan dan sebaiknya tidak dijadikan bahan belajar Flutter. |

## File Konfigurasi IDE

| File | Penjelasan |
| --- | --- |
| `.idea/modules.xml` | Konfigurasi modul project untuk Android Studio/IntelliJ. |
| `.idea/workspace.xml` | Konfigurasi workspace lokal IDE. Biasanya spesifik komputer pengguna. |
| `.idea/libraries/Dart_SDK.xml` | Referensi Dart SDK pada Android Studio/IntelliJ. |
| `.idea/libraries/KotlinJavaRuntime.xml` | Referensi runtime Kotlin/Java pada Android Studio/IntelliJ. |
| `.idea/runConfigurations/main_dart.xml` | Konfigurasi run untuk menjalankan `lib/main.dart` dari IDE. |
| `.idea/.DS_Store` | Metadata macOS di folder IDE. Tidak dipakai Flutter. |
| `.vscode/settings.json` | Pengaturan VS Code untuk project ini. |

## Folder dan File `lib/`

### File utama

| File | Penjelasan |
| --- | --- |
| `lib/main.dart` | Entry point aplikasi. Menginisialisasi Firebase, format tanggal Indonesia, dan menjalankan `GetMaterialApp`. |
| `lib/firebase_options.dart` | Konfigurasi Firebase hasil FlutterFire CLI untuk Web, Android, iOS, macOS, dan Windows. Linux belum dikonfigurasi. |
| `lib/.DS_Store` | Metadata macOS. Tidak berpengaruh pada aplikasi. |

### Routing

| File | Penjelasan |
| --- | --- |
| `lib/app/routes/app_pages.dart` | Mendaftarkan semua halaman GetX, route, view, dan binding. |
| `lib/app/routes/app_routes.dart` | Konstanta nama route. File ini diberi catatan generated by Get CLI. |

### Data, service, model, tema, dan widget umum

| File | Penjelasan |
| --- | --- |
| `lib/app/data/constants/api_constant.dart` | Menyimpan base URL API dan base URL gambar. |
| `lib/app/data/dummy_chats.dart` | Data dummy untuk chat. |
| `lib/app/data/dummy_kuesioner.dart` | Data dummy untuk kuesioner. |
| `lib/app/data/dummy_mentors.dart` | Data dummy untuk mentor. |
| `lib/app/data/dummy_pacomp.dart` | Data dummy untuk fitur/komponen PAComp. |
| `lib/app/data/dummy_sourcelink.dart` | Data dummy untuk Sourcelink. |
| `lib/app/data/models/chat_model.dart` | Model data chat. |
| `lib/app/data/models/kuesioner_model.dart` | Model data kuesioner. |
| `lib/app/data/models/mentor_model.dart` | Model data mentor. |
| `lib/app/data/models/user_model.dart` | Model data user. |
| `lib/app/data/models/withdraw_model.dart` | Model data withdraw/penarikan. |
| `lib/app/data/providers/auth_provider.dart` | Provider untuk operasi autentikasi atau komunikasi data auth. |
| `lib/app/data/repositories/auth_repository.dart` | Repository auth sebagai lapisan penghubung antara controller dan provider/service. |
| `lib/app/data/services/auth_service.dart` | Service autentikasi, biasanya untuk token/session/user login. |
| `lib/app/data/services/http_service.dart` | Konfigurasi HTTP client untuk request API. |
| `lib/app/data/theme/app_colors.dart` | Konstanta warna aplikasi. |
| `lib/app/data/theme/app_formats.dart` | Helper format data, misalnya format tanggal/angka/mata uang. |
| `lib/app/data/theme/app_styles.dart` | Konstanta style teks atau komponen visual. |
| `lib/app/data/widgets/admin_bottom_navbar.dart` | Bottom navigation khusus admin. |
| `lib/app/data/widgets/bottom_navbar.dart` | Bottom navigation untuk pengguna. |
| `lib/app/data/widgets/custom_button.dart` | Komponen tombol custom utama. |
| `lib/app/data/widgets/custom_button_simple.dart` | Komponen tombol custom sederhana. |
| `lib/app/data/widgets/custom_category_tabs.dart` | Komponen tab kategori. |
| `lib/app/data/widgets/custom_item_setting.dart` | Komponen item menu pengaturan. |
| `lib/app/data/widgets/custom_kategori_item.dart` | Komponen item kategori. |
| `lib/app/data/widgets/custom_padding.dart` | Helper/komponen padding yang dipakai ulang. |
| `lib/app/data/widgets/custom_row.dart` | Komponen row custom yang dipakai ulang. |
| `lib/app/data/widgets/custom_shimmer.dart` | Komponen loading shimmer. |
| `lib/app/data/widgets/custom_snackbar.dart` | Helper snackbar/notifikasi. |
| `lib/app/data/widgets/custom_text_input_formatter.dart` | Formatter input teks. |
| `lib/app/data/widgets/custom_textfield.dart` | Komponen text field custom. |
| `lib/app/data/widgets/custom_textformfield.dart` | Komponen text form field custom. |
| `lib/app/data/widgets/verification_status_dialog.dart` | Dialog status verifikasi. |

### Modul fitur

| Modul/File | Penjelasan |
| --- | --- |
| `admin_dashboard/bindings/admin_dashboard_binding.dart` | Binding controller dashboard admin. |
| `admin_dashboard/controllers/admin_dashboard_controller.dart` | Logika dashboard admin. |
| `admin_dashboard/views/admin_dashboard_view.dart` | UI dashboard admin. |
| `admin_home/bindings/admin_home_binding.dart` | Binding controller home admin. |
| `admin_home/controllers/admin_home_controller.dart` | Logika home admin. |
| `admin_home/views/admin_home_view.dart` | UI home admin. |
| `admin_kuesioner/bindings/admin_kuesioner_binding.dart` | Binding controller manajemen kuesioner admin. |
| `admin_kuesioner/controllers/admin_kuesioner_controller.dart` | Logika manajemen kuesioner admin. |
| `admin_kuesioner/views/admin_kuesioner_view.dart` | UI manajemen kuesioner admin. |
| `admin_orders/bindings/admin_orders_binding.dart` | Binding controller order admin. |
| `admin_orders/controllers/admin_orders_controller.dart` | Logika order admin. |
| `admin_orders/views/admin_orders_view.dart` | UI daftar/manajemen order admin. |
| `admin_withdraw/bindings/admin_withdraw_binding.dart` | Binding controller withdraw admin. |
| `admin_withdraw/controllers/admin_withdraw_controller.dart` | Logika verifikasi/kelola withdraw admin. |
| `admin_withdraw/views/admin_withdraw_view.dart` | UI withdraw admin. |
| `chat/bindings/chat_binding.dart` | Binding controller chat. |
| `chat/controllers/chat_controller.dart` | Logika chat, daftar chat, dan room chat. |
| `chat/views/chat_view.dart` | UI utama chat. |
| `chat/views/chat_list_view.dart` | UI daftar chat. |
| `chat/views/chat_room_view.dart` | UI ruang percakapan. |
| `complink/bindings/complink_binding.dart` | Binding controller Complink. |
| `complink/controllers/complink_controller.dart` | Logika fitur Complink. |
| `complink/views/complink_view.dart` | UI fitur Complink. |
| `dashboard/bindings/dashboard_binding.dart` | Binding controller dashboard pengguna. |
| `dashboard/controllers/dashboard_controller.dart` | Logika dashboard pengguna. |
| `dashboard/views/dashboard_view.dart` | UI dashboard pengguna. |
| `faq/bindings/faq_binding.dart` | Binding controller FAQ. |
| `faq/controllers/faq_controller.dart` | Logika FAQ. |
| `faq/views/faq_view.dart` | UI FAQ. |
| `group/bindings/group_binding.dart` | Binding controller group. |
| `group/controllers/group_controller.dart` | Logika group. |
| `group/views/group_view.dart` | UI group. |
| `home/bindings/home_binding.dart` | Binding controller home. |
| `home/controllers/home_controller.dart` | Logika home. |
| `home/views/home_view.dart` | UI home. |
| `kuesioner/bindings/kuesioner_binding.dart` | Binding controller kuesioner. |
| `kuesioner/controllers/kuesioner_controller.dart` | Logika utama kuesioner. |
| `kuesioner/controllers/create_kuesioner_controller.dart` | Logika membuat kuesioner. |
| `kuesioner/views/kuesioner_view.dart` | UI daftar/fitur kuesioner. |
| `kuesioner/views/create_kuesioner_view.dart` | UI membuat kuesioner. |
| `kuesioner/views/data_user_kuesioner_view.dart` | UI data user terkait kuesioner. |
| `kuesioner/views/kuesioner_detail_view.dart` | UI detail kuesioner. |
| `kuesioner/views/kuesioner_payment_dialog_view.dart` | Dialog pembayaran kuesioner. |
| `login/bindings/login_binding.dart` | Binding controller login. |
| `login/controllers/login_controller.dart` | Logika login. |
| `login/views/login_view.dart` | UI login. |
| `master_data/bindings/master_data_binding.dart` | Binding controller master data. |
| `master_data/controllers/master_data_controller.dart` | Logika master data. |
| `master_data/views/master_data_view.dart` | UI master data. |
| `order/bindings/order_binding.dart` | Binding controller order. |
| `order/controllers/order_controller.dart` | Logika order. |
| `order/controllers/order_history_controller.dart` | Logika riwayat order. |
| `order/views/order_view.dart` | UI order. |
| `order/views/order_dialog_view.dart` | Dialog order. |
| `order/views/order_history_view.dart` | UI riwayat order. |
| `paperlink/bindings/paperlink_binding.dart` | Binding controller Paperlink. |
| `paperlink/controllers/paperlink_controller.dart` | Logika Paperlink. |
| `paperlink/views/paperlink_view.dart` | UI Paperlink. |
| `paperlink/views/list_mentor_view.dart` | UI daftar mentor. |
| `paperlink/views/detail_mentor_view.dart` | UI detail mentor. |
| `profile/bindings/profile_binding.dart` | Binding controller profil. |
| `profile/controllers/profile_controller.dart` | Logika profil. |
| `profile/controllers/withdraw_controller.dart` | Logika withdraw dari sisi pengguna. |
| `profile/views/profile_view.dart` | UI profil. |
| `profile/views/edit_profile_view.dart` | UI edit profil. |
| `profile/views/change_password_view.dart` | UI ubah password. |
| `profile/views/withdraw_dialog_view.dart` | Dialog withdraw. |
| `register/bindings/register_binding.dart` | Binding controller register. |
| `register/controllers/register_controller.dart` | Logika register. |
| `register/views/register_view.dart` | UI register. |
| `sourcelink/bindings/sourcelink_binding.dart` | Binding controller Sourcelink. |
| `sourcelink/controllers/sourcelink_controller.dart` | Logika Sourcelink. |
| `sourcelink/views/sourcelink_view.dart` | UI Sourcelink. |
| `sourcelink/views/sourcelink_submit_view.dart` | UI submit Sourcelink. |
| `splash/bindings/splash_binding.dart` | Binding controller splash. |
| `splash/controllers/splash_controller.dart` | Logika splash screen. |
| `splash/views/splash_view.dart` | UI splash screen. |
| `users/bindings/users_binding.dart` | Binding controller users/mentor. |
| `users/controllers/users_controller.dart` | Logika data users/mentor. |
| `users/views/users_view.dart` | UI daftar user/mentor. |
| `users/views/mentor_detail_view.dart` | UI detail mentor. |

## Folder `assets/`

Asset yang aktif didaftarkan di `pubspec.yaml`:

```yaml
assets:
  - assets/images/
  - assets/icons/
```

File yang ada:

| File | Penjelasan |
| --- | --- |
| `assets/images/banner1.jpg` | Banner gambar untuk UI. |
| `assets/images/banner2.jpg` | Banner gambar untuk UI. |
| `assets/images/banner3.jpg` | Banner gambar untuk UI. |
| `assets/images/facebook_logo.png` | Logo Facebook untuk tombol/login sosial. |
| `assets/images/google_logo.png` | Logo Google untuk tombol/login sosial. |
| `assets/images/logo.jpeg` | Logo aplikasi, juga dipakai untuk `flutter_launcher_icons`. |
| `assets/images/logo.png` | Logo aplikasi format PNG. |
| `assets/images/profile_dummy.jpg` | Gambar profil dummy/default. |
| `assets/images/qrqris.jpeg` | Gambar QRIS untuk pembayaran. |
| `assets/.DS_Store` | Metadata macOS. Tidak dipakai aplikasi. |

Catatan: `pubspec.yaml` juga mendaftarkan `assets/icons/`, tetapi pada hasil pemeriksaan tidak ada file icon yang terlihat di folder tersebut.

## Folder `android/`

| File/Folder | Penjelasan |
| --- | --- |
| `android/settings.gradle.kts` | Pengaturan Gradle multi-project Android. |
| `android/build.gradle.kts` | Konfigurasi Gradle level root Android. |
| `android/gradle.properties` | Properti Gradle/Android. |
| `android/gradle/wrapper/gradle-wrapper.properties` | Versi Gradle wrapper, yaitu Gradle `8.12`. |
| `android/app/build.gradle.kts` | Konfigurasi module Android app: application id, minSdk, signing, dependency native. |
| `android/app/google-services.json` | Konfigurasi Firebase Android. |
| `android/app/src/main/AndroidManifest.xml` | Manifest utama Android. |
| `android/app/src/debug/AndroidManifest.xml` | Manifest tambahan untuk build debug. |
| `android/app/src/profile/AndroidManifest.xml` | Manifest tambahan untuk build profile. |
| `android/app/src/main/kotlin/com/example/cermatify/MainActivity.kt` | Activity utama Android yang menjalankan Flutter. |
| `android/app/src/main/res/drawable/launch_background.xml` | Background launch screen Android lama. |
| `android/app/src/main/res/drawable-v21/launch_background.xml` | Background launch screen Android API 21+. |
| `android/app/src/main/res/values/styles.xml` | Style Android utama. |
| `android/app/src/main/res/values-night/styles.xml` | Style Android untuk mode gelap. |
| `android/app/src/main/res/mipmap-*/ic_launcher.png` | Icon launcher Android dalam berbagai density. |

## Folder `ios/`

| File/Folder | Penjelasan |
| --- | --- |
| `ios/Podfile` | Konfigurasi CocoaPods untuk dependency iOS Flutter. |
| `ios/Flutter/Debug.xcconfig` | Konfigurasi build Debug Flutter iOS. |
| `ios/Flutter/Release.xcconfig` | Konfigurasi build Release Flutter iOS. |
| `ios/Flutter/AppFrameworkInfo.plist` | Metadata framework Flutter untuk iOS. |
| `ios/Runner/AppDelegate.swift` | Entry native iOS sebelum masuk ke Flutter. |
| `ios/Runner/Info.plist` | Metadata aplikasi iOS. |
| `ios/Runner/GoogleService-Info.plist` | Konfigurasi Firebase iOS. |
| `ios/Runner/Runner-Bridging-Header.h` | Bridging header Swift/Objective-C. |
| `ios/Runner/Base.lproj/Main.storyboard` | Storyboard utama iOS. |
| `ios/Runner/Base.lproj/LaunchScreen.storyboard` | Launch screen iOS. |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` | Icon aplikasi iOS dalam berbagai ukuran. |
| `ios/Runner/Assets.xcassets/LaunchImage.imageset/*` | Gambar launch screen iOS. |
| `ios/Runner.xcodeproj/*` | File project Xcode. |
| `ios/Runner.xcworkspace/*` | Workspace Xcode/CocoaPods. |
| `ios/RunnerTests/RunnerTests.swift` | Template test native iOS. |

## Folder `web/`

| File/Folder | Penjelasan |
| --- | --- |
| `web/index.html` | HTML host untuk Flutter Web. |
| `web/manifest.json` | Manifest PWA Flutter Web. |
| `web/favicon.png` | Favicon web. |
| `web/icons/Icon-192.png` | Icon PWA 192px. |
| `web/icons/Icon-512.png` | Icon PWA 512px. |
| `web/icons/Icon-maskable-192.png` | Maskable icon PWA 192px. |
| `web/icons/Icon-maskable-512.png` | Maskable icon PWA 512px. |

## Folder `windows/`

| File/Folder | Penjelasan |
| --- | --- |
| `windows/CMakeLists.txt` | Konfigurasi CMake root untuk Windows desktop. |
| `windows/flutter/CMakeLists.txt` | Konfigurasi CMake Flutter Windows. |
| `windows/flutter/generated_plugin_registrant.cc` | Registrasi plugin Flutter Windows hasil generate. |
| `windows/flutter/generated_plugin_registrant.h` | Header registrasi plugin Flutter Windows. |
| `windows/flutter/generated_plugins.cmake` | Daftar plugin Windows yang dihasilkan Flutter. |
| `windows/runner/CMakeLists.txt` | Konfigurasi build runner Windows. |
| `windows/runner/main.cpp` | Entry point native Windows. |
| `windows/runner/flutter_window.cpp` | Implementasi window Flutter di Windows. |
| `windows/runner/flutter_window.h` | Header window Flutter. |
| `windows/runner/win32_window.cpp` | Implementasi window Win32. |
| `windows/runner/win32_window.h` | Header window Win32. |
| `windows/runner/utils.cpp` | Helper native Windows. |
| `windows/runner/utils.h` | Header helper native Windows. |
| `windows/runner/Runner.rc` | Resource script Windows. |
| `windows/runner/resource.h` | Konstanta resource Windows. |
| `windows/runner/runner.exe.manifest` | Manifest executable Windows. |
| `windows/runner/resources/app_icon.ico` | Icon aplikasi Windows. |

## Folder `macos/`

| File/Folder | Penjelasan |
| --- | --- |
| `macos/Podfile` | Konfigurasi CocoaPods untuk macOS. |
| `macos/Flutter/Flutter-Debug.xcconfig` | Konfigurasi build Debug Flutter macOS. |
| `macos/Flutter/Flutter-Release.xcconfig` | Konfigurasi build Release Flutter macOS. |
| `macos/Flutter/GeneratedPluginRegistrant.swift` | Registrasi plugin Flutter macOS. |
| `macos/Runner/AppDelegate.swift` | Entry native macOS. |
| `macos/Runner/MainFlutterWindow.swift` | Window utama Flutter macOS. |
| `macos/Runner/Info.plist` | Metadata aplikasi macOS. |
| `macos/Runner/GoogleService-Info.plist` | Konfigurasi Firebase macOS. |
| `macos/Runner/DebugProfile.entitlements` | Entitlement macOS untuk Debug/Profile. |
| `macos/Runner/Release.entitlements` | Entitlement macOS untuk Release. |
| `macos/Runner/Configs/*.xcconfig` | Konfigurasi build macOS. |
| `macos/Runner/Base.lproj/MainMenu.xib` | Menu/window dasar macOS. |
| `macos/Runner/Assets.xcassets/AppIcon.appiconset/*` | Icon aplikasi macOS. |
| `macos/Runner.xcodeproj/*` | File project Xcode macOS. |
| `macos/Runner.xcworkspace/*` | Workspace Xcode/CocoaPods macOS. |
| `macos/RunnerTests/RunnerTests.swift` | Template test native macOS. |

## Folder `linux/`

| File/Folder | Penjelasan |
| --- | --- |
| `linux/CMakeLists.txt` | Konfigurasi CMake root untuk Linux desktop. |
| `linux/flutter/CMakeLists.txt` | Konfigurasi CMake Flutter Linux. |
| `linux/flutter/generated_plugin_registrant.cc` | Registrasi plugin Flutter Linux hasil generate. |
| `linux/flutter/generated_plugin_registrant.h` | Header registrasi plugin Flutter Linux. |
| `linux/flutter/generated_plugins.cmake` | Daftar plugin Linux yang dihasilkan Flutter. |
| `linux/runner/CMakeLists.txt` | Konfigurasi build runner Linux. |
| `linux/runner/main.cc` | Entry point native Linux. |
| `linux/runner/my_application.cc` | Implementasi aplikasi GTK/Linux. |
| `linux/runner/my_application.h` | Header aplikasi GTK/Linux. |

## Hal yang Perlu Dipelajari Terlebih Dahulu

Urutan belajar yang disarankan:

1. `pubspec.yaml` untuk memahami dependency dan asset.
2. `lib/main.dart` untuk memahami startup aplikasi.
3. `lib/app/routes/app_pages.dart` dan `lib/app/routes/app_routes.dart` untuk memahami navigasi.
4. `lib/app/data/services/http_service.dart` dan `lib/app/data/constants/api_constant.dart` untuk memahami komunikasi API.
5. `lib/app/data/models/` untuk memahami bentuk data.
6. Satu modul sederhana seperti `login`, `register`, atau `faq` untuk memahami pola binding, controller, view.
7. Modul yang lebih kompleks seperti `kuesioner`, `order`, `profile`, dan `admin_*`.

## Catatan Kebersihan Project

Beberapa file/folder terlihat berasal dari macOS atau hasil ekstrak ZIP:

- `.DS_Store`
- `__MACOSX/`
- file dengan awalan `._` di folder `__MACOSX`

File tersebut tidak diperlukan untuk menjalankan Flutter. Untuk repository yang rapi, file-file itu biasanya dihapus dan dimasukkan ke `.gitignore`.
