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
- [x] Upgrade toolchain Android ke Gradle `8.14`, Android Gradle Plugin `8.11.1`, dan Kotlin `2.2.20`.
- [x] Verifikasi ulang build APK debug setelah perubahan lintas platform.

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

> Pembaruan 25 Oktober 2026: pemilik melaporkan akses Firebase sudah tersedia
> kembali. Checklist Console/koneksi di bawah siap dilanjutkan; hasilnya tetap
> perlu diverifikasi dan belum dianggap lulus hanya berdasarkan kabar akses.
> Deployment Web untuk sementara tetap diizinkan tanpa App Check. Jangan
> aktifkan enforcement sebelum `FIREBASE_RECAPTCHA_SITE_KEY` dipasang kembali.

- [x] Verifikasi konfigurasi Firebase Web di `firebase_options.dart`.
- [ ] Tambahkan `localhost` ke Firebase Authorized Domains untuk development.
- [ ] Tambahkan `yuelearningcode.github.io` ke Firebase Authorized Domains.
- [ ] Siapkan `cermatify.com` sebagai domain produksi sesuai laporan pemilik 25 Oktober 2026; domain belum dihosting dan konfigurasi DNS/Authorized Domains belum diverifikasi.
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
- [x] Batasi lebar Chat Room dan bubble pesan pada desktop.
- [x] Batasi lebar form Paperlink, Complink, Sourcelink, dan submit Sourcelink.
- [x] Responsifkan dialog order, QR pembayaran, tombol aksi, dan daftar riwayat order.
- [x] Audit seluruh dialog pada layar pendek dan sempit.
  - [x] Dialog profil, logout, withdraw, dan status verifikasi.
  - [x] Dialog pembayaran order dan kuesioner.
  - [x] Dialog master data, bukti pembayaran admin, dan konfirmasi kuesioner.
- [x] Putuskan split view chat belum diperlukan; list dan room terpisah mempertahankan fokus serta riwayat browser.
- [x] Tambahkan hover state dan mouse cursor pada elemen interaktif.
- [x] Pastikan kontrol interaktif utama dapat digunakan dengan keyboard melalui button/`InkWell`.
- [x] Tambahkan focus indicator yang terlihat melalui theme dan kontrol Material.
- [x] Uji shell layout otomatis pada lebar 320, 375, 768, 1024, 1366, dan 1920 px.
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

- [x] Uji seluruh named route GetX agar unik, absolut, dan memiliki guard sesuai akses.
- [ ] Uji tombol Back dan Forward browser.
- [ ] Uji refresh pada halaman login, dashboard, profil, dan halaman detail.
- [x] Pastikan route yang memerlukan login memiliki route guard/middleware.
- [x] Pastikan customer atau mentor tidak dapat membuka route admin secara langsung pada lapisan UI.
- [x] Tentukan halaman login sebagai tujuan ketika session lokal tidak tersedia/kedaluwarsa.
- [x] Tambahkan halaman not-found yang sesuai.

Kriteria selesai:

- Refresh dan direct URL tidak menghasilkan halaman kosong atau 404.
- Protected route selalu memvalidasi session dan role.

## P2 — Quality gate dan testing

- [x] Selesaikan dua warning analyzer yang aktif.
- [x] Selesaikan seluruh deprecation dan info analyzer hingga `No issues found`.
- [x] Hapus `--no-fatal-warnings` dari CI setelah warning bersih.
- [x] Tetapkan quality gate `flutter analyze` harus menghasilkan nol issue.
- [x] Tambahkan unit test untuk formatter, breakpoint, route, dan middleware session.
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

- [x] Jalankan analyze, test, dan build web pada pull request.
- [x] Pertahankan build release dengan base href `/cermatify/` selama memakai GitHub Pages repository tersebut.
- [ ] Aktifkan GitHub Pages dengan source GitHub Actions.
- [x] Verifikasi permission workflow Pages tersedia pada workflow.
- [x] Putuskan environment staging belum diperlukan untuk rilis awal.
- [x] Dokumentasikan bahwa preset Cloudinary dan site key reCAPTCHA adalah public variables, bukan secrets.
- [x] Tandai deploy staging tidak diperlukan untuk rilis awal.
- [x] Jalankan smoke test deployment awal Firebase Hosting pada 25 Oktober 2026: root/aset, pengalihan legacy dan guard tamu profil/admin lulus. Uji akun nyata dan transaksi tetap mengikuti checklist penerimaan.
- [x] Dokumentasikan proses rollback.
- [ ] Selesaikan checklist penerimaan produksi dan rilis fitur penuh — Deployment live awal Firebase Hosting sudah dilakukan pada 25 Oktober 2026; autentikasi tiap role, transaksi, upload nyata, domain kustom dan App Check masih perlu diselesaikan sesuai checklist terkait.

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
- [x] Tidak ada credential rahasia di bundle berdasarkan audit source dan `build/web`.
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

## Pengembangan produk dan landing page — audit Tahap 0

Tanggal audit: 24 Oktober 2026 (Asia/Jakarta).

Bagian ini menjadi pelacak utama untuk arahan pengembangan produk pada lampiran pengguna. Nama file yang sudah ada, `TODO_WEB.md`, dipertahankan (Windows tidak membedakan kapitalisasi `todo_web.md`). Mengikuti permintaan terbaru, progres dicatat di sini; tidak membuat duplikat `docs/cermatify-improvement-checklist.md`. Checklist kesiapan web di atas tetap dipertahankan sebagai catatan sebelumnya, bukan hasil pengujian ulang pada audit ini.

### Ruang lingkup dan arti status

- [x] Kerjakan hanya Tahap 0: audit sumber dan penyusunan checklist.
- [x] Pertahankan kode aplikasi, konfigurasi produksi, data, dan mekanisme transaksi.
- [x] Selesaikan kajian/draft Tahap 1 dan catat persetujuan pemilik atas copy, urutan bagian serta implementasi awal Tahap 7 (pembuka dan tiga kartu layanan).

Status tugas: `[ ]` belum dikerjakan; `[x]` selesai. Tambahkan keterangan **Menunggu keputusan pemilik**, **Terhambat dependensi**, atau **Belum terverifikasi** bila berlaku. Tampilan yang tersedia tidak membuktikan perilaku atau layanan sudah berjalan.

Klasifikasi kemampuan pada tabel: **Implementasi tersedia** berarti jalur sumber dapat ditelusuri, bukan sudah lolos pengujian produksi; **Sebagian** berarti ada dukungan tetapi perilaku lengkap belum terpenuhi; **Placeholder** berarti konten contoh/statis tanpa bukti operasional; **Rencana** berarti implementasi belum ditemukan pada cakupan pemeriksaan. Semua kemampuan produksi di bawah belum terverifikasi melalui akun nyata.

### Tahap 0 — checklist audit

- [x] Baca aturan proyek dan identifikasi framework. Tidak ditemukan `AGENTS.md` pada root/induk yang diperiksa maupun pencarian file tersembunyi dalam proyek. Arahan lampiran menjadi batas pekerjaan.
- [x] Temukan landing page, routing, komponen, tema, dan layout terkait.
- [x] Periksa pendaftaran customer dan mentor, termasuk pintu masuk dari login.
- [x] Identifikasi implementasi Paperlink, Kuesioner, Sourcelink, serta keberadaan Complink.
- [x] Telusuri alur mentoring, chat, pembayaran, saldo, withdraw, dan dukungan jadwal yang ditemukan/tidak ditemukan.
- [x] Periksa sumber testimoni, statistik, rating, dan badge mentor pada kode.
- [x] Periksa keberadaan FAQ, syarat layanan, informasi privasi, dan bantuan.
- [x] Audit struktur responsif desktop/mobile dan baca cakupan tes yang tersedia. Pemeriksaan ini hanya berdasarkan sumber.
- [ ] Verifikasi visual desktop/mobile secara langsung — Belum terverifikasi; URL referensi tidak dapat diakses alat web dan Flutter lokal gagal dimulai.
- [x] Bedakan implementasi tersedia, sebagian, placeholder, serta rencana.
- [x] Susun checklist seluruh tahap berdasarkan audit tanpa memulai Tahap 1.
- [x] Catat keputusan bisnis yang memengaruhi implementasi dan rekomendasi urutan.

Audit sumber dan rencana selesai. Verifikasi visual/runtime tetap terbuka dan tidak menghalangi penyerahan hasil audit dengan batas tersebut.

### Temuan kondisi proyek dan bukti

Lokasi menggunakan format `path:baris`; nomor baris merujuk sumber saat audit. Tabel ini merekam kondisi awal sebelum perubahan; hasil implementasi terbaru dicatat pada bagian progres Tahap 7 di akhir dokumen.

