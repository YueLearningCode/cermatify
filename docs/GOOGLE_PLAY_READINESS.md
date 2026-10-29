# Audit kesiapan Google Play — Cermatify

Tanggal pemeriksaan: 28 Oktober 2026. Package Android yang diminta: **`com.cermatify.app`**.

**Pembaruan:** audit di bawah mencatat baseline `1.0.0+1`. Persiapan berikutnya menambahkan dokumen legal, jalur permintaan hapus akun, Play Billing dan backend/ledger, serta kandidat `1.0.0+2`. Lihat [status persiapan terbaru](PLAY_STORE_RELEASE.md) dan `TODO_WEB.md`. Artefak pada path build yang sama dapat telah digantikan kandidat baru; hash baseline di bawah bukan hash kandidat terbaru. Pembayaran/operasi backend belum diaktifkan atau diuji melalui track Play; kesimpulan belum siap produksi tetap berlaku.

**Kesimpulan: belum siap diajukan untuk rilis publik.** Perubahan identitas selesai, AAB/APK rilis bertanda tangan berhasil dibuat, dan pemeriksaan teknis di bawah lulus. Kekurangan privasi, penghapusan akun, deklarasi Play Console, pembayaran dan penerimaan fitur perlu diselesaikan sebelum pengajuan produksi. Lulus build tidak sama dengan persetujuan Google Play.

## Identitas Android dan Firebase

- `applicationId` dan namespace: `com.cermatify.app`.
- Activity utama: `android/app/src/main/kotlin/com/cermatify/app/MainActivity.kt`.
- Proyek Firebase tetap `cermatify`; aplikasi Android baru didaftarkan dengan App ID `1:1083109793751:android:f1aa56860023933c093592`.
- `google-services.json` diunduh dari Firebase, dan Android `FirebaseOptions` serta metadata FlutterFire diselaraskan. Aplikasi Firebase lama tetap tersedia; tidak menghapus pengguna/data proyek.
- Plugin Google Services diaktifkan pada modul app agar konfigurasi native sesuai package.
- Izin `INTERNET` ditambahkan ke manifest utama. Sebelumnya izin hanya ada pada debug/profile, sehingga konfigurasi rilis perlu diperbaiki.
- Identitas iOS/macOS tidak diganti: permintaan ini khusus Android.
- Versi sumber saat audit: `1.0.0+1`. Pemilik mengonfirmasi belum pernah mengunggah Cermatify ke Google Play; pastikan version code belum dipakai ketika unggahan pertama dilakukan.

