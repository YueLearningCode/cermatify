# Backend pembayaran dengan Firebase Spark — 1 November 2026

Keputusan pemilik: tetap Spark; kaji backend eksternal dahulu, tanpa mengaktifkan biaya. Target Android tetap berbayar. Belum membuat akun provider, menautkan kartu, memindahkan database, menerbitkan endpoint, atau memasang kredensial.

Pemilik sempat menyebut memiliki VPS, tetapi saat diminta detail menjelaskan memakai Firebase Google dan belum memiliki Docker. Karena Firebase bukan VPS, keberadaan server terpisah **belum terkonfirmasi**. Jangan menjadikan jawaban awal tersebut sebagai bukti host, akses SSH, runtime Node, atau kapasitas tersedia. Tidak ada deployment VPS yang dilakukan.

## Hasil kajian

Kode sekarang memakai Node 22, Firebase Admin SDK, transaksi Firestore, callable Functions, dan Pub/Sub RTDN. Fungsi bisnis di `functions/finance.js` dan `functions/fulfill-purchase.js` dapat dipakai kembali pada server Node. Lapisan HTTP, verifikasi Firebase ID token, autentikasi notifikasi, penjadwalan, dan konfigurasi Flutter perlu disesuaikan. Mengganti URL saja tidak cukup.

| Pilihan | Kesesuaian dengan kode sekarang | Batas dan keputusan |
| --- | --- | --- |
| VPS / server Node yang sudah dimiliki, selalu aktif | Paling dekat: gunakan Firebase Admin SDK dan transaksi yang sudah diuji; Auth/Firestore dapat tetap di Firebase | Perlu memastikan kapasitas, HTTPS, secret, backup, monitoring, patch, dan penjadwal. Tidak menganggap pemilik sudah memiliki VPS atau biaya tambahan nol. Domain Hostinger saja bukan bukti tersedianya runtime backend. |
| Cloudflare Workers Free | Kandidat pembuktian konsep jika belum ada server. Verifikasi JWT dan panggilan API dapat dijalankan sebagai worker; perlu membuktikan jalur transaksi Firestore dan portabilitas dependensi | Batas resmi saat diperiksa: 100.000 request/hari dan 10 ms CPU per request, termasuk batas CPU cron Free. Melebihi batas dapat menghentikan eksekusi. Ini **belum terbukti cocok** untuk transaksi pembayaran Cermatify; jangan mengumumkan produksi gratis tanpa benchmark, pengujian retry/rekonsiliasi, dan audit kredensial. |
| Render Free | Node paling mudah untuk prototipe dan mempertahankan kode Admin SDK | Layanan tidur setelah 15 menit tanpa trafik, bangun sekitar satu menit. Dokumentasi Render menyatakan Free tidak untuk aplikasi produksi. Cocok uji awal; tidak direkomendasikan untuk menerima pembayaran publik. |
| Supabase Free / Edge Functions | Memerlukan adapter runtime, autentikasi Firebase, dan akses transaksi Firestore; menambah platform operasional | Ada paket Free, tetapi jaminan tidak dipause disebut untuk Pro. Tidak perlu migrasi Auth/database hanya untuk mendapatkan endpoint. Bukan pilihan pertama untuk basis kode ini; batas pemakaian dan kompatibilitas harus dibuktikan sebelum dipilih. |
| Firebase Functions | Perubahan paling sedikit | Deployment memerlukan Blaze; dikeluarkan dari opsi aktivasi sekarang mengikuti keputusan pemilik. Emulator lokal tetap dapat dipakai. |

Rekomendasi teknis: pertama periksa apakah pemilik sudah mempunyai server Node/VPS yang dapat beroperasi 24 jam. Jika tidak ada, Cloudflare Workers Free layak diuji sebagai pembuktian konsep yang terpisah, **bukan langsung menggantikan backend produksi**. Tidak ada opsi dalam kajian ini yang sudah terbukti siap menerima uang untuk Cermatify tanpa pekerjaan dan uji tambahan.

## Syarat adapter eksternal sebelum dapat dipilih untuk rilis

1. Verifikasi Firebase ID token, issuer/audience/signature/expiry; UID berasal dari token, bukan body. Tolak akun anonymous/nonaktif dan batasi request. Pisahkan pemeriksaan akun dari pemulihan transaksi yang sudah terbayar agar uang tidak hilang karena akun dibatasi.
2. Akses Google Android Publisher menggunakan service account berizin minimum dan penyimpanan secret server. Jangan masukkan private key ke Flutter, repository, chat, atau public environment variable. Bila provider mendukung identitas workload, kaji mekanisme tanpa private key statis.
3. Pertahankan transaksi atomik order/receipt/ledger, idempotensi token dan request pencairan, serta retry consumption setelah pencatatan. Uji dua callback dan dua pencairan bersamaan pada infrastruktur pilihan, bukan hanya mock HTTP.
4. Verifikasi identitas pengirim RTDN untuk endpoint push; jangan menerima payload publik sebagai bukti bayar. Kaji kebutuhan proyek Pub/Sub, billing/kuota, dan IAM tersendiri: memakai worker gratis tidak otomatis menghilangkan persyaratan layanan Google lain.
5. Sediakan rekonsiliasi Voided Purchases berkala dengan cursor, retry, alarm kegagalan, audit ledger, dan pemulihan notifikasi terlewat. Polling aplikasi saja tidak memadai saat pengguna tidak membuka aplikasi.
6. Uji beban dan batas CPU/request, expiry token, timeout, cold start, respons 429, konsumsi ganda, refund, shutdown dan kebocoran log. Dokumentasikan biaya/kuota aktual sebelum penjualan, tanpa mengasumsikan batas instance adalah batas tagihan.
7. Baru ubah transport Flutter, deploy backend/rules sebagai migrasi terkoordinasi, lalu uji melalui track Google Play. Produk pembayaran dan akses Developer API tetap harus disiapkan di Play Console.

## Sumber resmi yang diperiksa

- [Cloudflare Workers limits](https://developers.cloudflare.com/workers/platform/limits/)
- [Render Free — limits and production guidance](https://render.com/docs/free)
- [Supabase billing and Free plan](https://supabase.com/docs/guides/platform/billing-on-supabase)
- [Firebase Functions — deployment requires Blaze](https://firebase.google.com/docs/functions/get-started)

Kesimpulan kesesuaian kode dan rekomendasi di atas adalah penilaian teknis terhadap repository; bukan jaminan dari provider. Kuota dapat berubah, sehingga harus diperiksa kembali saat aktivasi.