| Area | Bukti dan kondisi aktual | Klasifikasi / implikasi |
| --- | --- | --- |
| Stack | `pubspec.yaml:1`, `.fvmrc:2`, `lib/app/routes/app_pages.dart:3`: Flutter/Dart, GetX, Firebase Auth/Firestore/App Check, Cloudinary untuk upload melalui `lib/app/data/services/media_upload_service.dart`. Versi proyek Flutter 3.44.4; batas Dart >=3.10.0 <4.0.0. | Implementasi tersedia. Versi SDK yang berhasil dijalankan belum terverifikasi. Gunakan pola GetView/controller/binding, tema dan widget yang sudah ada. |
| Landing dan navigasi | `lib/app/modules/landing/views/landing_view.dart:15`, `:132`, `:254`, `:274`, `:381`, `:765`; `lib/app/routes/app_pages.dart:61`: landing adalah route awal; CTA menuju register/login. Header hanya menyediakan Masuk. | Implementasi tersedia. Belum ada navigasi antarbagian, FAQ/kebijakan publik, atau CTA mentor langsung pada landing. Kartu layanan menjelaskan layanan tanpa alur eksplorasi mentor publik. |
| Akses layanan | `lib/app/routes/app_pages.dart:124` dan route berikutnya memakai `AuthenticatedMiddleware`, termasuk FAQ/Paperlink/Kuesioner/Sourcelink/Complink. Guard di `lib/app/routes/route_access_middleware.dart:20` mengarahkan tamu ke login. | Implementasi tersedia. Informasi detail layanan dan FAQ berada di balik login; CTA Cari Mentor publik perlu desain alur dan akses data terlebih dahulu. Guard UI tidak menggantikan rules. |
| Pendaftaran customer | `lib/app/modules/register/controllers/register_controller.dart:55`, `:309`, `:453`; `lib/app/modules/register/views/register_view.dart:16`: email/password, nama, semester wajib; kampus/jurusan tersedia, telepon opsional; Auth dibuat lalu profil Firestore disimpan. | Implementasi tersedia; registrasi nyata belum diuji. Perlu uji kegagalan penyimpanan profil setelah akun Auth terbuat karena dua operasi terpisah. |
| Pendaftaran mentor | `lib/app/modules/login/views/login_view.dart:140` mengirim argumen `mentor` ke register; `register_controller.dart:34`, `:64`, `:506`: formulir sama dengan tipe Paperlink/Complink, layanan dan LinkedIn; status awal `pending`. | Sebagian. Formulir dan status ada; kriteria kompetensi, simulasi, SLA seleksi, komisi, dan proses penolakan belum terdokumentasi sebagai prosedur operasional. |
| Verifikasi mentor | `lib/app/modules/users/controllers/users_controller.dart:105` mengubah pending/verified; `lib/app/modules/paperlink/views/list_mentor_view.dart:131` menyaring verified; `lib/app/modules/login/controllers/login_controller.dart:103` menangani pending. | Sebagian. Ada tindakan admin dan filter status. Klaim umum `Pendamping terverifikasi` pada `landing_view.dart:479` belum didukung definisi dan bukti penilaian kompetensi. Status database bukan bukti seleksi itu sendiri. |
| Paperlink | `lib/app/modules/paperlink/controllers/paperlink_controller.dart:92` mengambil kampus/jurusan/layanan; `views/list_mentor_view.dart:57` mengambil mentor; `views/detail_mentor_view.dart:59` memeriksa order progress lalu membuka chat atau dialog order. | Implementasi tersedia. Urutan sumber: login → filter → mentor → pembayaran/bukti → menunggu admin → order progress → chat. Pengajuan kebutuhan, pemilihan slot, dan hasil mentoring terstruktur belum ditemukan. |
| Chat dan sesi | `lib/app/modules/chat/controllers/chat_controller.dart:224`, `:520`, `:593`, `:656`: pesan Firestore, receipt baca, room per pasangan/order; `firestore.rules:194` mengatur akses room/pesan. | Implementasi tersedia untuk chat teks. Scheduler, kapasitas mentor, durasi sesi, video meeting, ringkasan sesi dan tindak lanjut terstruktur belum ditemukan. Jangan menjanjikannya dari keberadaan chat. |
| Kuesioner | `lib/app/modules/kuesioner/controllers/create_kuesioner_controller.dart:72`, `:123`, `:157`: order/bukti pembayaran lebih dahulu, lalu link dan kriteria responden; `kuesioner_controller.dart:97` membaca approved serta menyaring demografi. | Sebagian. Ini distribusi/pengelolaan link kuesioner, bukan otomatis survei feedback mentoring. Order dapat tersimpan sebelum formulir kuesioner selesai; perlu penanganan pengguna keluar di tengah alur. |
| Reward responden | `lib/app/modules/kuesioner/views/kuesioner_detail_view.dart:188` mencoba menambah signedBy dan saldo Rp100 dari client; `firestore.rules:61` membatasi update saldo, `:159` hanya mengizinkan admin mengubah kuesioner. | Sebagian/terhambat dependensi backend. Jalur client ini ditolak rules lokal. Tidak ditemukan verifikasi jawaban eksternal atau backend reward. Jangan menjanjikan hadiah aktif. |
| Sourcelink | `lib/app/modules/sourcelink/views/sourcelink_view.dart:361` menyimpan kriteria lalu membuka submit; `views/sourcelink_submit_view.dart:122`, `:219` membuat order dan dokumen kuesioner. | Implementasi sebagian untuk pengajuan link/kriteria responden. Copy landing `landing_view.dart:636` menyebut sumber dan komunitas; kemampuan pencarian referensi/komunitas belum ditemukan. Batas produk terhadap Kuesioner perlu diputuskan. |
| Jalur Sourcelink lain | `lib/app/modules/sourcelink/controllers/sourcelink_controller.dart` juga memiliki `createKuesioner()` yang menulis createdBy/status open; tidak ditemukan pemanggilan dari view Sourcelink yang diperiksa. | Jalur lama/tidak terhubung pada alur tersebut; skemanya berbeda dari rules create `firestore.rules:149`. Jangan memakai keberadaan metode ini sebagai bukti fitur aktif. |
| Complink | `lib/app/modules/complink/controllers/complink_controller.dart:47` membaca layanan bertipe complink; ada route, filter kompetisi, dan alur daftar mentor bersama. | Implementasi tersedia, tetapi tidak ditampilkan di tiga kartu landing. Perlu keputusan posisi produk; tidak diubah dalam audit. |
| Pembayaran dan harga | `lib/app/modules/order/controllers/order_controller.dart:23`, `:53`, `:79`; `lib/app/modules/order/views/order_dialog_view.dart`; `lib/app/modules/sourcelink/views/sourcelink_submit_view.dart:461`: gambar QRIS, upload bukti ke Cloudinary, status waiting verification, admin mengubah status. `firestore.rules:103` memvalidasi harga katalog atau kuesioner Rp25.000. | Sebagian: alur pembayaran manual, bukan konfirmasi gateway. Rp25.000 di kode dan fallback Rp100.000 (`detail_mentor_view.dart:109`) adalah temuan implementasi, bukan harga yang baru disetujui. Fallback belum tentu lolos rules katalog. |
| Saldo dan withdraw | `lib/app/modules/admin_orders/controllers/admin_orders_controller.dart:224` transaksi approval dan kredit saldo; `lib/app/modules/profile/controllers/withdraw_controller.dart:19`, `:29`; `lib/app/modules/admin_withdraw/controllers/admin_withdraw_controller.dart:110` approval/rejection. `firestore.rules:165` membatasi pengajuan untuk mentor aktif, minimum Rp50.000. | Sebagian. Approval memotong saldo secara atomik; pengajuan pending belum mereservasi saldo. Transfer nyata, bukti pencairan, rekonsiliasi/ledger belum ditemukan. Jangan menyamakan approved dengan uang sudah ditransfer. Angka minimum masih perlu konfirmasi bisnis. |
| Paket/bundling | Pencarian paket/bundle dan model order menunjukkan layanan tunggal serta price, belum menemukan katalog paket dengan jumlah/durasi sesi, masa berlaku, kuota chat/review atau bundling lintas layanan. | Rencana. Proposal paket memerlukan keputusan isi dan dampak teknis sebelum penjualan. |
| Testimoni | `lib/app/modules/landing/views/landing_view.dart:704`: dua kutipan const dengan nama generik Mahasiswa/Mentor, tanpa sumber, tanggal, consent atau hubungan transaksi. | Placeholder/belum terverifikasi. Tidak menyimpulkan palsu, tetapi tidak boleh dianggap pengalaman nyata tanpa bukti pemilik. |
| Statistik dan rating | `landing_view.dart:515`, `:523`, `:531`: angka statis 3+ layanan, 24/7 Akses web, 1 aplikasi; bukan statistik pelanggan. `list_mentor_view.dart:160` membaca rating/totalSessions dari user, default 0; `detail_mentor_view.dart:302` menampilkannya. | Belum terverifikasi. Tidak ditemukan sistem ulasan/agregasi sesi yang membuktikan rating. Label 24/7 sudah merujuk akses web, bukan jam mentor; uptime/SLA belum dibuktikan. |
| Data contoh | `lib/app/modules/kuesioner/controllers/kuesioner_controller.dart:226` mengganti daftar menjadi `dummyKuesioner` pada semua exception. `lib/app/data/dummy_mentors.dart` juga ada, tetapi bukan sumber daftar mentor Firestore yang diperiksa. | Placeholder pada fallback kuesioner berpotensi tampak seperti data nyata ketika jaringan/izin gagal. File dummy tidak otomatis berarti seluruh layanan dummy. Pisahkan opsi demografi statis dari pengalaman/transaksi contoh. |
| FAQ | `lib/app/modules/faq/controllers/faq_controller.dart:4` memuat lima jawaban statis: nama Cermat Paper, tarif mentor individual, kuesioner sebagai feedback sesi, dan klaim keamanan umum. Route FAQ memerlukan login. | Sebagian. Penjelasan feedback berbeda dari implementasi link survei/demografi; tarif individual dan keamanan menyeluruh perlu bukti/peninjauan. Belum ada FAQ kebijakan dan calon mentor yang lengkap. |
| Syarat dan privasi | `lib/app/modules/register/views/register_view.dart:557` checkbox dengan TextSpan Syarat dan Ketentuan tanpa recognizer/tautan; pencarian route/file belum menemukan halaman kebijakan publik. `lib/app/modules/kuesioner/views/data_user_kuesioner_view.dart:391` memiliki panel informasi privasi. | Sebagian. Panel privasi bukan kebijakan lengkap. Dokumen refund/pembatalan/sengketa dan batas akademik belum ditemukan. Tidak melakukan riset atau menyimpulkan status hukum/PSE. |
| Akses data pribadi | `firestore.rules:59` mengizinkan semua akun login membaca dokumen users; profil menyimpan email/telepon dan data akademik. | Temuan privasi sumber: perlu evaluasi pemisahan profil publik/privat sebelum klaim keamanan atau membuka katalog mentor publik. Rules produksi belum dibandingkan. |
| Bantuan | `lib/app/modules/profile/controllers/profile_controller.dart:35` menyediakan openAdminChat; tombol pada `profile/views/profile_view.dart:1407` menuju Chat admin. Landing tidak memiliki kontak bantuan publik. | Implementasi tersedia di area akun. Kontak pengelola, jam layanan, SLA respons dan penerima bantuan resmi belum terverifikasi. |
| Desktop/mobile | `lib/app/data/layout/app_breakpoints.dart:2`: 600/1024, lebar utama 1440. Landing memakai ResponsiveLayout, max width 1180 (`landing_view.dart:8`), hero desktop/mobile terpisah (`:298`), kartu Wrap (`:641`). Widget auth dan shell responsif sudah tersedia. | Struktur responsif tersedia. `test/landing_responsive_test.dart:19` mencakup lebar 320, 375, 600, 768, 1024, 1366, 1440, 1920. Belum menjalankan ulang tes, memeriksa seluruh scroll, zoom, keyboard, kontras, atau browser nyata. |

Dokumentasi pendukung yang diperiksa: `docs/audit-chat-transaksi-withdraw.md`, `docs/QUALITY_GATE.md`, serta checklist web lama pada file ini. Hasil tes lama yang tertulis di dokumentasi bukan hasil validasi baru. Jika dokumen lama berbeda dari sumber, temuan tabel di atas mengacu pada sumber yang diperiksa.

### Masalah prioritas dan dependensi

- **Konten yang perlu bukti sebelum publikasi ulang:** kutipan testimoni, dasar verifikasi mentor, rating/jumlah sesi, klaim keamanan FAQ. Prioritas Tahap 1, 3, 5, 6; jangan memperkuat klaim sebelum diverifikasi.
- **Ketidaksesuaian definisi produk:** copy Sourcelink, hubungan Kuesioner dengan feedback mentoring, dan posisi Complink. Selesaikan definisi di Tahap 1–2 sebelum implementasi landing.
- **Alur berisiko membingungkan:** instruksi Cara Kerja terlalu umum, informasi rinci tersembunyi di balik login, persetujuan syarat tanpa dokumen yang dapat dibuka, serta order survei dapat tercipta sebelum pengisian selesai.
- **Backlog teknis terpisah:** fallback data contoh pada error; reward ditolak rules; kegagalan parsial registrasi/order; backend/ledger, reservasi saldo dan bukti pencairan; pemisahan data profil. Ini temuan audit, bukan izin memperbaiki chat/transaksi/withdraw pada tahap konten.

### Keputusan yang sudah disepakati

- Tahap 0 dan draft Tahap 1 selesai. Pemilik menyetujui copy/urutan/bagian awal; tahap aktif adalah Tahap 7 untuk pembuka dan tiga kartu layanan.
- Progres pengembangan dicatat pada `TODO_WEB.md`; catatan sebelumnya dipertahankan.
- Gunakan komponen, tema, pola kode, dan desain proyek yang tersedia.
- Jangan mengklaim fitur tersedia dari UI saja atau mengarang testimoni, statistik, badge dan legalitas.
- Rincian paket, CTA, seleksi mentor, jadwal/pembatalan, transaksi/reward, dukungan dan pengelolaan data sudah tersedia dalam enam jawaban lanjutan. Bagian itu menjadi acuan draft terbaru; label usulan dan syarat finalisasi yang ditulis pemilik tetap berlaku.
- Tahap 1 menghasilkan draft copy untuk persetujuan sebelum penerapan; Tahap 7 dikerjakan per bagian yang dipilih.
- Tidak melakukan deploy, konfigurasi produksi, transaksi nyata atau migrasi destruktif pada audit ini.

### Ringkasan awal keputusan dari jawaban pemilik — 24 Oktober 2026

Tabel ini adalah ringkasan sepuluh jawaban awal, dipertahankan untuk riwayat. Acuan draft terkini berada pada bagian Status terkini dan enam rincian di bagian jawaban pemilik. Persetujuan arah produk/bisnis dibedakan dari status implementasi; tidak ada fitur yang ditandai selesai hanya karena keputusannya telah diberikan.

| No. | Keputusan atau arahan yang tercatat | Dampak tahap dan status implementasi |
| --- | --- | --- |
| 1 | Segmen utama mahasiswa; mahasiswa dan orang dewasa yang memiliki waktu tersedia dapat menjadi calon mentor. | Tahap 1/3: arah target sudah diberikan. Posisi publik Complink dan rincian kelayakan calon mentor masih perlu diperjelas. Tidak menganggap formulir saat ini sudah mendukung semua latar belakang. |
| 2 | Pemilik melihat Kuesioner dan Sourcelink kemungkinan sama dan meminta audit kesamaannya. | Tahap 2: audit duplikasi menjadi tindak lanjut. Belum ada persetujuan menggabungkan, menghapus, atau mengganti nama layanan. |
| 3 | Pengunjung menjelajahi landing page sampai CTA di bagian akhir. | Tahap 1/7: perjalanan publik berfokus pada landing. Tidak menyimpulkan katalog mentor publik harus dibuka atau login dihapus; label CTA final masih perlu draft. |
| 4 | Mahasiswa boleh menjadi mentor; verifikasi direncanakan melalui interview langsung. Profil sosial, LinkedIn, dan portofolio online menjadi bahan penilaian platform serta pertimbangan pengguna. | Tahap 3: metode interview dan bahan penilaian sudah diarahkan. Rubrik, bukti minimum, pihak penilai, dan alur seleksi belum lengkap. Source register saat ini menyediakan LinkedIn; Instagram/tautan sosial/portofolio tambahan belum dianggap tersedia. |
| 5 | Mentoring online maupun pertemuan langsung dimungkinkan bila lokasi mendukung. Jadwal dipilih saat memilih mentor. Durasi, kuota chat/review, dan batas layanan masuk dalam paket. Pemilik menanyakan kelayakan video call di aplikasi. | Tahap 2/4: arah pengalaman disepakati; penjadwalan, lokasi, durasi dan paket belum diimplementasikan. Video call masih pertanyaan kelayakan dan backlog teknis, bukan layanan aktif. |
| 6 | Harga final belum diputuskan. Pemilik mengizinkan saran paket dan pratinjau/thumbnail untuk dibahas sebelum harga sebenarnya diisi. | Tahap 4/7: proposal/pratinjau dapat dirancang saat bagian itu dipilih. Label harga belum ditentukan; jangan mengisi angka contoh sebagai tarif resmi atau mengaktifkan pembelian paket. |
| 7 | Pembagian pendapatan mentoring: Cermatify 25%, mentor 75%. Pendapatan layanan kuesioner dialokasikan 100% ke Cermatify selama belum ada pihak ketiga. Minimum penarikan diarahkan menjadi Rp20.000. Pembayaran, penarikan/topup direncanakan melalui gateway/bank dengan konfirmasi admin/sistem. | Tahap 3/4 dan backlog transaksi: keputusan bisnis tercatat, belum diterapkan. Kode masih mengkredit `price` penuh ke mentor dan minimum withdraw controller/rules masih Rp50.000. Provider, dasar hitung komisi, biaya gateway, dan arti selesai transfer belum ditentukan. Pembagian pendapatan bukan pernyataan laba bersih atau penghapusan biaya/reward. |
| 8 | Reward responden Rp100 tetap diinginkan. Pemilik mengusulkan token akun/klaim dengan ID reward unik dan pengecekan pernah klaim; backend dikerjakan kemudian, fokus UI terlebih dahulu. | Tahap 7/8 dan backlog reward: arah reward disetujui, mekanisme final belum dipilih. Token/popup saja tidak membuktikan respons sah atau mencegah klaim ganda; validasi dan idempotensi perlu backend. Rules saat ini tetap menolak reward dari client. |
| 9 | Testimoni/rating direncanakan dua baris, masing-masing enam entri; baris pertama bergerak kanan ke kiri, baris kedua kiri ke kanan, berulang. | Tahap 5/7/8: arah tata letak/animasi tercatat. Sumber 12 ulasan, rating asli, identitas dan izin penggunaan belum diberikan. Jangan membuat ulasan/rating palsu atau menampilkan contoh sebagai pengalaman nyata. |
| 10 | Bantuan diarahkan ke akun admin; pemilik menghendaki admin online 24/7, FAQ di landing dan dashboard, pengelolaan keamanan oleh admin, serta penyimpanan data tanpa batas waktu untuk sementara. | Tahap 6/7: arah operasional dicatat sebagai pernyataan/keinginan pemilik. Dukungan 24/7 belum diverifikasi sebagai kapasitas operasional/SLA; kebijakan keamanan, akses, retensi dan penghapusan perlu dirinci dan ditinjau sebelum klaim publik. Penanggung jawab admin tidak membuktikan keamanan data dengan sendirinya. |

Video call di dalam Cermatify memungkinkan secara teknis. Implementasinya memerlukan komponen audio/video, izin kamera dan mikrofon, kontrol akses sesi, serta dukungan backend. Pilihan infrastruktur/provider, biaya dan rincian implementasi dibahas pada tahap teknis yang dipilih nanti. Tidak menambahkan dependency atau menampilkan tombol panggilan seolah sudah berfungsi pada pencatatan keputusan ini.

### Pertanyaan audit dan jawaban asli pemilik

Jawaban asli pemilik dipertahankan di bawah untuk keterlacakan. Ringkasan keputusan di atas menjadi acuan; hanya rincian yang belum dijawab yang tetap terbuka.

