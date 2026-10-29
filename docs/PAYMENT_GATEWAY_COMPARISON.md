# Pembayaran otomatis dan perbandingan gateway Cermatify

Tanggal kajian: 28 Oktober 2026. Pemilik meminta integrasi gateway serta alat untuk memantau uang masuk/keluar. Setelah klarifikasi, pemilik memilih **bandingkan dahulu** dan menyatakan **belum punya akun merchant/sandbox**. Provider belum dipilih; belum membuat integrasi, akun merchant, transaksi, perubahan billing atau deployment backend.

**Pembaruan selanjutnya pada 28 Oktober 2026:** pemilik mengonfirmasi **akun GoPay Merchant sudah aktif**. Ini memperbarui konteks persiapan akun: akses API/webhook, akun Midtrans/sandbox dan kemungkinan memakai merchant ID yang sama belum dikonfirmasi. Prioritasnya memeriksa opsi akun GoPay yang sudah ada sebelum membuat akun merchant baru.

## Rekomendasi awal

Mulai dengan **Midtrans Snap sandbox** untuk penerimaan pembayaran. Ini rekomendasi berdasarkan kebutuhan checkout awal Cermatify dan nominal layanan, bukan keputusan provider yang sudah disetujui. Snap menyediakan halaman checkout hosted/redirect sehingga aplikasi tidak perlu menangani data kartu langsung. [Snap](https://docs.midtrans.com/docs/snap).

Pertimbangkan Xendit bila pengelolaan payout, pelaporan terperinci dan alur platform/sub-account menjadi kebutuhan utama. Xendit menyediakan laporan transaksi, saldo dan rekonsiliasi. Bandingkan keseluruhan penawaran akun sebelum memilih; fitur tersebut bukan bukti bahwa payout atau split komisi otomatis sudah diaktifkan untuk Cermatify. [Laporan Xendit](https://docs.xendit.co/docs/reports-overview), [rekonsiliasi](https://docs.xendit.co/docs/reconciliations).

## Perbandingan

| Aspek | Midtrans | Xendit |
| --- | --- | --- |
| Menerima pembayaran | Snap menyediakan hosted checkout/pop-up/redirect. | Payment Links/Payment Session menyediakan alur pembayaran dengan notifikasi status. |
| Verifikasi otomatis | Webhook yang diverifikasi backend; status transaksi dapat diperiksa melalui API. | Webhook pembayaran dan payout, dengan rekonsiliasi berdasarkan ID transaksi. |
| Dana keluar | Produk payout/disbursement tersedia; persetujuan/aktivasi dan biaya ditinjau terpisah. | Payout dan kemampuan platform tersedia; akses produk dan biaya ditinjau terpisah. |
| Pelaporan | Dashboard menampilkan transaksi serta biaya dan pajaknya. | Laporan transaksi/saldo/auto-withdrawal serta ekspor untuk rekonsiliasi. |
| Kesesuaian awal | Rekomendasi untuk checkout awal yang lebih terbatas cakupannya. | Kandidat bila kebutuhan operasi keuangan/platform lebih luas. |

Rujukan webhook: [Midtrans](https://docs.midtrans.com/docs/https-notification-webhooks), [Xendit Payment Session](https://docs.xendit.co/apidocs/webhook-notification-sent-defined-webhook-url-updates-payment-session), [Xendit Payout](https://docs.xendit.co/apidocs/payout-v3-webhook).

## Biaya yang perlu dibandingkan

Halaman [harga Midtrans](https://midtrans.com/pricing) saat ditinjau mencantumkan QRIS 0,7%, virtual account Rp4.000 dan payout bank Rp5.000 per transaksi, dengan ketentuan pajak dan tarif kategori merchant. Tarif yang berlaku untuk Cermatify harus dikonfirmasi saat aktivasi/penawaran.

Halaman [harga Xendit](https://www.xendit.co/id/biaya/) saat ditinjau memisahkan biaya metode dan biaya pemrosesan; pada QRIS tercantum 0,70% untuk transaksi di atas Rp100.000 serta biaya pemrosesan Rp4.000. Ketentuan pajak ditampilkan per rincian dan penagihan. Tarif paket Rp75.000, kategori merchant, payout dan penawaran akun perlu dikonfirmasi. Artikel bantuan lama menampilkan rincian berbeda sehingga tidak dipakai sebagai tarif final.

Jangan membandingkan hanya persentase QRIS. Hitung biaya metode, processing, pajak atas biaya, payout, refund serta ketentuan kategori merchant. Minimum withdraw Rp20.000 dan harga paket Rp75.000/Rp250.000 yang telah disetujui tetap menjadi acuan bisnis; tidak mengubahnya sepihak untuk menyesuaikan fee.

## Alur otomatis yang harus dibangun setelah provider dipilih

1. Backend memvalidasi pengguna dan mengambil harga layanan/paket dari data yang dipercaya, lalu membuat order serta checkout dengan identitas transaksi unik.
2. Pengguna membayar melalui halaman gateway.
3. Gateway mengirim webhook ke backend HTTPS. Backend memverifikasi keaslian notifikasi, nominal, mata uang, order dan status resmi provider.
4. Backend memperbarui order dan catatan keuangan secara atomik/idempoten; notifikasi ganda atau terlambat tidak menghasilkan pembayaran/kredit ganda.
5. Aplikasi membaca status pembayaran yang tersimpan. Menutup checkout atau kembali ke halaman sukses tidak cukup untuk menandai lunas.
6. Pembayaran diterima, settlement ke rekening platform, layanan selesai dan payout ke mentor masing-masing mempunyai status terpisah.

Verifikasi pembayaran otomatis tidak otomatis menyetujui isi kuesioner, kualitas pekerjaan atau sengketa layanan. Peninjauan operasional tetap mengikuti ketentuan layanan.

## Pencatatan keuangan dan kode yang perlu diselaraskan

- Pertahankan komisi terbaru 15%, perlakuan diskon dan biaya yang disetujui pada jawaban pemilik; jangan menganggap seluruh penerimaan pelanggan sebagai pendapatan platform.
- Pisahkan saldo tertunda, tersedia, ditahan dan dalam pencairan. Pembayaran diterima tidak langsung berarti saldo dapat ditarik.
- Catat jurnal/ledger transaksi yang tidak ditulis langsung oleh Flutter. Rekonsiliasikan catatan order, gateway dan rekening bank.
- Payout baru berstatus berhasil setelah konfirmasi resmi transfer; gagal mengembalikan reservasi tepat sekali, sedangkan status belum pasti harus diperiksa sebelum retry.
- Kode saat kajian: `OrderController.createOrder` masih mewajibkan unggah bukti; `AdminOrdersController.updateOrderStatus` menambah `users.saldo` sebesar harga penuh saat approval pertama. Ini belum sesuai komisi 15% dan model saldo terbaru, sehingga bukan sekadar menambahkan tombol checkout.
- Rules/controller penarikan masih memakai minimum Rp50.000 dan belum mereservasi saldo pada permintaan. Minimum Rp20.000 serta pencegahan penarikan ganda perlu diterapkan bersama ketika modul keuangan dikerjakan.
- Harga dan `paid`, komisi, ledger, refund serta saldo harus ditentukan backend yang dipercaya. Server Key/secret tidak masuk Flutter atau repository.

## Tools keuangan tambahan

Gunakan dashboard gateway untuk memantau transaksi, settlement dan payout. Catatan internal Cermatify tetap diperlukan untuk menghubungkan pembayaran dengan hak mentor/komisi serta status layanan.

Untuk pembukuan bisnis, kandidat terpisah adalah **Mekari Jurnal** (Cashlink/rekonsiliasi bank) atau **Accurate Online** (rekonsiliasi kas/bank dan Smartlink). Verifikasi bank yang didukung, paket langganan dan cara integrasinya sebelum membeli. Tidak menganggap ada sinkronisasi langsung Cermatify yang sudah tersedia. [Mekari Jurnal](https://www.jurnal.id/id/blog/rekonsiliasi-bank-cash-link/), [Accurate](https://help.accurate.id/product/accurate-online/fitur-aol/kas-bank/rekonsiliasi-bank/rekonsiliasi-bank-accurate-online/).

Untuk awal, dashboard gateway + ledger internal + ekspor laporan dapat diprioritaskan. Software akuntansi tambahan mengikuti kebutuhan volume/operasional; tidak harus berlangganan semuanya sekaligus.

## Prasyarat infrastruktur dan Google Play

Jika backend menggunakan Cloud Functions for Firebase, deployment memerlukan paket **Blaze**; Firebase Hosting Spark saja tidak menyediakan runtime backend untuk verifikasi gateway. Kajian ini belum memeriksa billing aktual atau mengubah paket. Kode dan pengujian sandbox dapat disiapkan dahulu; aktivasi infrastruktur berbayar memerlukan keputusan pemilik. [Firebase Functions](https://firebase.google.com/docs/functions/get-started).

Untuk Android yang didistribusikan melalui Google Play, petakan tiap layanan terhadap aturan Play Billing. Pengecualian layanan online 1:1 memiliki ketentuan; jangan mengarahkan pengguna keluar aplikasi sebagai cara menghindari kewajiban pembayaran Play. Checkout web dan alur distribusi Android perlu diputuskan sesuai produk dan kebijakan. [Google Play Payments](https://support.google.com/googleplay/android-developer/answer/10281818?hl=en-en).

## Langkah berikut setelah perbandingan ditinjau

- Tentukan provider dan buat akun sandbox. Pemilik memasukkan secret melalui konfigurasi backend/secret manager, bukan chat.
- Sepakati cakupan awal: penerimaan pembayaran otomatis dahulu; payout/refund dan pembukuan diperluas bertahap dengan ledger yang konsisten.
- Siapkan backend, pengujian signature/nominal, order/status, replay webhook, duplicate credit, kegagalan jaringan dan rekonsiliasi sebelum live.
- Uji sandbox tanpa uang nyata, lalu selesaikan verifikasi merchant/bank serta persyaratan Google Play sebelum mengaktifkan produksi.

## Persiapan pemilik — sandbox dahulu

Untuk jalur Midtrans yang direkomendasikan (provider masih menunggu pilihan pemilik):

Jika memakai GoPay Merchant aktif yang baru dikonfirmasi, cek terlebih dahulu opsi integrasi akun tersebut sebagaimana bagian GoPay Merchant di bawah. Instruksi pendaftaran baru berlaku setelah jalur akun/integrasi ditentukan.

1. Siapkan email bisnis serta nomor telepon aktif, lalu buat dan verifikasi akun Midtrans. Pendaftaran memberi akses sandbox gratis; aktivasi penerimaan uang nyata dapat diselesaikan kemudian. [Dashboard Basics](https://docs.midtrans.com/docs/dashboard-basics).
2. Pilih environment Sandbox. Temukan Merchant ID serta akses key pada Settings → Access Keys. Server Key bersifat rahasia dan dimasukkan melalui konfigurasi backend/secret manager saat integrasi; jangan dikirim melalui chat atau dimasukkan ke Flutter. Key sandbox dan production berbeda. [Account Overview](https://docs.midtrans.com/docs/midtrans-account).
3. Akses proyek Firebase sudah tersedia. Pengembangan/pengujian Functions lokal dapat dilakukan dahulu; deployment Functions ke Firebase membutuhkan Blaze dan Cloud Billing. Tidak mengubah billing pada langkah persiapan ini. [Firebase Functions](https://firebase.google.com/docs/functions/get-started).
4. Data paket/komisi/withdraw yang sudah disetujui tetap digunakan: harga Rp75.000/Rp250.000, komisi mentoring 15%, minimum withdraw Rp20.000. Implementasi katalog/ledger dan cakupan produk tetap harus sesuai sebelum dipromosikan aktif; tidak meminta jawaban bisnis ini dari awal.
5. URL bisnis `https://cermatify.com/` berhasil diperiksa melalui HTTPS dengan HTTP 200 dan halaman Flutter pada 28 Oktober 2026. Ini membuktikan endpoint website merespons, belum membuktikan konfigurasi Auth/App Check domain atau persetujuan merchant.

Saat akan menerima uang nyata, siapkan identitas pemilik/jenis merchant dan rekening pencairan sesuai ketentuan provider. Dokumen tambahan mengikuti pendaftaran perorangan atau badan usaha dan metode pembayaran yang diaktifkan. Unggah dokumen identitas/bank langsung ke provider. [Panduan aktivasi](https://docs.midtrans.com/docs/hal-yang-perlu-diperhatikan-untuk-menghindari-kendala-saat-proses-aktivasi-akun).

Website/app perlu menjelaskan layanan serta harga Rupiah sesuai kategori bisnis. Sebelum produksi, selesaikan pula kontak, privasi, syarat, pembatalan/refund dan penerimaan layanan berdasarkan backlog Cermatify. [Kriteria website Midtrans](https://docs.midtrans.com/docs/what-are-the-website-or-application-criterias-for-registering-a-midtrans-account).

Pemilik tidak perlu menyiapkan URL webhook secara manual sekarang; URL tersebut ditentukan dari backend yang benar-benar disiapkan/deploy, lalu diatur pada dashboard provider. Belum berlangganan tools akuntansi tambahan; dashboard gateway dan ledger internal menjadi cakupan awal yang disarankan.

## GoPay Merchant yang sudah aktif

GoPay Merchant menyediakan QRIS statis dan QRIS dinamis yang nominalnya dimasukkan melalui aplikasi merchant. Ini dapat dipakai untuk menerima pembayaran dan memantau transaksi di aplikasi GoPay Merchant. Memunculkan gambar QRIS saja belum menghubungkan status transaksi dengan order Cermatify. [Panduan GoPay Merchant](https://gopay.co.id/bantuan-merchant/qris-merchant/cara-menampilkan-qris).

Untuk pembaruan order Cermatify otomatis, diperlukan jalur integrasi resmi dengan identitas order, API/backend dan notifikasi transaksi yang dapat diverifikasi. Salah satu jalur terdokumentasi adalah QRIS GoPay melalui Midtrans: backend meminta QR untuk transaksi, menampilkan QR, lalu memproses notifikasi HTTP resmi. Akses Server Key disediakan melalui jalur integrasi/provider terkait. [Integrasi GoPay QRIS](https://docs.midtrans.com/docs/gopay-qris-pos-integration).

Panduan onboarding Midtrans membedakan merchant baru dengan merchant yang **sudah terhubung ke GoPay melalui Midtrans**. Karena pemilik baru mengonfirmasi akun GoPay Merchant aktif, belum diasumsikan masuk kategori yang sudah terhubung tersebut. Penggunaan merchant ID/rekening yang sama, akses produk/API dan tarif perlu dikonfirmasi oleh GoPay/Midtrans. [Onboarding](https://docs.midtrans.com/reference/onboarding-v2).

Pertanyaan yang dapat disampaikan pemilik melalui bantuan resmi:

> Saya memiliki akun GoPay Merchant aktif dan ingin mengintegrasikan pembayaran QRIS di website/aplikasi Cermatify. Apakah akun/merchant ID ini bisa memakai integrasi API resmi dengan webhook untuk pembaruan order otomatis? Apakah perlu onboarding Midtrans atau aktivasi produk lain, dan berapa tarif yang berlaku untuk layanan kami?

Status: GoPay Merchant aktif berdasarkan konfirmasi pemilik; akses API, sandbox dan penggunaan identitas merchant untuk integrasi belum diverifikasi. Jangan mengotomatisasi verifikasi order dari pembacaan notifikasi ponsel/screenshot. Belum menghubungi provider atau membuat akun baru pada langkah ini.