Package Firebase yang sudah terdaftar tidak dapat diubah; package baru membutuhkan registrasi Android app baru dalam proyek yang sama. [Firebase Android setup](https://firebase.google.com/docs/android/setup).

## Pemeriksaan teknis

| Pemeriksaan | Status dan bukti |
| --- | --- |
| Analisis Flutter | Lulus: `flutter analyze --no-pub`, tidak ada masalah. Log lokal: `build/play-readiness-analyze.log`. |
| Tes Flutter | Lulus: 186 tes. Log lokal: `build/play-readiness-flutter-test.log`. |
| SDK sumber/artefak | Flutter 3.44.4 menyediakan compile/target API 36 dan min SDK 24; SDK 36 terpasang. Manifest hasil dump AAB dan badging APK mengonfirmasi compile/target 36, min 24, versi 1.0.0/1 dan package `com.cermatify.app`. |
| Toolchain native | AGP 8.11.1, Kotlin 2.2.20, NDK 28.2.13676358. |
| Signing | Keystore dan private key rilis tersedia, bukan sertifikat debug; RSA 2048-bit/SHA384withRSA, sertifikat berlaku sampai 31 Maret 2053. Password tidak dicetak atau disimpan pada laporan. |
| AAB/APK rilis | Lulus build bertanda tangan. AAB lolos `bundletool validate` 1.18.3 dan `jarsigner -verify`; APK lolos `apksigner verify` dengan signature v2 dan fingerprint sesuai upload key. |
| 16 KB | Semua pustaka native 64-bit lolos pemeriksaan ELF alignment; bundle menyatakan `PAGE_ALIGNMENT_16K`, APK lolos `zipalign -c -P 16 -v 4`. Startup/halaman login rilis diperiksa pada emulator page size 16384, API 37/x86_64. |
| Manifest rilis | Izin INTERNET tersedia. Tidak ada flag debuggable atau izin broad READ_MEDIA_IMAGES/VIDEO, lokasi, kontak, mikrofon pada manifest artefak yang diperiksa. Izin lain: ACCESS_NETWORK_STATE, READ_GSERVICES dan permission internal dynamic receiver. |
| Penerimaan akun/transaksi | Belum diuji dengan akun nyata pada pemeriksaan ini; wajib dilanjutkan untuk customer, mentor, admin, order, chat, upload dan kuesioner. |

Google Play mewajibkan aplikasi baru/update ponsel menargetkan API 36 sejak 31 Agustus 2026. [Target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en). Kompatibilitas 16 KB diperiksa mengikuti [panduan Android](https://developer.android.com/guide/practices/page-sizes), dengan hasil build/ELF dan uji perangkat sebagai bukti terpisah.

### Artefak hasil pemeriksaan

| Artefak | Lokasi lokal | Ukuran / SHA-256 |
| --- | --- | --- |
| AAB untuk Google Play | `build/app/outputs/bundle/release/app-release.aab` | 67.696.770 byte; `70e8cacdd04fd608ebc1759d47055407fbaca223bce013ea6dea6b855893d530` |
| APK untuk instalasi/uji langsung | `build/app/outputs/flutter-apk/app-release.apk` | 69.068.908 byte; `8ec5240308417d0a50c436d71c12f6f47947da168dbdc89024e4bc1a46cd811c` |

Build AAB awal memerlukan sekitar 793 detik; APK berikutnya sekitar 75 detik. Pemeriksaan native mencakup 12 pustaka pada ABI arm64-v8a, armeabi-v7a dan x86_64. Semua pustaka 64-bit yang diperiksa memiliki PT_LOAD alignment minimal 16.384 byte; pustaka Flutter/app memakai 65.536 byte. Bundletool resmi diunduh dari rilis Google dan digest SHA-256 aset diverifikasi.

Log lokal: `build/play-release-aab.log`, `play-release-apk.log`, `play-bundle-validate.log`, `play-bundle-manifest.xml`, `play-bundle-config.json`, `play-bundle-signature.log`, `play-apk-signature.log`, `play-apk-zipalign.log`, `play-apk-badging.txt`, `play-native-aab.json` dan `play-native-apk.json`.

### Batas dan temuan selama pengujian

- Emulator yang sudah tersedia memakai Android API 37/x86_64 dengan page size 16 KB. Belum menguji perangkat fisik atau runtime ARM64; alignment ELF ARM64 diperiksa langsung pada artefak.
- Pada screenshot awal ada dialog **System UI isn't responding** dari emulator, sementara proses Cermatify tetap hidup. Setelah memilih Wait, dialog hilang; landing dan halaman login berhasil ditinjau, Firebase native mencatat initialization successful, dan log proses aplikasi tidak memuat FATAL EXCEPTION atau Unhandled Exception pada smoke test. Tidak menyamakan temuan System UI emulator dengan ANR Cermatify, tetapi pengujian perangkat nyata tetap diperlukan.
- Screenshot lokal: `build/play-release-startup.png` dan `build/play-release-login.png`. Tidak memasukkan kredensial atau membuat transaksi pada emulator.
- Build menampilkan peringatan/deprecation plugin serta kegagalan cache incremental Kotlin akibat source dan Pub Cache berada pada drive berbeda. Compiler menyelesaikan build melalui jalur fallback; hasil akhir AAB/APK sukses. Jangan menandai log bersih dari warning hanya karena build lulus.
- `jarsigner` melaporkan jar verified, dengan warning sertifikat self-signed/tanpa timestamp dan urutan pembacaan ZIP/JarInputStream. APK diverifikasi terpisah memakai apksigner; hasil penerimaan AAB akhir tetap ditentukan Google Play Console.

## Penghalang sebelum rilis publik

| Prioritas | Temuan | Yang harus diselesaikan |
| --- | --- | --- |
| P0 | Registrasi akun tersedia, tetapi jalur penghapusan akun/data belum ditemukan pada source/routing. | Sediakan jalur permintaan/penghapusan akun di aplikasi serta resource web untuk meminta penghapusan akun dan data terkait. Tentukan autentikasi ulang, data terkait, pengecualian retensi, dan proses backend yang dapat dibuktikan. |
| P0 | Halaman/tautan kebijakan privasi publik yang berlaku untuk aplikasi belum ditemukan pada source. Checkbox Syarat dan Ketentuan belum membuka dokumen. | Siapkan kebijakan privasi yang sesuai pemrosesan nyata, URL publik aktif dan dapat diakses tanpa login, serta tautkan di aplikasi dan Play Console. Selesaikan juga syarat/batas layanan yang sudah menjadi backlog produk. |
| P0 | Pembayaran QRIS/manual tersedia untuk mentoring dan pengajuan kuesioner. Kelayakan terhadap Google Play Payments belum dipetakan per produk. | Telaah apakah setiap SKU termasuk barang/jasa digital yang wajib Play Billing atau memenuhi pengecualian/program yang berlaku. Jangan menganggap semua layanan pendidikan otomatis dikecualikan. |
| P1 | Data safety, App access, rating konten, target usia, iklan dan deklarasi lain di Play Console belum diverifikasi. | Isi sesuai aplikasi/SDK dan operasi nyata. Sediakan akun uji serta instruksi peninjau agar fitur yang memerlukan login dapat ditinjau. |
| P1 | Uji fungsional menyeluruh rilis Android belum dilakukan. | Uji registrasi/login/logout, verifikasi mentor, sesi, upload/kamera/pemilih foto, order/pembayaran, chat, kuesioner dan perilaku koneksi gagal dengan data uji. |
| P1 | Daftar toko dan proses akun developer belum diverifikasi. | Lengkapi verifikasi identitas/kontak developer, nama/deskripsi aplikasi, icon toko, feature graphic, screenshot Android nyata dan detail bantuan. |
| P1 | Akun Play Console personal; tanggal pembuatan akun belum diketahui. | Jika akun dibuat setelah 13 November 2023, jalankan closed test minimum 12 tester yang terus opted-in selama 14 hari sebelum mengajukan akses produksi. Ikuti persyaratan aktual pada dashboard akun. |
| P1 | Kesiapan backend produksi dari backlog masih terpisah dari keberhasilan build. | Selesaikan hak akses, penanganan kegagalan parsial, transaksi/komisi, reward tervalidasi dan pekerjaan keamanan upload yang relevan sebelum menyatakan fitur aktif. |
| P1 | `kuesioner_controller.dart` mengganti daftar dengan `dummyKuesioner` saat query gagal. | Tampilkan keadaan gagal/kosong yang benar dan sediakan coba lagi; data contoh tidak boleh tampak sebagai data nyata saat jaringan/izin gagal. Opsi demografi statis dan gambar profil placeholder bukan temuan yang sama. |

Sumber kebijakan: [penghapusan akun](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en), [User Data/privasi](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en), [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en), [Payments](https://support.google.com/googleplay/android-developer/answer/10281818?hl=en-en), [testing akun personal](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en).

Pengecualian pembayaran layanan online 1:1 mensyaratkan layanan antara dua individu dan tidak tersedia untuk diputar/diakses ulang sesudahnya dalam aplikasi yang didistribusikan melalui Play. Pendampingan berbasis chat/review dan layanan penyebaran kuesioner perlu dipetakan berdasarkan perilaku sebenarnya; audit ini belum menetapkan pengecualian atau melakukan migrasi pembayaran.

## Bahan untuk Data safety

Informasi di bawah adalah inventaris source untuk membantu pengisian, bukan deklarasi final:

- Firebase Auth: akun login dan autentikasi.
- Firestore: profil nama/email/telepon, kampus/jurusan/semester, status role/mentor, pemesanan, data layanan dan percakapan.
- Cloudinary: foto profil dan bukti pembayaran yang diunggah; cocokkan retensi/penghapusan dan pengaturan akun pihak ketiga.
- Penarikan: nama serta nomor rekening/e-wallet tercantum pada model penarikan; periksa deklarasi informasi keuangan sesuai pemrosesan aktual.
- Alur kuesioner: data profil/demografi/kriteria responden dan tautan survei; bedakan data yang diproses Cermatify dengan formulir eksternal.
- Tinjau perilaku seluruh SDK yang benar-benar dipakai, lokasi pemrosesan, pembagian data, tujuan, retensi serta penghapusan. Penggunaan Firebase bukan alasan mengisi "tidak mengumpulkan data".

## Signing dan unggahan pertama

Gunakan AAB bertanda tangan untuk Google Play dan APK untuk instalasi/uji langsung. Pertahankan upload key yang sudah tersedia dan cadangkan secara aman; jangan commit `key.properties`, keystore atau password.

SHA-256 sertifikat upload yang diperiksa: `BE:2C:DF:E2:54:6A:3D:00:19:9A:3C:14:72:16:D7:50:21:8F:5A:4B:31:C8:C8:EA:14:FF:04:D3:AA:2E:D8:46`.

Ketika memakai Play App Signing, sertifikat aplikasi yang didistribusikan Play dapat berbeda dari upload key. Daftarkan fingerprint signing Play yang relevan pada Firebase/konfigurasi API bila fitur/provider membutuhkannya. [Android signing](https://developer.android.com/studio/publish/app-signing), [client authentication](https://developers.google.com/android/guides/client-auth), [rilis Android Flutter](https://docs.flutter.dev/deployment/android).

Tidak membuat aplikasi di Play Console, mengunggah AAB ke Google Play, atau mempublikasikan rilis pada pemeriksaan ini. Data akun Firebase pengguna tidak diubah.