1. Siapa segmen utama dan hasil bantuan akademik yang ingin ditonjolkan? Apakah Complink layanan utama publik atau layanan tambahan? = segemen utamanya mahasiswa dan orang dewasa senggang yang dapat menjadi mentor
2. Apa perbedaan resmi Kuesioner dan Sourcelink? Apakah Sourcelink memang distribusi responden, atau ada rencana sumber referensi/komunitas yang belum dikembangkan? = sepertinya sama saja jadi dapat diaudit,
3. Sejauh mana calon pengguna boleh menjelajah mentor/layanan sebelum login, dan apa CTA utama yang dipilih? = menjelajahi landing page hingga cta diakhir
4. Apa definisi mentor terverifikasi, bukti kompetensi yang diperlukan, pihak penilai dan proses seleksi/penolakan? Apakah mentor nonmahasiswa boleh mendaftar mengingat semester saat ini wajib? = mahasiswa dapat menjadi mentor juga, dan untuk memverifikasi mentor nanti ada interview langsung dengan mentornya, dan mentor saat mendaftar kan ada kolom profil mereka seperti instagram, sosmed, linkedln bahkan jika ada portofolio online yang dapat digunakan untuk bahan penilaiaan baik dari cermatifynya serta pengguna yangakan memilih mentor
5. Apakah mentoring melalui chat saja atau juga pertemuan eksternal? Tentukan durasi, jadwal, kuota chat/review, hasil sesi, batas bantuan akademik, SLA respons, reschedule dan keluhan sebelum dijanjikan. = dapat 2nya jika lokasi memungkinkan, namun jika melalui video call fitur bawaan dari cermatify apakah mungkin untuk menambahkannya?, dan untuk jadwal dipilih saat hendak memilih mentor, dan untuk sisanya seperti durasi, kuota chat/review, batasnya itu dimasukkan kedalam paket dengan harga tertentu.
6. Konfirmasikan sumber harga, termasuk angka Rp25.000 dan fallback Rp100.000 yang sudah tertulis di kode. Untuk paket, putuskan isi/jumlah sesi/masa berlaku/pengecualian terlebih dahulu; contoh Konsultasi Awal, Pendampingan Berkala, Persiapan Pengumpulan Data belum disetujui. = masih di putuskan jadi boleh berikan saran dan buat juga untuk thumbnail skrng, nanti diinput harga pasnya
7. Siapa penerima pendapatan layanan kuesioner, berapa komisi, kapan saldo boleh ditarik, siapa yang boleh withdraw, apakah minimum Rp50.000 tetap berlaku, dan bagaimana bukti transfer/refund/sengketa ditangani? = bukti transfer akan ditanagi melalui bank langsung melalui payment gateway dan admin/sistem akan memberikan konformasi progress penarikan ataupun topup, untuk persenan komisi app cermatify mengambil 25%, sisanya kepada para mentor, namun untuk kuisioner app cermatify 100% karena kami sebagai penyedia layanan tanpa campur tangan pihak ke tiga, namun jika nantinya ada pihak ke tiga baru diberi pembagiannya, untuk minimun transfer dikurangi menjadi 20rb
8. Apakah reward Rp100 untuk responden tetap diinginkan? Bagaimana bukti respons sah, anti-duplikasi, sumber dana, dan batas janji responden? Backend dibutuhkan sebelum aktivasi. = reward tetap diberikan, untuk anti duplikasi digunakan fitur token perakun yang mengisi kuisioner atau bisa saja menggunakan popup hadiah dan claim dari sana kemudian sistem akan cek jika sudh pernah claim atau tidak, dan juga id setiap reward walaupun isinya sama memiliki identitas yang berbeda untuk menghindai kecurangan, untuk backend bantu saya membuatnya nanti, untuk sekarang kerjakan fokus ui dulu
9. Adakah sumber/izin tertulis bagi dua kutipan landing dan data rating/sesi? Jika belum ada, pilih penghilangan sementara atau penggantian dengan struktur tanpa klaim pengalaman nyata pada tahap yang dipilih. ada ditambahkan saja beberapa rating nya buat dalam bentuk 2 row dan infinite scrolling nanti testimoninya, row 1 scroll kanan ke kiri, row 2 kiri ke kanan dan setiap row ada 6 testimoni atau rating
10. Siapa pengelola dan kontak bantuan publik, jam respons, dokumen kebijakan, masa simpan/penghapusan data, serta pihak peninjau kebijakan? Klaim legalitas/PSE memerlukan bukti terpisah. = untuk usernya untuk saat ni dibuat ke akun admin saja yang menanganinya, admin online 24/7 dan juga ada bagian faq nantinya di landing page dan di halaman dashboard, untuk keamanan data diatur juga oleh admin, masa simpan data untuk sekarang tidak ada batasan waktu


### Status terkini berdasarkan bagian jawaban pemilik

**Enam jawaban lanjutan sudah tersedia dan telah dibaca seluruhnya.** Bagian `jawaban pemilik` di bawah menjadi acuan draft terbaru, melengkapi dan memperbarui ringkasan awal di atas. Informasi yang sudah dijawab tidak ditandai sebagai belum diberikan dan tidak ditanyakan ulang.

**Konfirmasi terbaru, 24 Oktober 2026:** pemilik menyatakan seluruh arahan saat ini sudah dikonfirmasi, dan perubahan berikutnya akan diberitahukan. Enam jawaban menjadi arah pengembangan yang disetujui, termasuk paket Rp75.000/Rp250.000 dan komisi mentoring 15%. Label usulan/proposal pada jawaban asli dipertahankan sebagai riwayat penulisan; tidak perlu meminta persetujuan pemilik yang sama lagi. Penyiapan operasional, kesepakatan mentor, kebijakan tertulis dan implementasi tetap dilacak sebagai pekerjaan tersendiri. Prioritas implementasi pertama pada kelanjutan ini adalah navigasi landing.

| Bidang | Jawaban yang sudah tersedia | Status lanjutan |
| --- | --- | --- |
| Paket dan CTA | Konsultasi Awal: 1 × 60 menit, 3 topik chat dalam 3 hari, 1 review maksimal 5 halaman, masa berlaku 14 hari, hasil ringkasan/rekomendasi; Rp75.000. Pendampingan Terarah: 4 × 60 menit, 12 topik chat pada jam mentor, maksimal 4 review masing-masing 10 halaman, masa berlaku 30 hari, catatan progres/umpan balik/tindak lanjut; Rp250.000. CTA: Cari Mentor, Lihat Cara Kerja, Daftar sebagai Mentor. | Isi, batas, harga dan label CTA telah dikonfirmasi sebagai arah pengembangan. Kesepakatan mentor dan UI/kuota/booking/hasil sesi tetap perlu disiapkan. Hero saat ini masih memakai Lihat Layanan/Masuk; navigasi mentor sudah diterapkan. |
| Mentor | Kompetensi dan kemampuan membimbing menjadi dasar; semester 5 acuan nonwajib. Rubrik: penguasaan bidang 35%, menjelaskan 30%, komunikasi/empati 15%, integritas 15%, kesiapan 5%; usulan ambang 75/100 dan dua aspek utama masing-masing minimal 70%. Penilai admin dan penilai bidang; bukti wajib/opsional, empat status pendaftar, semester kondisional, penolakan pribadi dan usulan daftar ulang 30 hari sudah diuraikan. | Rubrik, penilai, bukti dan alur penolakan sudah tersedia sebagai draft; formulir serta proses operasional belum diterapkan. Tidak meminta rubrik dari awal lagi. |
| Jadwal dan layanan | Awal peluncuran diarahkan daring melalui pertemuan eksternal; video internal ditunda dan tatap muka belum ditawarkan. Usulan pemesanan minimal 24 jam, reschedule satu kali minimal 12 jam sebelumnya, ketentuan pembatalan/refund, masa tunggu no-show 15 menit, gangguan teknis dan kanal/waktu keluhan sudah tertulis. | Draft aturan sudah dijawab; penyusunan dokumen final dan dukungan booking/penjadwalan masih backlog. Tidak menampilkan layanan tatap muka/video internal sebagai fitur aktif. |
| Transaksi dan komisi | Komisi terbaru 15% dari harga jasa setelah diskon yang ditanggung mentor; biaya gateway terpisah, ditanggung platform selama layak. Diskon platform tidak mengurangi hak mentor. Empat jenis saldo, hak withdraw, minimum Rp20.000, pembayaran langsung per pesanan untuk awal, refund bagian belum terpakai, konfirmasi transfer dan pengembalian saldo tepat sekali sudah dijelaskan. | Dasar perhitungan, angka dan prinsip transaksi telah dikonfirmasi. Gunakan 15%; 25%/75% dipertahankan sebagai riwayat keputusan awal. Implementasi finansial, provider dan perjanjian pihak ketiga masih harus disiapkan. |
| Reward | Kriteria respons sah, sumber dana dari anggaran pemilik survei atau subsidi tercatat, validasi integrasi/manual, status Dikirim → Menunggu validasi → Disetujui/ditolak → Reward tersedia, ID respons unik, satu reward per respons sah, idempotensi, audit dan pencatatan atomik sudah ditentukan sebagai persyaratan draft. Reward Rp100 tetap acuan awal. | Prinsip validasi, sumber dana dan pencegahan reward ganda sudah dijawab; detail teknologi/integrasi dan backend masih perlu dibangun. Screenshot bukan bukti tunggal otomatis; jawaban tidak ditolak karena berbeda dari hipotesis. |
| Dukungan dan data | Usulan Senin–Sabtu 09.00–17.00 WIB, target respons awal satu hari kerja, keluhan sederhana tiga hari kerja, pembaruan kasus kompleks dua hari kerja; kanal resmi yang dipantau. Retensi mengikuti tujuan/jenis data, verifikasi mentah dibatasi, akses berdasarkan tugas, penghapusan akun dan siklus backup; tidak memakai retensi tak terbatas secara menyeluruh. | Jam, target respons dan prinsip pengelolaan data sudah dijawab. Email bantuan `cermatifycompany@gmail.com` dikonfirmasi pemilik dan dipasang pada footer tanggal 25 Oktober 2026. Durasi retensi final per jenis data dan peninjauan kebijakan masih terbuka. |

- [x] Terima dan petakan seluruh enam jawaban lanjutan, termasuk bagian 5–6 yang belum tercermin lengkap pada checklist sebelumnya.
- [x] Catat tiga nama publik yang disetujui dan implementasi awal landing/root/pratinjau ulasan yang sudah dikerjakan; pilihan bagian awal tidak perlu ditanyakan lagi.
- [x] Terima konfirmasi pemilik atas rincian dan angka pada enam jawaban — Persetujuan arah pengembangan diterima; kesepakatan operasional dan implementasi tetap harus diselesaikan sebelum layanan dinyatakan aktif.
- [x] Catat arahan 25 Oktober 2026: petunjuk langkah penggunaan ditampilkan melalui tutorial pop-up setelah login dan dapat dibuka kembali dengan tombol tanda tanya dalam lingkaran. Rincian tutorial menjadi pekerjaan aplikasi setelah login; landing cukup memberi gambaran singkat layanan.
- [x] Cantumkan alamat email bantuan publik — Pemilik mengoreksi dan mengonfirmasi `cermatifycompany@gmail.com` pada 25 Oktober 2026; footer memakai tautan email tersebut. Penulisan awal `cermatifycompany@gamil.com` digantikan oleh konfirmasi ini.
- [ ] Tetapkan durasi retensi final per jenis data dan selesaikan dokumen kebijakan untuk ditinjau — Prinsip retensi sudah tersedia.
- [ ] Terima dan verifikasi ulasan nyata serta izin publikasi bila akan dipakai sebagai bukti pengalaman — Materi terbaru yang diberikan eksplisit berupa contoh fiktif.
- [ ] Terapkan UI, proses operasional dan backend pada subtahap terkait, lalu jalankan validasi — Tidak ditandai selesai hanya karena rancangan sudah tertulis.

jawaban pemilik

**1. Detail paket dan CTA landing page**

Saya mengusulkan dua paket awal agar mudah dipahami dan dikelola.

| Komponen | Konsultasi Awal | Pendampingan Terarah |
|---|---|---|
| Cakupan | Membahas satu masalah atau kebutuhan akademik | Mendampingi satu topik dengan target yang disepakati |
| Sesi | 1 × 60 menit | 4 × 60 menit |
| Chat | Klarifikasi pembahasan selama 3 hari setelah sesi | Klarifikasi selama masa paket, pada jam layanan mentor |
| Review | 1 dokumen, maksimal 5 halaman, 1 kali umpan balik | Maksimal 4 kali review, masing-masing maksimal 10 halaman |
| Masa berlaku | 14 hari sejak pembayaran terkonfirmasi | 30 hari sejak pembayaran terkonfirmasi |
| Hasil | Ringkasan pembahasan dan rekomendasi langkah berikutnya | Catatan progres, umpan balik, dan rencana tindak lanjut |
| Harga usulan | Rp75.000 | Rp250.000 |

Kuota chat sebaiknya dihitung sebagai **topik klarifikasi**, bukan jumlah pesan: maksimal 3 topik untuk Konsultasi Awal dan 12 topik untuk Pendampingan Terarah. Topik baru di luar cakupan membutuhkan kesepakatan tambahan.

Pengecualian kedua paket:

- Tidak mencakup pengerjaan tugas, ujian, atau karya ilmiah atas nama pengguna.
- Tidak mencakup pembuatan data, referensi, atau respons kuesioner fiktif.
- Tidak menjamin nilai, kelulusan, kemenangan lomba, atau persetujuan dosen.
- Review berarti memberi komentar dan arahan, bukan menulis ulang seluruh dokumen.

**CTA utama:** “Cari Mentor”.<br>
**CTA pendukung:** “Lihat Cara Kerja”.<br>
**CTA rekrutmen:** “Daftar sebagai Mentor”.

Harga final baru dipublikasikan setelah mentor menyetujui pendapatan bersih dan cakupan pekerjaannya. Jika bidang tertentu memerlukan tarif berbeda, tampilkan harga pada profil mentor sebelum pemesanan.

**2. Seleksi mentor dan dukungan pendaftar nonmahasiswa**

Dasar kelulusan adalah **kompetensi dan kemampuan membimbing**. Semester 5 tetap menjadi acuan pengalaman bagi mahasiswa, bukan syarat mutlak.

Usulan rubrik interview:

| Aspek | Bobot | Cara menilai |
|---|---:|---|
| Penguasaan bidang | 35% | Pertanyaan dan studi kasus sesuai bidang |
| Kemampuan menjelaskan | 30% | Simulasi mengajar sekitar 10 menit |
| Komunikasi dan empati | 15% | Cara menanggapi pengguna yang kesulitan |
| Integritas akademik | 15% | Respons terhadap permintaan joki atau manipulasi data |
| Kesiapan operasional | 5% | Jadwal, koneksi, dan komitmen layanan |

