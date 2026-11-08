# Persiapan rilis Cermatify — 28 Oktober 2026

**Bundle lokal terbaru - 8 November 2026: 1.0.0+6.** Memuat kategori/label kompetisi, privacy policy/retensi, desain daftar mentor dan daftar layanan yang bisa dijelajahi sebelum mengetik. Package com.cermatify.app, min SDK 24/target SDK 36. Build release berhasil, bundletool validate dan jarsigner (jar verified) lulus; alignment 16 KB lulus untuk 8 library 64-bit. Warning SDK/Kotlin dan signing yang sudah dicatat tetap ada. Belum diunggah/diterima Play dan belum dinyatakan siap produksi.

- File utama: `build/app/outputs/bundle/release/app-release.aab`.
- File untuk dipilih saat upload: **`build/play-candidates/cermatify-1.0.0+6.aab`**.
- Ukuran: **69,778,511 byte**; SHA-256 **`28b131ea3ffbb50e5abc21cc46d52084c27dcfaee8f54b7725e64f6bee7baee8`**.
- Acuan kode terakhir: analyzer bersih, 240 tes Flutter lulus pada pekerjaan pencarian layanan. Pada pembuatan AAB ini hanya versi dinaikkan menjadi 1.0.0+6.
- Nama file tidak mengubah identitas/versi internal. Setiap pembaruan Play harus memakai versionCode yang belum dipakai; lihat [Android versioning](https://developer.android.com/studio/publish/versioning).
- Catatan +5 dan sebelumnya di bawah adalah riwayat; penghalang backend/pembayaran/migrasi/rollout tetap harus diselesaikan.

**Perubahan setelah build +5 (7 November 2026):** kategori kompetisi, select dengan pencarian dan pembaruan privacy policy/retensi satu tahun sudah ditambahkan di source. AAB +5 di bawah tidak memuat perubahan tersebut. Lihat `COMPETITION_CATEGORIES.md`, `PRIVACY_POLICY.md` dan `PRIVACY_OPERATIONS.md`; diperlukan build dengan version code lebih tinggi untuk distribusi berikutnya.

**Bundle sebelumnya - 7 November 2026: `1.0.0+5`.** Memuat kode backlog terbaru; package `com.cermatify.app`, target SDK 36. Build release berhasil; analyzer bersih dan 210 tes Flutter lulus. Bundletool validate, signature (`jar verified`) dan alignment native 64-bit 16 KB lulus, dengan warning yang dicatat di TODO. Belum diunggah/diterima Google Play atau diuji melalui Play Store. Penghalang backend/pembayaran/migrasi produksi di bawah tetap berlaku.

- File utama: `build/app/outputs/bundle/release/app-release.aab`.
- Salinan untuk dipilih saat upload: `build/play-candidates/cermatify-1.0.0+5.aab`.
- Ukuran: **69.603.014 byte**; SHA-256 **`63926c7bd73923d20b6171858bf6917d604baf6ac14b6ec5b22a84231b223fa5`**.
- `pubspec.yaml` pada build tersebut menyimpan versi `1.0.0+5`; kandidat +4 disimpan sebagai referensi. Keterangan 2 November berikut merupakan catatan historis.


**Status terbaru 2 November 2026:** kode kandidat `1.0.0+4` menambahkan pemisahan profil privat/publik dan migrasi yang diuji lokal. Lihat [panduan migrasi profil](PUBLIC_PROFILE_MIGRATION.md). Analyzer bersih; 202 tes Flutter, 12 unit backend/CLI, 25 rules, 17 integration test lulus; 7 tes legal diulang setelah perubahan dokumen dan lulus. Belum melakukan migrasi atau deployment produksi. Build awal `+4` gagal akibat Gradle 9.7.1 tidak kompatibel dengan AGP 8.11.1; wrapper dikembalikan ke 8.14 setelah konfigurasi sebelumnya disalin untuk referensi. Pembayaran tetap nonaktif dan backend eksternal belum diputuskan. Rilis publik belum siap.

### Artefak sebelumnya `1.0.0+4` — 2 November 2026

- Path: `build/app/outputs/bundle/release/app-release.aab`.
- Ukuran: **69.585.515 byte**; SHA-256 **`dbaf5a1cb537bfa9674e2707ffbac25d1e7d99ac81440b5a02a8092dd3cac08e`**.
- Build ulang dengan Gradle 8.14 berhasil. Bundletool validate lulus; manifest memuat `com.cermatify.app` dan version code `4`; jarsigner menyatakan `jar verified`; seluruh 12 native libraries lolos pemeriksaan ELF alignment 16 KB.
- Log lokal: `build/play-release-nov2-aab-compatible.log`, `build/play-release-v4-bundle-validation.log`, `build/play-release-v4-signature.log`, `build/play-release-v4-native.json`.
- Masih terdapat warning SDK XML/Kotlin/deprecation dan fallback cache lintas drive. Jarsigner tetap memberi warning sertifikat/metadata ZIP seperti kandidat sebelumnya. Tidak memodifikasi ZIP AAB secara manual. Penerimaan dan pengujian melalui Google Play belum dilakukan.
- APK dan build web lama belum dibangun ulang pada tahap ini. Kandidat `+3` disimpan di `build/play-candidates/cermatify-1.0.0+3.aab` sebagai referensi; file AAB pada path utama kini `+4`.
- Ini kandidat **pengujian**, bukan pernyataan siap produksi. Rules/proyeksi akun dan backend harus dimigrasikan sebelum memakai client ini pada layanan hidup. Belum mengunggah ke Play, menerbitkan legal baru, atau melakukan pembayaran.

**Pembaruan 1 November 2026:** kandidat kode `1.0.0+3` menambahkan moderasi chat, blokir dua arah, persetujuan usia 18+ dan pengetatan akses akun. Pemilik menyebut identitas Windia/Cermatify dan memilih tetap Spark serta mengkaji backend eksternal dahulu. Informasi VPS belum terkonfirmasi karena penjelasan lanjut menyebut Firebase Google. Baca [kajian backend](BACKEND_SPARK_OPTIONS.md), [operasi moderasi dan usia](MODERATION_RELEASE_CHECKLIST.md), dan bagian 1 November pada `TODO_WEB.md`. Pembayaran masih belum operasional; tidak ada deployment baru. Hasil/hashes `+2` di bawah merupakan bukti tahap sebelumnya, bukan bukti build `+3`.

Pemeriksaan 1 November: analyzer bersih; 199 tes Flutter lulus dan 26 tes terkait diulang setelah koreksi; 11 unit backend, 15 integration test backend, 21 tes rules lulus. Uji backend menggunakan emulator `demo-cermatify`. Tidak melakukan uji pembayaran nyata atau menganggap deklarasi usia sebagai verifikasi identitas. Draft target audience kini 18 and over; deklarasi content rating tetap berdasarkan fungsi/konten sebenarnya.

### Validasi AAB `1.0.0+3` — selesai 2 November 2026

Build selesai 1 November, pemeriksaan terakhir sempat tertunda akibat batas penggunaan alat. Bundletool validate lulus, manifest `com.cermatify.app` dengan version code `3`, jarsigner menyatakan `jar verified` dengan warning, dan pemeriksaan ELF alignment 16 KB lulus untuk 12 native libraries. Ukuran **69.571.869 byte**, SHA-256 **`89bc1c5d5a6a61a873f55dda2c81c60d0dc6505fd3a7ebf6f401637ef7b23ede`**. Log lokal: `build/play-release-nov2-bundle-validation.log`, `build/play-release-nov2-signature.log`, `build/play-release-nov2-native.json`.

Artefak pada saat validasi: `build/app/outputs/bundle/release/app-release.aab`. APK lama belum dibangun ulang dalam tahap ini. AAB ini belum mencakup pengerjaan privasi profil yang dimulai 2 November; jangan menganggapnya representasi semua source terbaru. Gradle wrapper ditemukan berubah ke 9.7.1 setelah waktu build AAB tersebut; validasi artefak tidak membuktikan build ulang dengan wrapper terbaru berhasil. Perubahan wrapper tidak ditimpa ketika melanjutkan pekerjaan.

**Status: kandidat pengujian lokal, belum layak dikirim ke produksi Play.** Aplikasi `com.cermatify.app` sudah dibuat pemilik di Play Console; produk pembayaran belum dibuat. Pemilik menetapkan rilis pertama tetap berbayar. Tidak mengunggah AAB, mengaktifkan produk, menaikkan paket billing, menerapkan rules baru, atau mempublikasikan dokumen legal dalam tahap ini.

## Perubahan yang disiapkan

**Keputusan 29 Oktober 2026:** pemilik mengonfirmasi proyek masih Spark dan belum ingin mengaktifkan billing. Deployment Functions yang disiapkan ditunda; pembayaran tetap nonaktif. Target rilis berbayar tidak dibatalkan. Lanjutkan persiapan UI, dokumen dan pengujian lokal tanpa menganggap kandidat sudah siap produksi. Backend eksternal belum dipilih; perpindahan infrastruktur bukan bagian dari persetujuan ini. Jangan deploy rules migrasi pencairan tanpa backend yang menyertainya.

- Android memakai Google Play Billing pada checkout pendampingan dan pengajuan kuesioner, dengan harga lokal dari Play. Tidak menampilkan QRIS atau upload bukti bayar pada kedua checkout Android. Web tetap memakai alur manual yang ada; kelayakan App Store iOS belum dicakup.
- Paket Android mengikuti keputusan pemilik: Awal Rp75.000 (1 sesi 60 menit, 3 topik chat/3 hari, review 5 halaman, masa layanan 14 hari), Intensif Rp250.000 (4 sesi 60 menit, 12 topik chat, 4 review 10 halaman, 30 hari). Informasi cakupan ditampilkan sebelum membeli. Batas pemakaian aktual per paket masih perlu ditegakkan dan diuji pada alur layanan; pencatatan `packageId` saja belum merupakan sistem kuota lengkap.
- Pembelian hanya menghasilkan pesanan setelah Google Developer API mengonfirmasi status PURCHASED, satu unit, dan kecocokan hash akun, produk serta ID intent. Token dipakai satu kali; transaksi Firestore menyimpan receipt, order dan kuesioner secara atomik. Harga kiriman klien diabaikan. Harga katalog adalah nilai kontrak internal, **bukan bukti nilai settlement bersih Google**.
- Consumption/acknowledgement dilakukan backend setelah penyimpanan berhasil. Pembelian pending tidak memberikan hak layanan. RTDN menyelesaikan pembelian saat aplikasi tertutup dan merekonsiliasi pembatalan/refund dengan memeriksa Google kembali. Listener login/periksa pembelian membantu pemulihan di aplikasi.
- Hak mentor 85%, komisi platform 15%, mengikuti keputusan sebelumnya. Dana mentor masuk `playPending`, baru menjadi `playAvailable` saat layanan selesai. Pesanan Play tidak dapat diproses dengan approval client lama yang mengkreditkan harga penuh.
- Pencairan minimal Rp20.000 dilakukan melalui backend: saldo tersedia dikurangi dan `playPayoutReserved` ditambah saat permintaan dibuat. Persetujuan belum berarti transfer selesai. Admin baru mencatat selesai setelah transfer nyata berhasil dan mengisi referensi transfer. Tidak ada integrasi transfer bank otomatis.
- Refund mengurangi pending/available yang terkait; bila dana sudah dicadangkan/dicairkan, kasus ditahan dengan `playPayoutHold` dan `playDebt` untuk rekonsiliasi manual. Jangan menghapus hold tanpa audit ledger dan penyelesaian kewajiban.
- Privasi, syarat, permintaan hapus akun dapat dibaca tanpa login dan dari profil/registrasi/footer. Permintaan hapus akun melalui email, **bukan penghapusan otomatis**. Semua isinya perlu ditinjau terhadap operasi nyata sebelum dipublikasikan. Data contoh tidak lagi menggantikan rekomendasi kuesioner ketika query gagal.

## Urutan aktivasi yang perlu diselesaikan

1. Tinjau dokumen legal di `assets/legal/` dan proses operasional penghapusan di bawah. Tetapkan periode retensi per jenis data dan pengecualian yang benar-benar berlaku. Nama pengelola pada kebijakan harus cocok dengan identitas pengembang/entitas pada listing. Jangan mengisi Data safety seolah akun langsung terhapus ketika tombol email dibuka.
2. Selesaikan verifikasi akun developer, profil pembayaran merchant Google, negara penjualan dan detail pajak. Produk di bawah adalah one-time consumable, bukan langganan. Google Play dapat membatasi produk/pengujian sampai aplikasi dan profil pembayaran siap.

   | Product ID yang diusulkan | Nama | Harga Indonesia yang harus diperiksa di Play |
   | --- | --- | --- |
   | `cermatify_mentoring_basic` | Pendampingan Awal Cermatify | Rp75.000 |
   | `cermatify_mentoring_intensive` | Pendampingan Intensif Cermatify | Rp250.000 |
   | `cermatify_questionnaire` | Pengajuan Cermat Kuesioner | Rp25.000 |

   Gunakan penawaran pembelian biasa untuk produk satu kali; kode belum memilih penawaran diskon/kuantitas banyak. Periksa harga akhir, pajak dan biaya Google. **Komisi platform 15% tidak otomatis menutup biaya Google, pajak, diskon dan transfer**; hitung margin sebelum mengaktifkan penjualan. Jangan mengurangi hak mentor secara diam-diam. Biaya gateway GoPay/Midtrans tidak menggantikan biaya Play Billing.
3. Aktifkan Google Play Android Developer API pada proyek Cloud yang sesuai. Beri service account runtime Functions akses minimum yang dibutuhkan di Play Console untuk verifikasi/consumption pembelian, dan akses Firestore melalui IAM. Gunakan identitas runtime/ADC; jangan memasukkan JSON private key ke Flutter, chat atau Git. Jangan menganggap login Firebase CLI otomatis memberi akses Developer API.
4. Untuk deployment Functions, proyek Firebase perlu mendukung billing/Blaze. **Belum mengaktifkan atau menyetujui perubahan biaya.** Region yang disiapkan `asia-southeast2`, Node 22, `maxInstances: 5`; batas instance bukan batas biaya. Siapkan budget alert dan tinjau biaya Functions, Firestore, Cloud Build, Artifact Registry, Pub/Sub serta retry.
5. Deploy backend dan rules sebagai satu migrasi terencana. Client pencairan sekarang memanggil Functions; jangan merilis client baru tanpa backend/rules yang sesuai. Katalog produk tidak dapat ditulis client, termasuk client admin. Buat tiga dokumen `playBillingCatalog/{mentoring_basic|mentoring_intensive|kuesioner}` sesuai template `functions/play-billing-catalog.example.json` melalui tooling admin tepercaya. Biarkan `enabled: false` sampai uji siap.
6. Hubungkan RTDN Play Console ke topic `cermatify-play-billing` di proyek yang sama. Beri Google Play publisher IAM Pub/Sub Publisher sesuai dokumentasi Google, bukan akses publish publik. Cek test notification, retry, metrik error dan jalur eskalasi. Rekonsiliasi juga laporan keuangan dan Voided Purchases API agar hilangnya notifikasi tidak menyembunyikan refund; job rekonsiliasi berkala belum dibuat.
7. Deploy dokumen web dari build Flutter setelah tinjauan. URL yang disiapkan: `https://cermatify.com/legal/privacy.html`, `/legal/terms.html`, `/legal/delete-account.html`. File HTML mandiri tidak memerlukan JavaScript/login. Regenerasi setelah mengedit JSON: `python tool/generate_legal_pages.py`, lalu build web dan deploy Hosting. **URL tersebut belum dipublikasikan/diverifikasi pada tahap ini**; rewrite SPA dapat mengembalikan HTTP 200 walaupun file belum ada, jadi periksa isi dokumen, bukan status HTTP saja.
8. Unggah AAB kandidat ke internal testing, daftarkan license tester serta tester track dan gunakan akun Google yang tepat di Play Store. Aktifkan katalog dan `PLAY_BILLING_ENABLED=true` hanya untuk rangkaian uji yang terkontrol sesudah backend berhasil diverifikasi. Ini tidak otomatis menjadikan aplikasi siap produksi. Jangan mencoba pembelian uang nyata untuk menggantikan pengujian license tester.
9. Jalankan skenario di bawah, isi listing dan deklarasi, selesaikan closed testing bila dashboard mewajibkan, lalu ajukan akses produksi/review setelah semua penghalang selesai.

## Penerimaan pembayaran dan keuangan

Wajib diuji melalui aplikasi yang dipasang dari track Play, bukan hanya APK sideload:

- Beli paket Awal dan Intensif pada mentor terverifikasi untuk setiap jenis layanan; harga/cakupan/ID pesanan cocok. Product ID dapat dipakai banyak kategori, tetapi setiap transaksi tetap terikat ke satu mentor dan layanan.
- Batalkan dialog, pembayaran ditolak, pending lalu berhasil, pending lalu batal. Tidak ada order aktif/saldo bertambah pada pending/cancelled.
- Tutup aplikasi sebelum callback, putus jaringan sesudah ditagih dan sebelum consumption, buka kembali serta periksa pembelian. Satu token menghasilkan satu order dan satu ledger.
- Akun aplikasi berbeda dari pemilik pembelian, token diulang dan token dipindah pesanan ditolak. Error tidak membocorkan token, kredensial atau data pembayaran.
- Ajukan dan selesaikan kuesioner: data kriteria konsisten dengan filter responden, tautan https valid, konten menunggu moderasi admin. Persetujuan pembayaran tidak otomatis menyetujui isi survei atau keabsahan respons/reward.
- Approval mentor tidak mengubah dana pending menjadi tersedia; penyelesaian layanan melakukannya sekali. Pengujian batas sesi/chat/review paket dan penyelesaian sengketa masih diperlukan.
- Dua pencairan bersamaan tidak boleh memakai saldo yang sama. Ulangi request ID untuk simulasi timeout. Tolak permintaan, setujui lalu catat transfer, serta uji gagal transfer. Saldo dicadangkan/dirilis/dihabiskan tepat sekali.
- Refund sebelum dan setelah layanan selesai, setelah reservasi, dan setelah payout. Periksa hold/debt serta rekonsiliasi manual tanpa mengirim transfer ganda. Admin harus menggunakan Play Console/proses refund tepercaya: status `refund_requested` sendiri belum mengirim uang kembali.
- Uji keseluruhan login/registrasi/logout, izin unggahan, chat, moderasi mentor, penerimaan layanan, koneksi gagal dan perangkat fisik ARM64. Smoke test landing/login lama belum membuktikan semua alur ini.

## Operasi penghapusan akun

Inbox `cermatifycompany@gmail.com` harus dipantau oleh operator. Catat permintaan dan respons awal, verifikasi kepemilikan tanpa meminta password/OTP. Cocokkan user ID yang benar sebelum tindakan.

Inventaris yang harus ditinjau: Firebase Auth, `users/{uid}`, `data_diri/{uid}`, `orders` milik pengguna/mentor, `kuesioners` milik pengguna serta identitas responden, `chatRooms` dan subkoleksi `messages`, `withdraws`, `playPurchaseIntents`, `playPurchases`, `financeLedger`, unggahan Cloudinary serta penyimpanan/cache terkait. Menghapus satu dokumen Firestore **tidak** otomatis menghapus subkoleksi atau file Cloudinary.

Pisahkan data yang dapat dihapus/di-anonimkan dari data yang wajib dipertahankan untuk transaksi/sengketa/hukum; beri penjelasan cakupan dan periode kepada pemohon. Cabut sesi/akses dan hapus akun Auth setelah operasi data terkait terkoordinasi. Untuk akun mentor dengan pesanan atau payout aktif, selesaikan/serahkan layanan dan hak dana tanpa mengabaikan permintaan privasi. Konfirmasi penyelesaian setelah memeriksa data utama serta penyedia, bukan saat email diterima. Uji satu permintaan end-to-end pada akun uji sebelum rilis.

Jangan menjalankan script purge generik pada proyek produksi. Belum ada otomasi penghapusan lintas Firebase/Cloudinary; prosedur operator ini harus benar-benar dijalankan dan diuji.

## Data safety dan App access — bahan pengisian

Belum merupakan jawaban final untuk dikirim. Periksa tujuan, wajib/opsional, enkripsi, retensi dan pembagian data per kategori/SDK di Play Console:

| Kandidat kategori | Sumber/penggunaan |
| --- | --- |
| Nama, email, user ID, telepon | Firebase Auth/profil/login/komunikasi |
| Informasi keuangan dan riwayat pembelian | Play Billing, orders, ledger, rekening/e-wallet, pencairan; bukti bayar pada web |
| Pesan | Chat pengguna/mentor/admin serta referensi pesan pada laporan moderasi |
| Informasi keamanan akun dan persetujuan | Pernyataan usia 18+, versi/waktu persetujuan, daftar blokir, alasan laporan dan catatan moderasi; periksa pemetaan kategori final pada form |
| Foto/gambar dan konten pengguna lain | Foto profil, unggahan dan materi layanan |
| Informasi pribadi lain | Kampus, jurusan, semester, peran/kompetensi mentor dan demografi responden |
| Integritas/perangkat/diagnostik SDK | Tinjau perilaku SDK Firebase, Play Billing, sistem unggahan dan konfigurasi yang benar-benar aktif; jangan menyimpulkan dari izin manifest saja |

Google Play memproses informasi pembayaran menurut layanannya; jangan mengklaim Cermatify menyimpan nomor kartu apabila tidak demikian. Penggunaan penyedia layanan tidak otomatis berarti semua data harus ditandai “shared”; terapkan definisi/pengecualian form terhadap pemrosesan nyata. App Check Android/Play Integrity belum dikonfigurasi atau ditegakkan oleh perubahan ini. Tidak menemukan SDK iklan/analytics khusus dalam dependencies, tetapi deklarasi tetap harus mencerminkan aplikasi final.

Sediakan akun reviewer customer dan mentor yang sudah terverifikasi, data uji aman serta petunjuk mengakses tiap fitur. Simpan kredensial pada App access Play Console, bukan dokumen repository. Hindari akses admin luas dan data pengguna nyata. Pada 1 November pemilik memilih target audience 18 tahun ke atas; content rating tetap diisi sesuai konten dan fungsi nyata, bukan otomatis disamakan dengan target umur.

## Draft listing Bahasa Indonesia

Nama aplikasi: **Cermatify**

Deskripsi singkat: **Pendampingan karya ilmiah, persiapan kompetisi, dan kuesioner penelitian.**

Deskripsi lengkap:

> Kembangkan kebutuhan akademik Anda bersama Cermatify. Temukan pendampingan untuk memahami proses, menyusun langkah berikutnya, dan memperbaiki karya Anda sendiri.
>
> Cermat Paper membantu diskusi topik, metode dan pengembangan karya ilmiah. Cermat Competition mendampingi persiapan ide, karya dan presentasi sesuai bidang kompetisi. Cermat Kuesioner membantu pengajuan kebutuhan responden penelitian melalui peninjauan tim.
>
> Pilih layanan sesuai kebutuhan, ajukan pendampingan, ikuti proses pemesanan dan berkomunikasi dengan mentor. Layanan berbayar menampilkan harga serta cakupan sebelum pembelian.
>
> Cermatify mendukung integritas akademik. Pendampingan memberikan arahan dan umpan balik; pengguna tetap bertanggung jawab atas karya dan keputusan akademiknya. Layanan tidak menjamin kelulusan, kemenangan atau hasil penelitian tertentu.
>
> Bantuan: cermatifycompany@gmail.com

Periksa kembali deskripsi terhadap fitur yang benar-benar aktif pada kandidat rilis. Lengkapi ikon toko, feature graphic dan screenshot Android asli; jangan memakai ulasan/nama fiktif sebagai bukti pengguna atau tangkapan fitur yang belum berjalan. Kumpulan screenshot authenticated dan aset listing belum selesai dibuat.

## Perintah verifikasi lokal

Hasil terakhir: analyzer bersih, **193 tes Flutter**, **11 unit test backend**, **14 tes rules**, dan **13 integration test backend** lulus. Audit npm dependency produksi Functions: 0 vulnerability terlapor saat diperiksa. Integration test memakai Firestore emulator dan respons purchase buatan; tidak memanggil Developer API untuk transaksi nyata.

### Artefak kandidat `1.0.0+2`

| Artefak | Ukuran byte | SHA-256 |
| --- | --- | --- |
| `build/app/outputs/bundle/release/app-release.aab` | 69.395.980 | `af8d651bccf0055329b6fd768da21f7dfd42aeaf6ea78fac8d2c2a4f237a5dae` |
| `build/app/outputs/flutter-apk/app-release.apk` | 70.636.038 | `4ca1855517f16aa3da8a79404b14ecec0fb1f8794e8ee19c98d6119ca70c2e64` |

Package `com.cermatify.app`, min SDK 24, target/compile SDK 36, Play Billing Library 9.1.0. Bundletool validate, APK signature v2, APK ZIP alignment 16 KB, dan ELF PT_LOAD alignment seluruh pustaka 64-bit lulus; 12 native libraries diperiksa pada masing-masing AAB/APK. Scanner dapat dijalankan ulang melalui `tool/check_android_native_alignment.py`. AAB `jarsigner` melaporkan jar verified dengan peringatan sertifikat self-signed/chain/timestamp dan urutan pembacaan ZIP; jangan mengubah ZIP AAB secara manual untuk menghilangkan warning. Penerimaan aktual tetap perlu diperiksa di Play Console.

Build Android masih menunjukkan deprecation plugin/Kotlin dan fallback cache incremental lintas drive; build web menunjukkan peringatan pemeriksaan wasm, tetapi build JS berhasil. Tidak menyebut build bebas warning.

APK kandidat dipasang dan diluncurkan pada emulator Android API 37/x86_64 dengan page size 16 KB. Landing, menu dan navigasi footer menuju permintaan hapus akun ditinjau; Firebase berhasil diinisialisasi dan tidak menemukan FATAL EXCEPTION/Unhandled Exception pada smoke test. Screenshot lokal `build/play-prep-startup.png`, `play-prep-footer.png`, `play-prep-delete-account.png`, `play-prep-menu.png`. Tidak memasukkan kredensial atau melakukan pembelian. Perangkat fisik ARM64 dan akun/fitur authenticated belum diuji. Build web menyertakan ketiga file `build/web/legal/*.html`; belum deploy.

```powershell
flutter analyze
flutter test --no-pub
npm --prefix functions test
firebase emulators:exec --only firestore --project demo-cermatify "npm --prefix firebase-tests test && npm --prefix functions run test:integration"
python tool/generate_legal_pages.py
flutter build appbundle --release --no-pub
flutter build apk --release --no-pub
```

Gunakan Java 21 untuk emulator Firebase dan toolchain Flutter/Android yang telah disiapkan. Integration test menolak berjalan tanpa emulator dan project `demo-cermatify`. Jangan mengarahkan clear database pengujian ke proyek hidup.

## Migrasi dan batas operasional

- Katalog Firebase lama saat diperiksa read-only masih Rp10.000–Rp20.000 per kategori. Tidak mengubah data produksi. Migrasi paket pada web, enforcement kuota layanan dan pengisian katalog Play yang baru masih harus dituntaskan sebelum menjual paket lintas platform.
- Approval legacy pesanan manual masih memakai logika lama (kredit harga penuh). Jangan memproses transaksi baru melalui alur tersebut sebagai pengganti checkout/ledger baru. Pesanan dan saldo historis perlu diaudit sebelum migrasi; tidak mengubah atau menghitung ulang hak pengguna lama otomatis.
- Withdraw baru memakai backend dan reservasi. Pending lama dapat dicadangkan dari saldo legacy saat disetujui. Pencairan lama berstatus approved tanpa metadata reservasi memerlukan rekonsiliasi manual; jangan otomatis mengembalikan saldo atau mengirim ulang transfer.
- Pemakaian paket, reward responden, pencegahan respons ganda dan operasi moderasi perlu diuji terhadap rules/backend produksi. Tidak menganggap semua backlog selesai karena tes billing lulus.
- Enforce App Check hanya setelah Android/Play Integrity dan token tester bekerja; autentikasi akun serta verifikasi purchase bukan pengganti seluruh kontrol penyalahgunaan. Intent baru dibatasi 20/menit dan 100/hari per akun melalui transaksi server; quote harga tidak membuat intent. Lengkapi monitoring, pembatasan penyalahgunaan quote dan alert sebelum membuka penjualan luas. Sertakan `playPurchaseLimits/{uid}` pada inventaris penghapusan.
- Cloudinary preset saat ini unsigned/public. Android Play tidak lagi mengunggah bukti pembayaran, tetapi audit unggahan profil dan alur web serta proses penghapusan pihak ketiga tetap diperlukan. Jangan simpan materi privat pada URL publik.

## Sumber resmi

- [Keamanan dan verifikasi pembelian](https://developer.android.com/google/play/billing/security)
- [Flutter in_app_purchase](https://pub.dev/packages/in_app_purchase)
- [RTDN](https://developer.android.com/google/play/billing/rtdn-reference)
- [Penghapusan akun](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en)
- [Privasi dan data pengguna](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en)
- [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)
- [Pengujian akun personal](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)
- [Functions: paket dan deployment](https://firebase.google.com/docs/functions/get-started)

Akun personal yang dibuat setelah 13 November 2023 umumnya memerlukan 12 tester opted-in terus-menerus selama 14 hari sebelum mengajukan akses produksi; periksa kewajiban aktual pada dashboard akun. Tanggal pembuatan akun belum dikonfirmasi. Tidak menjanjikan penerimaan Google Play hanya berdasarkan lolos build.