Usulan ambang kelulusan adalah **75/100**, dengan syarat penguasaan bidang dan kemampuan menjelaskan masing-masing minimal 70% dari nilai aspek tersebut. Kesediaan melakukan kecurangan akademik menjadi alasan penolakan meskipun total nilai memenuhi ambang.

Penilai terdiri dari admin untuk administrasi dan penilai yang memahami bidang untuk kompetensi. Pada tahap awal, satu orang dapat merangkap jika kompeten; kasus meragukan perlu penilaian kedua.

Bukti wajib:

- Identitas dan status yang diverifikasi secara proporsional.
- Minimal satu bukti kompetensi relevan: portofolio, pengalaman, sertifikat, publikasi, atau karya.
- Persetujuan kode etik dan ketentuan mentor.

Bukti opsional meliputi transkrip, penghargaan, dan rekomendasi. Tidak semua bidang harus mewajibkan sertifikat.

Formulir menyediakan status **mahasiswa, lulusan, dosen/pengajar, dan praktisi/profesional**. Kolom semester hanya muncul untuk mahasiswa; pendaftar lain mengisi pengalaman relevan.

Penolakan disampaikan secara pribadi dengan kategori alasan dan saran perbaikan. Usulan pendaftaran ulang: setelah 30 hari dengan bukti peningkatan. Dugaan pemalsuan atau pelanggaran serius ditinjau terpisah.

**3. Jadwal, lokasi, pembatalan, no-show, dan video call**

Untuk peluncuran awal, saya menyarankan **mentoring daring menggunakan layanan pertemuan eksternal**. Video call internal masuk pengembangan berikutnya setelah kebutuhan dan biaya operasionalnya terbukti.

| Kondisi | Usulan aturan |
|---|---|
| Pemesanan | Minimal 24 jam sebelum sesi dan mengikuti ketersediaan mentor |
| Zona waktu | Ditampilkan secara eksplisit, termasuk pada konfirmasi |
| Reschedule oleh pengguna | Maksimal 1 kali per sesi, diajukan minimal 12 jam sebelumnya |
| Pembatalan ≥24 jam | Pengguna dapat memilih pengembalian biaya layanan yang belum digunakan atau penjadwalan ulang |
| Pembatalan <24 jam | Tidak otomatis mendapat refund; pengecualian ditinjau berdasarkan bukti |
| Mentor membatalkan/tidak hadir | Pengguna memilih jadwal pengganti atau refund sesi tersebut |
| Pengguna tidak hadir | Masa tunggu 15 menit; sesi dapat dihitung terpakai jika mentor terbukti hadir |
| Gangguan teknis | Dinilai berdasarkan durasi yang hilang dan bukti, lalu diberikan penggantian waktu atau sesi |
| Keluhan | Diajukan melalui kanal resmi, idealnya maksimal 2 × 24 jam setelah sesi |

Batas keluhan tersebut digunakan untuk mempercepat penanganan operasional, bukan menghapus hak pengguna atas masalah yang baru diketahui kemudian.

Pertemuan tatap muka sebaiknya belum ditawarkan sampai aturan lokasi, keselamatan, biaya perjalanan, dan tanggung jawabnya tersedia.

Sebelum membangun video call internal, buat estimasi peserta bersamaan, durasi pemakaian, biaya penyedia media, pemeliharaan, serta dukungan teknis. **Jangan menetapkan anggaran hanya berdasarkan biaya pembuatan fitur.**

**4. Komisi, gateway, withdraw, refund, dan topup**

Usulan komisi platform adalah **15% dari harga jasa setelah diskon yang ditanggung mentor**. Biaya gateway dicatat terpisah dan ditanggung platform pada tahap awal, selama hasil perhitungan biaya memungkinkan.

Contoh:

| Komponen | Nilai |
|---|---:|
| Harga jasa | Rp100.000 |
| Komisi platform 15% | Rp15.000 |
| Hak mentor | Rp85.000 |
| Biaya gateway | Mengurangi bagian platform sesuai biaya aktual |

Diskon yang dibiayai Cermatify tidak mengurangi hak mentor. Dasar perhitungan wajib tercatat per transaksi.

Aturan saldo yang disarankan:

- **Saldo tertunda:** pembayaran diterima, tetapi layanan belum selesai atau masih dalam masa pemeriksaan.
- **Saldo tersedia:** hak pendapatan yang sudah dapat ditarik.
- **Saldo ditahan:** terkait sengketa atau pemeriksaan.
- **Saldo dalam pencairan:** sudah dipesan untuk transfer sehingga tidak dapat ditarik lagi.

Withdraw hanya diberikan kepada pihak yang memang memiliki **hak pendapatan yang terverifikasi**, seperti mentor dan—jika fiturnya aktif—penerima reward responden. Akun mahasiswa tidak otomatis berhak withdraw hanya karena memiliki saldo pembayaran.

Minimum penarikan tetap **Rp20.000**. Minimum topup merupakan keputusan terpisah. Untuk tahap awal, saya menyarankan **pembayaran langsung per pesanan**, sehingga fitur topup tidak perlu dipaksakan. Jika topup sudah menjadi bagian penting aplikasi, batasnya ditentukan dari biaya gateway dan kebutuhan pembelian terkecil.

Refund paket dihitung berdasarkan layanan yang belum digunakan dan pembagian nilai sesi yang diberitahukan sejak pembelian. Dana transaksi yang disengketakan ditahan sementara; pendapatan lain yang tidak terkait tetap dapat diproses.

Pencairan hanya berstatus **berhasil setelah penyedia transfer mengonfirmasinya**, bukan saat tombol withdraw ditekan. Transfer gagal harus mengembalikan saldo tepat satu kali; transfer dengan status belum pasti harus direkonsiliasi sebelum dicoba ulang.

Skema pihak ketiga untuk kuesioner belum diaktifkan sebelum ada perjanjian mengenai biaya, validasi, akses data, dan penanganan kegagalan.

**5. Respons sah, reward, validasi eksternal, dan idempotensi**

Respons dinyatakan sah jika:

- Berasal dari responden yang sesuai kriteria.
- Memiliki persetujuan yang diperlukan.
- Memenuhi kelengkapan pertanyaan wajib.
- Tidak merupakan duplikat atau indikasi penyalahgunaan.
- Lolos aturan kualitas yang sudah diberitahukan sebelum pengisian.

**Jawaban tidak boleh ditolak hanya karena tidak mendukung hipotesis atau keinginan peneliti.** Durasi pengisian yang singkat cukup menjadi sinyal pemeriksaan, bukan alasan penolakan otomatis.

Usulan alur reward:

**Dikirim → Menunggu validasi → Disetujui/ditolak → Reward tersedia.**

Sumber dana reward harus berasal dari anggaran pemilik kuesioner yang sudah dibayar atau subsidi promosi Cermatify yang tercatat. Jangan menjanjikan reward sebelum dananya tersedia.

Untuk formulir eksternal:

- Jika tersedia integrasi yang dapat memverifikasi respons, gunakan identitas respons dari penyedia dan token peserta.
- Jika belum tersedia, gunakan pemeriksaan manual yang dijelaskan kepada responden.
- Screenshot bukan bukti tunggal yang cukup untuk persetujuan otomatis.

Ketentuan backend yang dapat ditetapkan sekarang:

| Kebutuhan | Aturan |
|---|---|
| Identitas respons | Satu ID internal unik untuk setiap respons |
| Hak reward | Satu pemberian reward untuk satu respons yang disetujui |
| Pencegahan duplikasi | Batas unik berdasarkan identitas peserta dan aturan kampanye |
| Idempotensi | Permintaan ulang untuk transaksi yang sama menghasilkan hasil yang sama, tanpa menambah saldo lagi |
| Audit | Perubahan status menyimpan waktu, alasan, dan pelakunya |

Backend harus memverifikasi status dan mencatat pemberian reward secara atomik. Detail teknologi boleh dipilih kemudian, tetapi prinsip **satu respons sah menghasilkan maksimal satu reward** harus menjadi persyaratan wajib.

**6. Kapasitas admin, SLA, kontak, dan pengelolaan data**

Jangan menjanjikan admin 24/7 sebelum ada personel dan pembagian shift. Untuk tahap awal:

| Komponen | Usulan |
|---|---|
| Akses aplikasi | Dapat diakses setiap saat, dengan kemungkinan pemeliharaan |
| Jam dukungan | Senin–Sabtu, 09.00–17.00 WIB |
| Target respons awal | Maksimal 1 hari kerja |
| Pemeriksaan keluhan sederhana | Target maksimal 3 hari kerja |
| Kasus kompleks | Berikan pembaruan progres maksimal setiap 2 hari kerja |
| Kontak | Email bantuan dan kanal resmi yang benar-benar dipantau |

SLA respons awal berbeda dari waktu penyelesaian. Kasus yang melibatkan bank, gateway, atau sengketa tidak boleh dijanjikan selesai sebelum pemeriksaannya tuntas.

Untuk data, saya menyarankan **tidak menerapkan penyimpanan tak terbatas secara menyeluruh**. Susun jadwal retensi berdasarkan tujuan dan jenis data:

- Dokumen akademik disimpan selama diperlukan untuk layanan dan periode penanganan keluhan yang ditetapkan.
- Dokumen verifikasi mentah dibatasi aksesnya dan dihapus ketika tidak lagi diperlukan; hasil verifikasinya dapat dicatat terpisah.
- Data transaksi mengikuti kebutuhan pencatatan dan ketentuan yang berlaku.
- Penghapusan akun memiliki prosedur yang menjelaskan data yang dihapus, dianonimkan, atau masih harus disimpan.
- Penghapusan juga mencakup siklus backup yang terdokumentasi.

Akses diberikan berdasarkan tugas: mentor hanya mengakses bahan mentee terkait, admin transaksi mengakses informasi pembayaran yang diperlukan, dan dokumen verifikasi dibatasi untuk petugas berwenang.

**Jangka retensi final serta kebijakan privasi perlu ditinjau sebelum dipublikasikan.** Preferensi menyimpan data selamanya belum cukup menjadi dasar penetapan kebijakan.

Keenam jawaban ini dapat dimasukkan sebagai **proposal keputusan pemilik**. Checklist baru ditandai selesai setelah angkanya disetujui, kebijakannya tertulis, dan implementasi aplikasi sudah sesuai.

### Backlog berdasarkan arahan baru — belum dikerjakan

- [ ] Audit khusus kesamaan Kuesioner dan Sourcelink, termasuk UI, penyimpanan, pembayaran, dan alur responden; hasilnya menjadi dasar proposal penyederhanaan.
- [x] Susun draft copy landing dan CTA (Tahap 1); persetujuan pemilik sudah diterima pada 24 Oktober 2026.
- [ ] Rancang UI pemilihan jadwal, pilihan online/lokasi, profil sosial/portofolio dan interview pada bagian yang dipilih; dukungan backend ditandai bila belum tersedia.
- [x] Terima rancangan dua paket, kuota dan harga usulan dari jawaban pemilik; penyiapan pratinjau/implementasi serta harga final dilacak sebagai pekerjaan berikutnya.
- [ ] Rancang dua baris testimoni berlawanan arah, enam entri tiap baris, dengan sumber asli; dukung reduced motion dan kontrol berhenti saat hover/fokus. Jangan menduplikasi kutipan menjadi 12 pengalaman berbeda.
- [ ] Susun FAQ untuk landing dan dashboard serta informasi bantuan admin; cocokkan setiap jawaban dengan fitur yang tersedia.
- [ ] Rancang UI reward/klaim dan status pembayaran/withdraw sesuai arah bisnis; pisahkan status contoh dari data transaksi nyata dan jangan menyatakan saldo telah dikreditkan jika backend belum tersedia.
- [ ] Bangun gateway/ledger, empat status saldo, konfirmasi transfer, minimum withdraw Rp20.000 dan reward atomik sesuai rancangan pemilik. Komisi terbaru 15% telah dikonfirmasi; pertahankan 25%/75% hanya sebagai riwayat awal. Ubah backend/controller/rules serta tes secara konsisten.
- [ ] Ikuti arahan draft awal menggunakan pertemuan daring eksternal; evaluasi video call internal pada tahap berikutnya berdasarkan kebutuhan dan biaya. Tatap muka belum ditawarkan menurut jawaban lanjutan.

### Progres pencatatan jawaban

- [x] Baca seluruh sepuluh jawaban pemilik dan pertahankan teks aslinya.
- [x] Perbarui daftar keputusan tanpa menandai implementasi fitur selesai.
- [x] Cocokkan arah baru dengan `pubspec.yaml`, register mentor, controller order/kuesioner, controller withdraw dan `firestore.rules`; tidak mengubah kode/rules.
- [x] Petakan dampak ke tahap konten, UI, dan backend; pertahankan batas pengerjaan per tahap.
- [x] Susun draft Tahap 1 berdasarkan proposal dan klarifikasi terbaru; lihat `docs/landing-page-proposal-review.md`. Copy/urutan/bagian awal sudah disetujui dan implementasi Tahap 7 dimulai.

### Hasil validasi Tahap 0

- [x] Baca lampiran UTF-8, inventarisasi file, telusuri route/controller/view/rules dan cocokkan temuan dengan lokasi kode.
- [x] Periksa status awal Git: bersih sebelum pencatatan audit.
- [x] Periksa keberadaan tes responsif dan quality gate tanpa mengubah tes/kode.
- [x] Validasi dokumentasi: `git diff --check` lulus; hanya `TODO_WEB.md` berubah; seluruh 86 butir checklist Tahap 1–9 dari lampiran tercatat, belum ditandai selesai.
- [ ] Buka dan evaluasi landing terdeploy — Belum terverifikasi. Percobaan membuka `https://yuelearningcode.github.io/cermatify/#/landing` melalui alat web gagal (URL tidak dapat diakses); tidak menyimpulkan situs mati atau menyamakan source lokal dengan versi terdeploy.
- [ ] Jalankan tes Flutter/analyzer/build — Terhambat dependensi lingkungan. Flutter tidak tersedia pada PATH; SDK ditemukan di `E:/develop/flutter`. Percobaan `E:/develop/flutter/bin/flutter.bat --version` gagal dengan Git dubious ownership dan Unable to determine engine version. Tidak mengubah global Git safe.directory, memasang SDK/dependency, atau mengklaim tes lulus.
- [ ] Uji E2E akun, dua browser, upload Cloudinary, rules terdeploy, pembayaran, dan withdraw — Belum terverifikasi; tidak menggunakan akun/data produksi atau transaksi nyata.
- [ ] Uji visual, zoom, keyboard dan screen reader — Belum terverifikasi; struktur sumber/tes yang tersedia tidak membuktikan hasil uji browser.

### Rekomendasi urutan berikutnya

Rekomendasi setelah pemilik memilih tahap: **1 → 2 → 3 → 4 (bila paket diperlukan) → 5 → 6 → 7 per bagian → 8 → 9**. Definisi tiga layanan dan Complink menjadi dasar copy; mekanisme mentoring/mentor/paket menentukan janji yang boleh ditampilkan; bukti kepercayaan dan kebijakan harus siap sebelum publikasi bagian terkait. Setelah akses SDK pulih, tutup pemeriksaan visual/runtime yang masih terbuka. Tidak melanjutkan Tahap 1 secara otomatis.

### Checklist tahap lanjutan dari arahan pemilik

Tahap 1 telah menghasilkan draft berdasarkan permintaan kajian proposal dan saran landing. Checklist Tahap 2–9 tetap belum dieksekusi sebagai tahap pengembangan; pembacaan pendukung tidak berarti seluruh tahap tersebut selesai. Copy dan bagian implementasi harus disetujui sebelum Tahap 7. Arahan awal tetap menjadi acuan dengan keputusan terbaru dicatat terpisah.

### Tahap 1 — TENTUKAN POSISI PRODUK DAN DAYA JUAL

Prasyarat:
Hasil audit Tahap 0 sudah tersedia.

Checklist:

- [x] Identifikasi target pengguna utama berdasarkan project.

- [x] Rumuskan masalah utama yang diselesaikan Cermatify.

- [x] Usulkan pesan utama landing page yang lebih konkret.

- [x] Jelaskan Paperlink, Kuesioner, dan Sourcelink menggunakan bahasa yang mudah dipahami.

- [x] Pilih 3–4 manfaat utama yang didukung fitur aktual.

- [x] Petakan setiap klaim dengan bukti atau fitur pendukungnya.

- [x] Tinjau klaim “pendamping terverifikasi” dan “24/7”.

- [x] Susun draft headline, deskripsi, dan CTA.

Arahan:

- Fokus pada manfaat pengguna.

- Jangan mengklaim paling unggul tanpa bukti.

- Bedakan akses aplikasi 24/7 dengan ketersediaan mentor.

- Integrasi layanan hanya boleh diklaim sesuai kemampuan aplikasi.

- Gunakan CTA yang menjelaskan tindakan, misalnya “Cari Mentor” jika alurnya tersedia.

Output:
Draft copy dan daftar klaim yang dapat digunakan.
Tunggu persetujuan copy sebelum menerapkannya.

Draft dan bukti: [kajian proposal serta usulan landing](docs/landing-page-proposal-review.md). Checklist di atas menandai penyusunan draft selesai; persetujuan copy telah diterima terpisah dan implementasi dicatat pada Tahap 7.

- [x] Pemilik menyetujui draft copy, urutan bagian dan implementasi awal pembuka/tiga kartu layanan pada 24 Oktober 2026.


### Tahap 2 — PERJELAS ALUR LAYANAN DAN MENTORING

Checklist:

- [ ] Petakan alur aktual masing-masing layanan.

- [ ] Identifikasi informasi yang diperlukan sebelum pengguna memesan.

- [ ] Jelaskan proses memilih mentor dan paket.

- [ ] Jelaskan pengajuan kebutuhan, jadwal, dan konfirmasi.

- [ ] Pastikan urutan pembayaran sesuai implementasi.

- [ ] Jelaskan media pertemuan dan durasi sesi.

- [ ] Jelaskan kegiatan sebelum, selama, dan sesudah mentoring.

- [ ] Tentukan informasi ringkasan sesi dan tindak lanjut yang memang tersedia.

- [ ] Identifikasi aturan penjadwalan ulang, pembatalan, dan keluhan yang belum diputuskan.

- [ ] Susun gambaran singkat Cara Kerja di landing; tempatkan petunjuk penggunaan rinci per layanan pada tutorial pop-up setelah login sesuai arahan 25 Oktober 2026.

Arahan:

- Jangan memaksakan semua layanan menggunakan alur mentoring.

- Jangan menjanjikan jaminan nilai, kelulusan, atau persetujuan dosen.

- Jika memakai video meeting eksternal, jelaskan dengan benar.

- Jika ada kebutuhan fitur baru, catat sebagai backlog terpisah.

Kriteria selesai:
Pengunjung dapat menjelaskan langkah penggunaan serta hasil layanan tanpa perlu menebak.


### Tahap 3 — RANCANG INFORMASI DAN PROSEDUR MENTOR

Checklist:

- [ ] Audit proses pendaftaran mentor yang sudah ada.

- [ ] Usulkan kriteria kompetensi sesuai bidang.

- [ ] Tentukan bukti kompetensi yang relevan dan proporsional.

- [ ] Usulkan proses pemeriksaan profil dan simulasi mentoring.

- [ ] Definisikan arti badge “terverifikasi”.

- [ ] Jelaskan tanggung jawab serta kode etik mentor.

- [ ] Susun manfaat bergabung berdasarkan dukungan platform yang tersedia.

- [ ] Jelaskan pengaturan jadwal, kapasitas, dan harga sesuai fitur aktual.

- [ ] Catat keputusan komisi, pencairan, pembatalan, dan sengketa.

- [ ] Susun konten ringkas “Gabung sebagai Mentor”.

- [ ] Susun informasi lengkap untuk halaman pendaftaran mentor.

- [ ] Susun FAQ khusus mentor.

Arahan:

- Jangan menjanjikan jumlah mentee atau pendapatan.

- Jangan memasang badge verifikasi sebelum ada proses verifikasi.

- Jangan mengubah mekanisme withdraw pada tahap penulisan konten.

Kriteria selesai:
Calon mentor memahami persyaratan, proses seleksi, tanggung jawab, manfaat, dan ketentuan pendapatannya.


### Tahap 4 — SUSUN USULAN PAKET DAN BUNDLING

Checklist:

- [ ] Periksa apakah aplikasi sudah mendukung paket.

- [ ] Identifikasi kebutuhan pengguna yang cocok dijadikan paket.

- [ ] Usulkan sedikit pilihan paket agar mudah dibandingkan.

- [ ] Jelaskan isi, jumlah sesi, durasi, hasil, masa berlaku, dan pengecualian.

- [ ] Tentukan batas chat dan review dokumen jika ditawarkan.

- [ ] Periksa kelayakan menggabungkan layanan.

- [ ] Petakan dampaknya pada pemesanan dan pembayaran.

- [ ] Pisahkan keputusan bisnis dari kebutuhan teknis.

Contoh untuk dibahas:

- Konsultasi Awal.

- Pendampingan Berkala.

- Persiapan Pengumpulan Data.

Arahan:

- Contoh tersebut bukan paket yang sudah disetujui.

- Jangan menentukan harga, diskon, atau komisi secara sepihak.

- Hindari “unlimited” dan “sampai selesai” tanpa batas yang jelas.

- Dukungan responden tidak boleh menjanjikan jawaban atau hasil penelitian tertentu.

Output awal:
Proposal paket dan dampak implementasi.
Jangan mengaktifkan penjualan paket sebelum isinya disetujui.


### Tahap 5 — PERKUAT TESTIMONI DAN BUKTI KEPERCAYAAN

Checklist:

- [ ] Periksa apakah testimoni sekarang nyata atau placeholder.

- [ ] Periksa izin penggunaan identitas dan isi testimoni.

- [ ] Prioritaskan cerita dengan masalah awal, layanan, dan manfaat spesifik.

- [ ] Tampilkan identitas sesuai izin, termasuk opsi penyamaran.

- [ ] Tambahkan periode pengalaman jika datanya tersedia.

- [ ] Tentukan dasar label “ulasan terverifikasi”.

- [ ] Perbaiki penempatan dan keterbacaan testimoni.

- [ ] Pastikan statistik memiliki sumber data yang sah.

Arahan:

- Jangan mengarang nama, kutipan, foto, rating, atau statistik.

- Jika data belum ada, buat struktur komponennya dan catat kebutuhan konten.

- Jangan menampilkan data contoh sebagai pengalaman pengguna nyata.

Kriteria selesai:
Bukti kepercayaan dapat ditelusuri dan ditampilkan secara jujur.


### Tahap 6 — SUSUN BATAS AKADEMIK DAN INFORMASI KEBIJAKAN

Checklist:

- [ ] Audit kebijakan yang sudah tersedia.

- [ ] Susun draft batas layanan akademik.

- [ ] Bedakan bantuan belajar dengan pengerjaan atas nama pengguna.

- [ ] Jelaskan larangan data, referensi, dan respons kuesioner fiktif.

- [ ] Jelaskan bahwa aturan kampus dan tugas tetap berlaku.

- [ ] Tinjau kebutuhan privasi untuk akun, dokumen, chat, dan data responden.

- [ ] Periksa kebijakan pembatalan, refund, keluhan, dan sengketa.

- [ ] Identifikasi informasi pengelola yang dapat ditampilkan.

- [ ] Catat kebutuhan pemeriksaan legalitas usaha dan PSE.

- [ ] Cantumkan sumber resmi dan tanggal pemeriksaan jika melakukan riset hukum.

Arahan:

- Draft kebijakan perlu ditinjau pemilik dan pihak yang kompeten sebelum dipublikasikan.

- Jangan menyimpulkan Cermatify sudah legal hanya dari keberadaan dokumen kebijakan.

- Jangan menambahkan nomor izin atau klaim kepatuhan tanpa bukti.

- Jangan mengumpulkan dokumen pribadi tambahan tanpa kebutuhan yang jelas.

Output:
Draft kebijakan dan daftar hal yang masih perlu diverifikasi.


### Tahap 7 — IMPLEMENTASI LANDING PAGE

Prasyarat:
Konten, alur, dan keputusan yang relevan sudah disetujui.

Checklist:

- [x] Perbarui navigasi sesuai bagian yang tersedia — Layanan, Cara Kerja dan FAQ menggulir ke bagian publik; Jadi Mentor membuka register dengan peran mentor; Masuk/Daftar tersedia; logo kembali ke awal; menu ringkas untuk HP/tablet.

- [x] Terapkan headline, deskripsi, dan CTA pembuka yang disepakati; CTA penutup diperbarui pada 25 Oktober 2026 dengan pilihan pengguna, mentor dan masuk.

- [x] Perjelas nama dan manfaat Cermat Paper, Cermat Competition dan Cermat Kuesioner pada landing.

- [ ] Tambahkan alasan memilih Cermatify yang dapat dibuktikan.

- [ ] Terapkan gambaran singkat layanan di landing; tutorial langkah penggunaan per layanan dikerjakan di dalam aplikasi setelah login, dengan tombol bantuan untuk membuka ulang.

- [ ] Tambahkan informasi mentor dan paket jika sudah siap.

- [ ] Perkuat testimoni berdasarkan data nyata.

- [ ] Tambahkan bagian ajakan bergabung sebagai mentor — Aksi Jadi Mentor pada navigasi sudah tersedia; bagian penjelasan mentor belum dibuat.

- [x] Tambahkan FAQ dasar publik untuk pengguna dan calon mentor — Enam pertanyaan tersedia dan dapat dibuka tanpa login. Rincian paket, jadwal dan kebijakan diperluas mengikuti implementasi layanan berikutnya.

- [x] Tambahkan footer berisi identitas Cermatify, navigasi bagian, FAQ, email bantuan yang dikonfirmasi, jam bantuan dan tombol kembali ke atas.

- [ ] Tambahkan tautan kebijakan setelah dokumen publiknya tersedia dan ditinjau; dokumen kebijakan belum diimplementasikan pada perubahan CTA/footer ini.

- [ ] Periksa seluruh tombol, tautan, dan navigasi.

- [ ] Hindari bagian kosong atau informasi placeholder pada tampilan publik.

Arahan:
Kerjakan per bagian yang saya pilih. Jangan merombak seluruh landing page dalam satu langkah.


### Tahap 8 — PENINGKATAN UX DAN AKSESIBILITAS

Checklist:

- [ ] Periksa layout desktop dan mobile.

- [ ] Pastikan tidak ada konten terpotong atau overflow.

- [ ] Periksa ukuran teks, kontras, dan tombol.

- [ ] Periksa navigasi keyboard dan label aksesibilitas.

- [ ] Gunakan istilah dan CTA yang konsisten.

- [ ] Tinjau apakah informasi layanan dapat dilihat sebelum login.

- [ ] Perjelas label formulir serta pesan validasi.

- [ ] Periksa loading, empty state, error state, dan status berhasil.

- [ ] Periksa apakah notifikasi mencerminkan kondisi nyata.

- [ ] Uji alur pengguna baru sampai tindakan utama.

Arahan:
Pisahkan masalah chat, transaksi, atau dashboard yang lebih besar menjadi backlog tersendiri jika berada di luar tahap aktif.


### Tahap 9 — VALIDASI DAN EVALUASI

Checklist:

- [ ] Jalankan build, lint, atau pemeriksaan project yang relevan.

- [ ] Uji CTA dan routing yang berubah.

- [ ] Uji alur pada ukuran layar yang representatif.

- [ ] Pastikan konten sesuai fitur aktual.

- [ ] Pastikan tidak ada klaim atau data contoh yang menyesatkan.

- [ ] Siapkan skenario uji untuk calon pengguna.

- [ ] Catat hasil pengujian nyata bila tersedia.

- [ ] Perbarui checklist dan daftar masalah tersisa.

Contoh tugas uji pengguna:

- Temukan layanan yang sesuai kebutuhanmu.

- Pilih mentor dan jelaskan alasanmu.

- Jelaskan isi dan batas paket.

- Temukan aturan pembatalan.

- Jelaskan bantuan akademik yang diperbolehkan.

Jangan mengarang hasil uji pengguna.

### Format laporan dan pembaruan progres

Pada setiap tahap/subtahap berikutnya, catat:

1. Tahap yang dipilih pemilik dan dikerjakan.
2. Temuan atau perubahan beserta bukti.
3. File yang diperiksa atau diubah.
4. Validasi yang dilakukan, hasil dan batasnya.
5. Keputusan yang masih diperlukan.
6. Status checklist dan rekomendasi berikutnya.

Tandai `[x]` hanya setelah perilaku yang dijanjikan tersedia dan validasi yang relevan selesai. Catat tugas yang menunggu pemilik, dependensi, atau verifikasi secara eksplisit. Audit Tahap 0 ini hanya mengubah dokumentasi; tahap lanjutan belum dimulai.

## Pemulihan lingkungan Flutter setelah instal ulang Windows

Tanggal: 24 Oktober 2026. Lingkup: menyiapkan toolchain lokal untuk proyek, terpisah dari Tahap 1–9 pengembangan produk. Tahap produk berikutnya belum dimulai.

### Progres setup

- [x] Gunakan Flutter 3.44.4 yang sudah ada di `E:/develop/flutter`, sesuai `.fvmrc`; Dart 3.12.2 disertakan SDK.
- [x] Pulihkan akses Git SDK dengan pengecualian `safe.directory` khusus `E:/develop/flutter` (tanpa wildcard).
- [x] Tambahkan Flutter, Java, Android platform-tools, command-line tools, dan emulator ke PATH pengguna.
- [x] Gunakan Android SDK yang sudah ada di `E:/android` dan Android Studio di `E:/Android Studio`.
- [x] Pasang Temurin JDK 21.0.12.1+1 di `E:/develop/jdk-21/jdk-21.0.12.1+1`; SHA-256 arsip cocok dengan metadata API resmi Adoptium.
- [x] Atur `JAVA_HOME`, `ANDROID_HOME`, `ANDROID_AVD_HOME` pengguna dan konfigurasi Flutter untuk SDK/Android Studio/JDK.
- [x] Perbaiki `android/local.properties` yang masih menunjuk profil Windows lama; file ini lokal dan diabaikan Git.
- [x] Verifikasi Android platform 36, build-tools 35.0.0/36.0.0, platform-tools, NDK 28.2.13676358 dan CMake 3.22.1 tersedia.
- [x] Pin command-line tools 22.0 pada `E:/android/cmdline-tools/22.0` agar pemeriksaan lisensi Flutter 3.44.4 tetap kompatibel. Tools 23 memakai CLI baru yang tidak lagi mengeluarkan hasil `--licenses` yang dipahami Flutter versi proyek; salinannya disimpan di `E:/develop/setup-backups`.
- [x] Pasang ekstensi VS Code `Dart-Code.flutter` dan `Dart-Code.dart-code` (versi 3.144.0).
- [x] Pemilik mengaktifkan Developer Mode; nilai Windows terverifikasi aktif dan symlink plugin berhasil dibuat.
- [x] Pulihkan dependency menggunakan `flutter pub get` pada cache profil Windows baru; tidak melakukan upgrade paket atau perubahan lockfile.
- [x] Verifikasi akselerasi emulator WHPX usable.
- [x] Pertahankan emulator `Small_Phone`; emulator lama sempat memerlukan otorisasi ADB dari profil sebelumnya.
- [x] Buat emulator `Cermatify_Dev_API37` dari system image yang sudah tersedia, tanpa mengunduh ulang system image; boot selesai (`sys.boot_completed=1`) dan ADB mengenali perangkat.
- [x] `flutter analyze --no-pub`: No issues found.
- [x] `flutter test --no-pub --reporter compact`: 158 tes lulus, termasuk tes landing responsif yang sebelumnya belum dapat dijalankan.
- [x] `flutter build web --release --no-pub --base-href /cermatify/`: berhasil; Wasm dry run berhasil. Hanya build lokal, tidak deploy.
- [x] `flutter build apk --debug --no-pub`: berhasil (build pertama 590,3 detik); APK baru `build/app/outputs/flutter-apk/app-debug.apk`, 172.188.241 byte.
- [x] Jalankan `flutter doctor -v` dengan PATH pengguna yang sudah dipulihkan: Flutter, Windows, Chrome, Visual Studio Build Tools, perangkat, dan jaringan terdeteksi.
- [ ] Lisensi opsional `microxr-sysimage-license` belum diterima. Lisensi SDK Android yang diperlukan untuk paket proyek sudah ada; tidak memasang microXR. `flutter doctor` tetap memberi satu kategori peringatan lisensi opsional ini. Belum menyatakan seluruh doctor hijau.
- [x] APK debug baru berhasil dipasang dan diluncurkan di `Cermatify_Dev_API37`; proses aplikasi aktif, tampilan awal landing terkonfirmasi melalui screenshot `build/cermatify-setup-android.png`, dan pemeriksaan log `AndroidRuntime:E`/`flutter:E` tidak menunjukkan error pada smoke test ini. Tidak login atau menjalankan transaksi.

### Lokasi dan penggunaan

| Kebutuhan | Lokasi |
| --- | --- |
| Flutter / Dart | `E:/develop/flutter/bin` |
| Android SDK | `E:/android` |
| Java / JAVA_HOME | `E:/develop/jdk-21/jdk-21.0.12.1+1` |
| Android command-line tools | `E:/android/cmdline-tools/22.0/bin` |
| ADB | `E:/android/platform-tools/adb.exe` |
| Emulator / AVD | `E:/android/emulator`, `E:/android/avd` |
| Backup variabel pengguna sebelum setup | `E:/develop/setup-backups/flutter-user-env-20261024-170938.json` |

Tutup dan buka ulang VS Code/terminal agar PATH pengguna yang baru terbaca. Proses aplikasi yang sudah berjalan dapat tetap membawa PATH lama. Tidak perlu memasang Dart SDK terpisah atau memperbarui Flutter ke versi lain untuk proyek ini.

```powershell
flutter --version
flutter doctor -v
flutter run -d chrome
flutter emulators
flutter emulators --launch Cermatify_Dev_API37
flutter devices
flutter run -d emulator-5554
```

Nomor emulator dapat berubah; gunakan ID dari `flutter devices`. Emulator uji saat setup dijalankan tanpa jendela, lalu dihentikan setelah smoke test; daemon Gradle uji juga dihentikan agar tidak menahan memori. Untuk penggunaan interaktif, luncurkan emulator melalui VS Code/Android Studio atau perintah di atas.

Pemeriksaan ini memulihkan toolchain, bukan membuktikan login, upload, pembayaran atau withdraw produksi berfungsi. Verifikasi visual manual, akun nyata dan kebijakan bisnis pada audit sebelumnya tetap terbuka.

Rujukan setup: [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup), [variabel lingkungan Android](https://developer.android.com/tools/variables), [kompatibilitas Java–Gradle](https://docs.gradle.org/current/userguide/compatibility.html), [instalasi arsip dan checksum Temurin](https://adoptium.net/installation/archives).

## Kajian proposal dan draft landing page — 24 Oktober 2026

Permintaan aktif: pelajari proposal, sarankan landing page, dan klarifikasi bagian yang belum jelas. Ini mengizinkan penyusunan draft Tahap 1; tidak mengubah kode aplikasi atau memulai seluruh tahap lanjutan.

- [x] Ekstrak proposal 57 halaman secara lokal serta tinjau diagram/tabel/tampilan yang relevan; bedakan rencana, hasil survei dan kemampuan source.
- [x] Rangkum informasi produk, target pengguna/mentor, tiga layanan, alur, harga referensi, model pendapatan, strategi, risiko dan identitas visual dengan nomor halaman.
- [x] Cocokkan nama layanan dengan Paperlink/Complink/Kuesioner/Sourcelink. Temukan bukti bahwa aksi membuat dari daftar Kuesioner menuju Sourcelink (`kuesioner_view.dart:224`); audit konsolidasi menyeluruh tetap backlog.
- [x] Susun struktur halaman, draft headline/deskripsi/CTA, empat manfaat dengan bukti source, alur per jenis layanan, serta daftar klaim yang perlu dibatasi.
- [x] Minta tiga klarifikasi yang belum terjawab; jawaban sudah diterima: nama publik mengikuti proposal, kompetensi/interview dengan semester 5 sebagai acuan, ulasan asli ada dan data/izin akan dilengkapi.
- [x] Pertahankan keputusan terbaru saat berbeda dari proposal: harga belum final, mentoring 25%/75%, pendapatan kuesioner 100% untuk Cermatify. Angka/proyeksi proposal bukan harga atau pendapatan aktif yang otomatis disetujui.
- [x] Simpan kajian lengkap di [docs/landing-page-proposal-review.md](docs/landing-page-proposal-review.md). Teks sepuluh jawaban awal pemilik dipertahankan persis.
- [x] Pemilik menyetujui copy/struktur dan bagian implementasi pertama: hero serta tiga kartu layanan.
- [ ] Materi ulasan/rating dan izin diterima serta diperiksa — Belum terverifikasi, walaupun pemilik sudah mengonfirmasi ketersediaannya.
- [ ] Selesaikan seluruh pengembangan landing/paket/jadwal/gateway/reward/backend — Bagian awal landing dikerjakan di Tahap 7; bagian lain tetap backlog dan bukan hasil kajian otomatis.

Validasi: hanya dokumentasi yang berubah. Tidak perlu menjalankan ulang Flutter karena tidak ada perubahan kode; hasil 158 tes/build pada setup sebelumnya tetap catatan sesi tersebut. PDF dan hasil ekstraksi/render tetap lokal, tidak dipublikasikan. Pemeriksaan akhir memakai `git diff --check` dan pemeriksaan status file.

## Tahap 7 — pembuka dan tiga kartu layanan, 24 Oktober 2026

Persetujuan pemilik: keseluruhan draft copy, urutan bagian, dan bagian implementasi pertama disetujui melalui chat. Bagian pertama mengikuti rekomendasi yang diajukan: pembuka dan tiga kartu layanan. Rencana peninjauan ulasan juga disetujui, tetapi materi 12 ulasan/rating, identitas sesuai izin, dan izin publikasi belum diterima untuk diperiksa.

### Perubahan dan status

- [x] Catat persetujuan copy/urutan/bagian awal pada dokumen kajian dan checklist Tahap 1.
- [x] Terapkan headline, deskripsi dan eyebrow yang sama pada hero desktop/mobile sesuai copy utama yang disetujui.
- [x] Ubah CTA hero menjadi Lihat Layanan yang menggulir ke judul/kartu layanan, dengan ruang di bawah header tetap; Masuk tetap menuju login.
- [x] Hormati preferensi pengurangan animasi pada CTA gulir.
- [x] Terapkan tiga nama publik dan manfaat/deskripsi yang disetujui: Cermat Paper, Cermat Competition, Cermat Kuesioner.
- [x] Gunakan tema, font, ilustrasi dan pola responsif yang sudah tersedia; teks kartu memakai warna yang terbaca dan tinggi mengikuti isi.
- [x] Hapus kutipan contoh dan tampilan Cerita Pengguna sementara menunggu materi asli; ganti klaim umum Pendamping terverifikasi pada hero dengan Pendampingan akademik.
- [x] Perbaiki kartu ringkasan hero yang sebelumnya memiliki tinggi tetap agar teks 200% tidak overflow.
- [ ] Terima dan periksa materi 12 ulasan/rating serta izin publikasi sebelum mengaktifkan bagian animasi — Belum terverifikasi; persetujuan rencana tidak menandai penerimaan materi selesai.
- [ ] Lanjutkan Cara Kerja per layanan, informasi mentor dan CTA akhir sesuai urutan yang disetujui — Navigasi bagian dan FAQ dasar sudah diselesaikan pada kelanjutan di bawah; bagian lainnya tetap backlog.
- [ ] Paket/harga final, jadwal, video call, gateway/reward dan konsolidasi teknis kuesioner tetap backlog tahap terkait; tidak diubah melalui pekerjaan pembuka/kartu.

### File

- `lib/app/modules/landing/views/landing_view.dart`: hero, CTA gulir, tiga kartu, ringkasan responsif dan penghapusan ulasan contoh.
- `test/landing_responsive_test.dart`: sesuaikan pemeriksaan hero dan tambahkan skenario interaksi gulir, header tetap, teks diperbesar serta pengurangan animasi.
- `docs/landing-page-proposal-review.md`: persetujuan dan status implementasi awal.
- `TODO_WEB.md`: progres, validasi dan materi yang masih menunggu.

### Validasi

- [x] `flutter analyze --no-pub`: No issues found.
- [x] `flutter test --no-pub --reporter expanded`: 162 tes lulus; log lokal `build/landing-full-test.log`.
- [x] Dua belas tes landing mencakup hero desktop/mobile, lebar 320/375/600/768/1024/1366/1440/1920, gulir tanpa berpindah route, judul layanan tidak tertutup header, serta teks 200% dengan pengurangan animasi.
- [x] `flutter build web --release --no-pub --base-href /cermatify/`: berhasil; Wasm dry run berhasil. Tidak deploy.
- [x] Smoke test Chrome lokal pada 1440×1200 dan viewport mobile 390×844; screenshot hero dan kartu ditinjau. CDP melaporkan 0 exception runtime selama pengambilan screenshot. Renderer software dipakai karena screenshot headless melalui GPU Windows sempat timeout.
- [x] Perbaikan tinggi kartu desktop berdasarkan temuan browser sudah diuji ulang melalui analyzer, seluruh tes, build dan screenshot baru.
- [x] Kembalikan perubahan otomatis dua file generated Windows agar diff aplikasi tetap terbatas pada landing dan tes terkait.
- [x] `git diff --check`: lulus. Tidak ada dependency aplikasi, aturan Firestore, transaksi, route internal atau konfigurasi produksi yang diubah.

Screenshot lokal untuk ditinjau: [desktop](build/landing-approved-desktop.png), [mobile](build/landing-approved-mobile.png), [kartu pada mobile](build/landing-approved-mobile-services.png). Server/profil browser uji terpisah dari browser pengguna; proses uji ditutup setelah selesai.

Batas validasi: viewport mobile Chrome bukan perangkat Android fisik; belum menguji ulang login, pembayaran, upload, penarikan atau akun nyata. Pemeriksaan zoom browser, screen reader dan penerimaan keseluruhan landing tetap bagian tahap berikutnya. Langkah berikut yang direkomendasikan adalah Cara Kerja dengan alur mentoring dan kuesioner yang dibedakan.

## Tahap 7 — URL root dan pratinjau ulasan, 24 Oktober 2026

Lingkup permintaan: hapus kata landing dari URL halaman awal, gunakan tabel ulasan yang diberikan, dan beri saran penempatan detail paket.

- [x] Ubah `Routes.LANDING` menjadi `/`; pertahankan `/landing` sebagai alias publik yang mengalihkan ke root tanpa mengubah guard halaman privat.
- [x] Pertahankan strategi hash untuk halaman lain agar hosting GitHub Pages tetap memakai pola yang tersedia; tidak menambahkan kebutuhan rewrite server.
- [x] Terima 12 kutipan/rating/nama **contoh fiktif** dari pemilik. Jangan mencatat tabel ini sebagai ulasan pelanggan asli atau izin identitas nyata.
- [x] Terapkan pratinjau debug/development dengan dua baris × enam entri unik, arah berlawanan, label fiktif pada bagian dan kartu, tombol jeda/lanjut, serta jeda saat hover/fokus/di luar viewport.
- [x] Pengurangan animasi/accessibility navigation menampilkan daftar statis yang dapat digeser; salinan putaran visual tidak dibacakan ulang sebagai pengguna lain.
- [x] Sembunyikan pratinjau dari release; pemeriksaan bundle memastikan nama/kutipan contoh tidak ikut sebagai konten ulasan release.
- [ ] Terima dan verifikasi data ulasan nyata beserta izin jika akan dipublikasikan sebagai pengalaman pengguna — Masih terbuka. Bagian Tahap 5 tentang bukti kepercayaan belum selesai hanya karena animasi contoh tersedia.
- [x] Baca usulan paket tambahan pemilik: Konsultasi Awal (1 × 60 menit, Rp75.000 usulan) dan Pendampingan Terarah (4 × 60 menit, Rp250.000 usulan), berikut kuota dan masa berlaku.
- [x] Catat rekomendasi: ringkasan paket di landing setelah Cara Kerja; ketentuan lengkap sebelum pemesanan. Harga/cakupan belum dinyatakan sebagai produk aktif dan bagian paket belum diimplementasikan pada pekerjaan ini.
- [ ] Selaraskan usulan komisi 15% pada catatan tambahan dengan keputusan sebelumnya 25%/75% sebelum backend/ketentuan pendapatan diperbarui — Tidak mengubah transaksi melalui pekerjaan URL/ulasan.

### Validasi perubahan ini

- [x] `flutter analyze --no-pub`: No issues found.
- [x] `flutter test --no-pub --reporter expanded`: 166 tes lulus; log `build/root-reviews-test.log`.
- [x] Tes meliputi pembukaan root dan redirect legacy, keunikan route serta guard privat, CTA landing, pergerakan dua baris berlawanan, jeda persisten, serta swipe pada teks 200%/pengurangan animasi.
- [x] Build web release dan debug berhasil; Wasm dry run berhasil. Debug disimpan lokal di `build/reviews-debug-web`, release di `build/web`; tidak deploy.
- [x] Chrome lokal memverifikasi root dan redirect URL lama pada kedua build. Dengan base href `/cermatify/`, URL akhirnya `http://127.0.0.1:8844/cermatify/`, tanpa fragmen landing. Port server pengguna tidak dipasang tetap pada kode.
- [x] Browser development desktop/mobile ditinjau dari screenshot; CDP melaporkan 0 exception runtime. Nama Aditya Pratama/Kirana Larasati dan copy pratinjau tidak ditemukan di bundle release.

File: `lib/app/routes/app_routes.dart`, `app_pages.dart`, `route_access_middleware.dart`; widget baru `lib/app/modules/landing/widgets/review_preview_section.dart`; pemanggilan pada landing; tes route, landing dan preview; dokumen kajian dan todo. Perubahan generated Windows yang sudah ada sebelum tugas ini dipertahankan.

Cara melihat: lakukan **hot restart** (`R` di terminal Flutter) atau mulai ulang `flutter run`, kemudian buka root server, misalnya `http://localhost:50822/`. Ulasan contoh terlihat pada `flutter run` mode debug; build release tidak menampilkannya. Bila port berbeda, gunakan port yang ditampilkan Flutter.

Pratinjau lokal: [desktop](build/reviews-development-desktop.png), [mobile](build/reviews-development-mobile.png). Rekomendasi paket dan status fiktif juga dicatat di [kajian landing bagian 10](docs/landing-page-proposal-review.md).

## Sinkronisasi enam jawaban pemilik — 24 Oktober 2026

Permintaan: periksa bagian jawaban pemilik dan gunakan jawaban yang sudah tersedia. Bagian tersebut sebelumnya belum tercermin lengkap pada daftar status; status tersebut kini diperbaiki.

- [x] Baca seluruh enam rincian, termasuk reward/idempotensi serta kapasitas admin/SLA/retensi.
- [x] Ubah status rincian paket/CTA, mentor, jadwal/pembatalan, transaksi, reward dan dukungan/data menjadi **draft jawaban tersedia**; jangan lagi meminta informasi dasar tersebut dari awal.
- [x] Jadikan usulan 15%, daring eksternal, jam dukungan 09.00–17.00 WIB dan retensi berbasis jenis data sebagai acuan draft terbaru, dengan riwayat jawaban awal tetap tersedia.
- [x] Catat CTA terbaru Cari Mentor / Lihat Cara Kerja / Daftar sebagai Mentor untuk iterasi berikutnya; penerapan hero sebelumnya tetap tercatat terpisah.
- [x] Pertahankan seluruh teks enam jawaban lanjutan dan sepuluh jawaban awal persis; validasi perbandingan dilakukan sebelum penulisan.
- [x] Perbarui `docs/landing-page-proposal-review.md` agar tidak lagi menyebut rincian yang telah diberikan sebagai belum tersedia.
- [ ] Implementasikan rincian yang telah dikonfirmasi pemilik sesuai syarat operasional sumber — Persetujuan terbaru diterima setelah sinkronisasi ini; pelaksanaan tetap backlog dan tidak memerlukan pengulangan jawaban dasar.

Validasi perubahan dokumentasi: perbandingan teks sumber jawaban lulus; UTF-8, struktur enam jawaban dan pemeriksaan whitespace diperiksa. Tidak mengubah kode aplikasi atau menjalankan ulang tes Flutter untuk pekerjaan dokumentasi ini. Hasil 166 tes pada tahap sebelumnya tetap catatan tahap tersebut, bukan hasil tes baru.

## Tahap 7 — navigasi landing dan konfirmasi terbaru, 24 Oktober 2026

Arahan pemilik: seluruh arahan saat ini sudah dikonfirmasi; perubahan akan diberitahukan kemudian. Untuk awal kelanjutan ini, perbarui navigasi. Persetujuan tersebut diterima tanpa meminta ulang enam jawaban yang sudah diberikan. Implementasi pada langkah ini berfokus pada navigasi dan tujuan FAQ dasarnya.

- [x] Catat enam jawaban sebagai arah yang disetujui, termasuk paket Rp75.000/Rp250.000 dan komisi mentoring 15%; pertahankan teks jawaban asli dan riwayat 25%/75%.
- [x] Buat menu desktop: Layanan, Cara Kerja, Jadi Mentor, FAQ, Masuk dan Daftar.
- [x] Sediakan menu ringkas pada HP/tablet serta saat ukuran teks diperbesar; Masuk tetap terlihat dan menu menutup setelah pilihan dibuat atau Escape ditekan.
- [x] Gulir ke bagian Layanan, Cara Kerja dan FAQ dengan judul tidak tertutup header tetap; tandai bagian aktif pada desktop. Hormati preferensi pengurangan animasi.
- [x] Jadikan logo tombol kembali ke awal halaman.
- [x] Arahkan Jadi Mentor ke formulir register yang sudah ada dengan argumen peran `mentor`; Daftar pengguna tidak membawa argumen mentor. Masuk menuju login.
- [x] Tambahkan enam FAQ dasar publik mengenai layanan, akun, pemilihan mentor, pembayaran manual, pendaftaran mentor dan batas pendampingan akademik.
- [x] Perbaiki pembungkusan teks badge ringkasan agar tampilan lebar 320 piksel dengan teks 200% tidak overflow.
- [x] Jalankan `flutter analyze --no-pub`: tidak ada masalah.
- [x] Jalankan seluruh `flutter test --no-pub --reporter expanded`: **176 tes lulus**, termasuk 10 tes navigasi baru. Log lokal: `build/landing-navigation-full-test.log`.
- [x] Bangun web rilis dengan `--base-href /cermatify/`: berhasil; Wasm dry run berhasil.
- [x] Periksa Chrome lokal pada desktop 1440×1200 dan HP 390×1000: header/menu terlihat baik; URL root dan pengalihan `/landing` tetap bekerja; **0 exception runtime** pada smoke test. Tangkapan layar lokal: `build/landing-navigation-desktop.png` dan `build/landing-navigation-mobile-menu.png`.
- [ ] Lanjutkan informasi mentor/paket serta CTA sesuai acuan yang disetujui. Arahan 25 Oktober 2026 memindahkan petunjuk penggunaan rinci ke tutorial setelah login; landing cukup menampilkan gambaran singkat Cara Kerja. Belum mengaktifkan booking, paket atau gateway melalui perubahan navigasi ini.

File implementasi: `lib/app/modules/landing/views/landing_view.dart`, `lib/app/modules/landing/widgets/landing_navigation.dart`, `lib/app/modules/landing/widgets/landing_faq.dart`, dan `test/landing_navigation_test.dart`. Kajian diselaraskan pada bagian 12 `docs/landing-page-proposal-review.md`. Belum melakukan deployment.

## Arahan tutorial setelah login — 25 Oktober 2026

Pemilik menetapkan bahwa urutan penggunaan layanan dijelaskan melalui pop-up tutorial setelah pengguna login. Tutorial juga harus bisa dipicu kembali melalui tombol ikon tanda tanya dalam lingkaran. Arahan ini menggantikan rencana menempatkan petunjuk penggunaan rinci sebagai pekerjaan landing berikutnya. Navigasi dan bagian Cara Kerja yang sudah tersedia tetap ada; pengunjung cukup mendapat gambaran singkat sebelum masuk.

- [x] Catat dua pemicu yang diminta: setelah login dan tombol bantuan untuk membuka kembali tutorial.
- [x] Selaraskan rencana landing serta kajian proposal dengan penempatan tutorial di dalam aplikasi.
- [ ] Bangun tutorial pop-up per layanan berdasarkan alur aktual Cermat Paper, Cermat Competition dan Cermat Kuesioner.
- [ ] Hubungkan tutorial dengan keberhasilan login serta tombol bantuan berbentuk tanda tanya dalam lingkaran yang mudah ditemukan.
- [ ] Siapkan tombol Sebelumnya, Berikutnya, Lewati/Tutup dan Selesai, beserta navigasi keyboard dan label aksesibilitas.
- [ ] Tentukan serta terapkan frekuensi tampil otomatis dan penyimpanan status tutorial. Rekomendasi UX: tampil otomatis pada login pertama, lalu buka ulang kapan saja melalui tombol bantuan; frekuensi ini adalah rekomendasi, bukan rincian yang sudah disebut pemilik.
- [ ] Uji pemicu login, pembukaan ulang, penutupan tutorial, perpindahan langkah dan tampilan HP/desktop sebelum menandai fitur selesai.

Status: **arahan tercatat; fitur tutorial belum diimplementasikan**. Perubahan pada langkah ini hanya dokumentasi; tidak menjalankan ulang tes Flutter. Urutan landing berikutnya berfokus pada informasi mentor/paket dan CTA dengan gambaran Cara Kerja yang singkat.

## Tahap 7 — CTA penutup dan footer, 25 Oktober 2026

Permintaan: terapkan CTA terbaru di landing dan pertimbangkan footer. Footer ringkas ditambahkan sebagai penutup serta tempat navigasi dan bantuan. Pemilik mengoreksi alamat bantuan menjadi **cermatifycompany@gmail.com**; alamat tersebut menjadi acuan terbaru.

- [x] Ganti CTA penutup lama dengan judul **Siap menentukan langkah berikutnya?**, deskripsi pilihan penggunaan, tombol **Mulai sebagai Pengguna**, **Daftar sebagai Mentor**, dan tautan **Masuk di sini**.
- [x] Gunakan alur register/login yang sudah ada: pendaftaran mentor membawa argumen `mentor`; pengguna biasa tidak membawa argumen tersebut.
- [x] Buat CTA dengan kontras biru/putih; tombol tersusun vertikal pada HP atau ukuran teks besar dan tinggi mengikuti isi.
- [x] Tambahkan footer responsif: brand/deskripsi, navigasi Lihat layanan/Cara kerja layanan/Pertanyaan umum, email bantuan, jam Senin–Sabtu 09.00–17.00 WIB, target respons awal satu hari kerja, copyright dan Kembali ke atas.
- [x] Gunakan tautan `mailto:cermatifycompany@gmail.com` untuk membuka penulisan email; tidak mengirim email secara otomatis.
- [x] Pastikan tautan bagian footer menggulir ke judul yang tidak tertutup header tetap; Kembali ke atas menuju awal halaman.
- [x] Pertahankan jawaban asli pemilik dan arahan tutorial setelah login; sinkronkan kajian pada bagian 14 `docs/landing-page-proposal-review.md`.
- [x] `flutter analyze --no-pub`: tidak ada masalah.
- [x] Seluruh `flutter test --no-pub --reporter expanded`: **186 tes lulus**, termasuk 10 tes tambahan untuk CTA/footer. Log lokal: `build/landing-cta-footer-full-test.log`.
- [x] Pengujian tambahan memeriksa tiga jalur CTA pada HP/desktop, navigasi footer, tujuan email memakai launcher tiruan, serta CTA/footer pada lebar 320 piksel dan teks 200%.
- [x] `flutter build web --release --no-pub --base-href /cermatify/`: berhasil; Wasm dry run berhasil.
- [x] Smoke test Chrome lokal pada desktop 1440×1200 dan HP 390×1000: tampilan CTA/footer ditinjau, root dan pengalihan legacy tetap berfungsi, **0 exception runtime** pada pemeriksaan ini. Screenshot lokal: [desktop](build/landing-cta-footer-desktop.png), [CTA HP](build/landing-cta-mobile.png), [footer HP](build/landing-footer-mobile.png).
- [x] `git diff --check` dan perbandingan teks enam jawaban lanjutan serta sepuluh jawaban awal: lulus.
- [ ] Tambahkan tautan syarat/privasi setelah dokumen publik tersedia dan ditinjau.
- [ ] Lanjutkan bagian informasi mentor/paket sesuai arahan yang sudah disetujui; tutorial setelah login tetap backlog tersendiri.

File aplikasi: `lib/app/modules/landing/widgets/landing_cta.dart`, `landing_footer.dart`, serta integrasi pada `lib/app/modules/landing/views/landing_view.dart`. Tes ditambahkan pada `test/landing_navigation_test.dart`. Belum deployment atau menguji pengiriman/penerimaan email sungguhan; tes email memeriksa pembukaan tujuan `mailto`, bukan status kotak masuk.

## Penanda edit style Cara Kerja — 25 Oktober 2026

- [x] Tambahkan komentar yang bisa dicari dengan `EDIT CARA KERJA` pada `lib/app/modules/landing/views/landing_view.dart`: judul/subjudul, isi empat langkah, kolom/breakpoint, jarak, lingkaran/angka, judul langkah, deskripsi dan garis bawah.
- [x] Tandai bahwa `_SectionHeader` juga dipakai bagian Layanan dan FAQ sehingga perubahan stylenya memengaruhi bagian tersebut.
- [x] Pertahankan isi empat langkah dan pengaturan style terbaru pengguna; langkah ini hanya menambahkan komentar panduan.

Validasi: pemeriksaan lokasi penanda dan `git diff --check`. Tidak menjalankan ulang tes Flutter karena perubahan langkah ini hanya komentar dan dokumentasi.

## Posisi nomor Cara Kerja di atas teks — 25 Oktober 2026

- [x] Ubah susunan `_StepTile` dari `Row` menjadi `Column` dengan rata kiri; lingkaran nomor berada di atas judul dan deskripsi.
- [x] Ganti jarak horizontal dengan `SizedBox(height: 12)`; hapus pembungkus `Expanded` agar tinggi langkah mengikuti isi; garis bawah tetap selebar kolom.
- [x] Perbarui komentar `EDIT CARA KERJA` untuk menunjukkan pengaturan posisi serta jarak vertikal nomor.
- [x] Jalankan 32 tes landing responsif dan navigasi: seluruhnya lulus. Log lokal: `build/landing-steps-layout-test.log`.
- [x] `git diff --check`: lulus.

File: `lib/app/modules/landing/views/landing_view.dart`, komponen `_StepTile`. Isi empat langkah dan jumlah kolom mengikuti perubahan pengguna yang sudah tersedia.

Catatan validasi tambahan: `flutter analyze --no-pub` dan analisis langsung file tidak mengembalikan hasil selama pemeriksaan, sehingga dihentikan. Tidak mengklaim analisis statis lulus pada langkah ini; kompilasi serta 32 tes landing/navigasi di atas berhasil.

## Alignment tengah layanan/Cara Kerja dan akses Firebase — 25 Oktober 2026

- [x] Ratakan judul/subjudul bagian Layanan dan Cara Kerja ke tengah dengan parameter `textAlign` pada `_SectionHeader`.
- [x] Posisikan ikon dan seluruh teks pada tiga kartu layanan di tengah.
- [x] Posisikan lingkaran nomor di tengah atas judul; ratakan judul/deskripsi ke tengah pada keempat langkah Cara Kerja.
- [x] Pertahankan isi dan jumlah langkah terbaru pengguna serta layout responsif yang tersedia; beri komentar penanda alignment untuk pengeditan berikutnya.
- [x] Jalankan 32 tes landing responsif dan navigasi: seluruhnya lulus. Log lokal: `build/landing-center-layout-test.log`.
- [x] Catat laporan pemilik bahwa akses Firebase sudah tersedia kembali; perbarui status penundaan di bagian P1 Firebase Web. Konfigurasi lokal menunjuk proyek `cermatify`.
- [ ] Verifikasi akses proyek melalui Console/sesi pengembangan, Authorized Domains, login/registrasi tiap role, persistence/logout, dan kesiapan App Check sesuai checklist P1. Status pengujian tersebut tetap belum selesai; perubahan alignment ini tidak menerapkan konfigurasi atau deployment Firebase.

File UI: `lib/app/modules/landing/views/landing_view.dart`, komponen `_SectionHeader`, `_FeatureTile` dan `_StepTile`. Validasi langkah ini menggunakan kompilasi/widget test dan pemeriksaan diff; tidak mengklaim hasil analisis statis atau build web baru.

## Logo footer berbingkai biru — 25 Oktober 2026

- [x] Tambahkan logo Cermatify di sebelah kiri nama brand pada footer, menggunakan aset `assets/images/logo.jpeg`.
- [x] Gunakan kotak 48×48, border biru 1,5 piksel, radius sudut 12 dan jarak 12 ke nama brand; teks dapat membungkus pada layar sempit/ukuran teks besar.
- [x] Tandai pengaturan dengan komentar `EDIT LOGO FOOTER` pada `lib/app/modules/landing/widgets/landing_footer.dart`.
- [x] Empat tes footer yang sudah tersedia lulus: navigasi desktop/HP, tautan email, serta lebar 320 piksel dengan teks 200%. Format Dart dan `git diff --check` bersih.

## Domain dan usulan fokus berikutnya — 25 Oktober 2026

Pemilik menyatakan akses Firebase sudah tersedia dan memiliki domain **cermatify.com**, tetapi belum melakukan hosting. Ini pencatatan informasi pemilik; belum memverifikasi kepemilikan/DNS, menghubungkan domain atau menerapkan deployment.

- [x] Catat domain produksi yang direncanakan sebagai `cermatify.com`; domain REST API lama `cermatify.my.id` tetap tidak digunakan.
- [x] Susun rekomendasi: lanjutkan validasi backend/integrasi alur inti sebelum memperluas UI. Landing sudah memiliki pembuka, layanan, Cara Kerja ringkas, FAQ, CTA dan footer.
- [ ] Prioritas pertama yang direkomendasikan: verifikasi proyek Firebase/konfigurasi lokal, domain development, registrasi/login customer/mentor/admin, verifikasi mentor, persistence/logout serta akses data sesuai role. Checklist emulator yang sudah lulus tidak otomatis membuktikan perilaku proyek Firebase aktual.
- [ ] Selesaikan P0 upload: pencabutan secret Cloudinary lama dan pembatasan preset sebelum memakai upload nyata.
- [ ] Validasi alur inti bertahap: profil/daftar mentor → pengajuan/order → upload bukti → verifikasi admin → chat; jalur kuesioner diuji tersendiri. Gunakan data uji yang terpisah untuk pemeriksaan.
- [ ] Bangun transaksi tepercaya/ledger, komisi 15%, withdraw/refund dan reward sesuai rancangan yang dikonfirmasi sebelum dinyatakan aktif; gateway mengikuti kesiapan alur pembayaran.
- [ ] Sesuaikan UI, keadaan loading/error dan tutorial setelah login berdasarkan alur yang telah berhasil diuji.
- [x] Siapkan dan deploy Firebase Hosting awal pada `https://cermatify.web.app` berdasarkan permintaan pemilik 25 Oktober 2026.
- [ ] Sambungkan domain `cermatify.com` dan selesaikan pemeriksaan Auth/App Check serta penerimaan fitur sebelum menyatakan seluruh layanan siap produksi.

Status: **rekomendasi urutan, belum memulai perubahan backend atau konfigurasi eksternal**. Hosting domain bukan prasyarat untuk melanjutkan pengujian lokal/emulator. Rujukan teknis: [Firebase Local Emulator Suite](https://firebase.google.com/docs/emulator-suite), [Hosting: test/preview/deploy](https://firebase.google.com/docs/hosting/test-preview-deploy) dan [Hosting: custom domain](https://firebase.google.com/docs/hosting/custom-domain). Perubahan pada langkah ini hanya dokumentasi; tidak menjalankan ulang tes aplikasi.

## Penyesuaian panduan Firebase Hosting — 25 Oktober 2026

Pemilik membagikan panduan Firebase Hosting/Spark dan domain kustom. Panduan ditinjau terhadap proyek lokal serta dokumentasi resmi; belum menjalankan inisialisasi, deployment atau perubahan DNS.

- [x] Identifikasi penyesuaian Flutter: artefak publik adalah hasil build `build/web`; untuk domain root gunakan base href `/`, menggantikan `/cermatify/` yang dipakai workflow GitHub Pages saat ini. Sertakan konfigurasi build upload/App Check yang berlaku ketika menyiapkan rilis.
- [x] Konfirmasi kondisi lokal: `firebase.json` sudah memuat konfigurasi Flutter dan Firestore Rules, tetapi belum memiliki bagian Hosting; `.firebaserc` belum tersedia. Konfigurasi yang sudah ada perlu dipertahankan saat penyiapan Hosting.
- [x] Catat bahwa Spark menyediakan kuota Hosting tanpa biaya dalam batas pemakaiannya; status billing proyek aktual belum diverifikasi melalui Console.
- [x] Siapkan konfigurasi Hosting untuk `build/web`, pilihan proyek `cermatify`, uji artefak lalu deploy khusus Hosting pada 25 Oktober 2026. Deployment tidak sekaligus menerapkan Firestore Rules yang tercantum di konfigurasi.
- [ ] Setelah artefak teruji, pertimbangkan preview Hosting untuk pengujian bersama; penyambungan `cermatify.com` memerlukan konfigurasi domain/DNS dan pemeriksaan HTTPS serta Firebase Auth/App Check.

Referensi: [Hosting quickstart](https://firebase.google.com/docs/hosting/quickstart), [kuota dan harga Hosting](https://firebase.google.com/docs/hosting/usage-quotas-pricing), [custom domain](https://firebase.google.com/docs/hosting/custom-domain). Perubahan pada langkah ini hanya dokumentasi; tidak menjalankan ulang tes Flutter.

## Inisialisasi dan deployment Firebase Hosting — 25 Oktober 2026

Permintaan pemilik: lakukan init dan deploy. Penyiapan dilakukan dengan menambahkan konfigurasi Hosting ke file yang sudah ada; tidak menjalankan wizard yang dapat menimpa konfigurasi Flutter/Firestore atau `index.html` hasil build.

**Hasil live:** [cermatify.web.app](https://cermatify.web.app) dan [cermatify.firebaseapp.com](https://cermatify.firebaseapp.com). Situs `cermatify`, versi Hosting `a6a8304593f4a2c9`, rilis 25 Oktober 2026 sekitar 15.42 WIB. Domain `cermatify.com` belum disambungkan.

- [x] Tambahkan `hosting.public = build/web`, fallback ke `index.html`, serta header `Cache-Control: no-cache` di `firebase.json`; pertahankan konfigurasi Flutter/Firestore yang sudah ada.
- [x] Tambahkan `.firebaserc` dengan proyek default `cermatify`; abaikan cache deployment lokal `.firebase/` melalui `.gitignore`.
- [x] Siapkan Firebase CLI 15.28.1 melalui `npx`; pemilik menyelesaikan autentikasi Google langsung di browser. CLI terautentikasi sebagai `cermatifycompany@gmail.com` dan akses situs proyek dikonfirmasi lewat API Hosting.
- [x] Build rilis Flutter Web terbaru dengan base href `/`, cloud `rgovyuw1` dan preset `flutter_upload`; build serta Wasm dry run berhasil.
- [x] Seluruh 186 tes Flutter lulus sebelum deployment. Log lokal: `build/firebase-hosting-full-test.log`.
- [x] Validasi JSON/target/base href dan pemindaian pola credential privat pada artefak: lulus. Tidak menyimpan token CLI di repository.
- [x] Periksa build root lokal di Chrome: landing, legacy `/landing`, serta guard tamu `/profile` dan `/admin-dashboard` lulus; 0 exception runtime pada smoke test.
- [x] Jalankan deploy khusus Hosting melalui `npx --yes firebase-tools@15.28.1 deploy --only hosting --project cermatify --non-interactive`; CLI melaporkan Deploy complete. Log lokal: `build/firebase-hosting-deploy.log`.
- [x] Verifikasi HTTPS/HTTP 200 serta SHA-256 file publik terhadap build lokal untuk `index.html`, `flutter_bootstrap.js`, `main.dart.js`, `manifest.json` dan logo. Alamat alternatif `cermatify.firebaseapp.com` juga menyajikan index yang sama.
- [x] Periksa situs live di Chrome: root, pengalihan legacy dan dua guard tamu lulus; 0 exception runtime pada smoke test. Screenshot lokal: `build/firebase-hosting-live.png`.
- [x] Perbarui petunjuk deploy ulang dan rollback di `docs/WEB_DEPLOYMENT.md`; `git diff --check` lulus.
- [ ] Sambungkan DNS/domain `cermatify.com` ke Hosting, lalu periksa HTTPS dan konfigurasi Auth/App Check domain tersebut.
- [ ] Lengkapi penerimaan login/registrasi tiap role, upload nyata, transaksi dan persyaratan backend lainnya; deployment Hosting ini tidak membuktikan seluruh alur bisnis sudah aktif.
- [ ] Isi site key reCAPTCHA dan selesaikan App Check sesuai checklist P1. Build ini mengikuti pengecualian sementara tanpa App Check yang sudah tercatat; tidak mengubah enforcement atau deploy Firestore Rules.

Batas validasi: belum menjalankan analisis statis baru pada tahap deployment ini karena percobaan sebelumnya tidak mengembalikan hasil. Build release dan seluruh tes lulus. Workflow GitHub Pages yang sudah tersedia tidak diubah, dan tidak mengubah DNS atau menambah tagihan/billing proyek.

## Verifikasi DNS domain kustom — 25 Oktober 2026

- [x] Periksa DNS setelah pemilik memasang record melalui Hostinger: A `cermatify.com` mengarah ke `199.36.158.100` dan TXT berisi `hosting-site=cermatify`.
- [x] Konfirmasi TXT terlihat melalui resolver lokal serta nameserver `aurora.dns-parking.com` dan `nebula.dns-parking.com`.
- [ ] Selesaikan verifikasi Firebase dan provisioning HTTPS. Saat pemeriksaan ini, HTTPS `cermatify.com` belum lolos validasi sertifikat; belum menyatakan domain Connected atau HTTPS siap.

Tidak mengubah record DNS pada langkah pemeriksaan ini. Pemilik dapat mencoba Verify kembali; propagasi DNS dan provisioning sertifikat dapat memerlukan hingga 24 jam menurut [dokumentasi Firebase](https://firebase.google.com/docs/hosting/custom-domain).

## Panduan pembaruan Hosting dari VS Code — 25 Oktober 2026

- [x] Catat laporan pemilik bahwa domain sudah berstatus **Minting certificate**; provisioning HTTPS masih berlangsung, belum menyatakan Connected berdasarkan laporan ini.
- [x] Dokumentasikan alur simpan/uji lokal → build Flutter rilis dengan base href `/` → deploy khusus Hosting → periksa situs di `docs/WEB_DEPLOYMENT.md`.
- [x] Jelaskan bahwa hot reload dan commit/push Git tidak otomatis memperbarui Firebase Hosting pada konfigurasi saat ini; workflow GitHub yang tersedia masih menargetkan Pages.
- [x] Catat bahwa inisialisasi/domain DNS tidak perlu diulang untuk perubahan UI biasa, sedangkan login CLI diulang bila sesi memerlukannya dan konfigurasi build publik harus dipertahankan.
- [ ] Pertimbangkan otomatisasi Firebase Hosting melalui GitHub Actions sebagai pekerjaan terpisah jika dibutuhkan.

Langkah ini hanya memperbarui petunjuk/status; tidak melakukan deployment baru atau mengubah DNS. Uji aplikasi tidak dijalankan ulang untuk perubahan dokumentasi.
