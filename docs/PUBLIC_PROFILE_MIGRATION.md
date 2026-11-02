# Pemisahan profil publik dan privat — 2 November 2026

Status: implementasi/migrasi lokal; belum dijalankan pada Firebase produksi. AAB `1.0.0+3` yang divalidasi 2 November dibuat sebelum perubahan ini.

Kandidat `1.0.0+4` sudah dibangun dan divalidasi setelah perubahan ini; hash dan batas pengujiannya tersedia pada [dokumen rilis](PLAY_STORE_RELEASE.md). Analyzer, 202 tes Flutter, 25 tes rules, 17 integration test backend, 12 unit backend/CLI dan pengujian ulang 7 halaman/legal assertions lulus. Pengujian rules dan migrasi dilakukan pada emulator, bukan produksi.

## Data dan akses

`users/{uid}` tetap menyimpan profil lengkap, kontak, saldo, status dan persetujuan. Rules baru membatasi baca dokumen tersebut kepada pemilik dan admin aktif. Memfilter field pada UI saja tidak melindungi dokumen Firestore; pemisahan mengikuti [panduan resmi akses field](https://firebase.google.com/docs/firestore/security/rules-fields).

`publicProfiles/{uid}` memuat daftar field eksplisit: ID, nama tampilan, gambar, role dan status. Untuk mentor, tambahkan kampus, jurusan, layanan, LinkedIn, bio, rating dan jumlah sesi dari sumber yang ada. Data akademik customer dikosongkan. Email, telepon, rekening, saldo, metadata persetujuan dan field lain tidak disalin. Tidak membuat rating/sesi palsu jika sumber tidak ada.

Nama/avatar dapat dibaca akun aktif yang sudah mengetahui UID untuk kebutuhan chat. Direktori yang dapat dicari customer hanya mentor dan admin bantuan; daftar semua customer tidak terbuka. Admin aktif tetap memiliki akses operasional ke data akun penuh. Pengguna tanpa profil aktif tidak dapat membaca `publicProfiles`.

Registrasi membuat kedua dokumen dalam satu batch. Perubahan nama/gambar/profil/verifikasi/status menggunakan transaksi yang memperbarui sumber dan proyeksi bersama-sama. Rules menolak perubahan field terpublikasi jika proyeksi tidak ikut sinkron, serta menolak field tambahan atau pemalsuan rating/role pada proyeksi. Penulisan saldo dan persetujuan yang tidak mengubah proyeksi tetap dapat memakai alur semula. Backend/Admin SDK harus mengikuti kontrak ini karena melewati rules.

Pembaca yang dipindahkan: pencarian/detail mentor, nama partner chat, nama customer pada pesanan mentor, pencarian admin bantuan, dan pencarian admin pada alur kuesioner manual lama. Email di detail mentor dihapus. Profil milik sendiri, pemeriksaan login, saldo, dan layar admin tetap memakai `users`.

## Migrasi yang dapat ditinjau sebelum diterapkan

Script `functions/scripts/migrate-public-profiles.js` memakai kredensial ADC pada lingkungan operator tepercaya. Tidak membaca kredensial dari Flutter dan tidak mencetak data akun/token. Script memperbarui **hanya** proyeksi publik, bukan akun Auth, dokumen private `users`, saldo, atau pesanan. Dapat dijalankan ulang dan membaca ulang sumber di dalam transaksi untuk menghindari menimpa perubahan profil yang bersamaan.

Pemeriksaan tanpa penulisan (tetap memakai kuota baca Firestore):

```powershell
node functions/scripts/migrate-public-profiles.js --project=cermatify
```

Sebelum penerapan: ekspor/backup koleksi terkait melalui prosedur operator, periksa jumlah akun serta rencana akses admin, siapkan client/backend/rules yang cocok, dan jadwalkan migrasi agar client lama tidak tetap membaca data private milik orang lain. Tidak pernah menjalankan perintah penerapan otomatis hanya karena dry-run berhasil.

Perintah penerapan setelah lingkungan dan rencana migrasi dipastikan:

```powershell
node functions/scripts/migrate-public-profiles.js --project=cermatify --apply --confirm-project=cermatify
```

Output hanya project, mode, dan jumlah created/changed/unchanged/missing. Jalankan dry-run sesudahnya; untuk sumber stabil, created/changed harus nol. Buktikan nama/gambar tidak berubah dan email/telepon/saldo tidak muncul pada proyeksi. Tes idempotensi dan penghapusan field yang terlanjur masuk proyeksi menggunakan emulator, bukan data produksi.

## Urutan deployment dan penghapusan

1. Selesaikan backend pembayaran, pengujian paket, dan semua penghalang rilis yang tercatat. File rules saat ini juga memuat migrasi withdrawal dan persetujuan usia; jangan deploy hanya karena pemisahan profil telah diuji.
2. Backup, dry-run, tinjau, lalu isi proyeksi pada lingkungan tujuan. Koordinasikan cutover client dan rules; client baru membaca koleksi baru, sedangkan rules baru sengaja menolak query private lama.
3. Uji registrasi, edit profil, upload avatar, pencarian mentor, admin bantuan, chat, verifikasi/penonaktifan mentor, moderasi dan finance. Periksa indeks jika query menampilkan error. Jangan mengaktifkan pembayaran untuk menutupi kesalahan migrasi profil.
4. Tambahkan `publicProfiles/{uid}` ke inventaris penghapusan akun. Penghapusan private dan public melalui client admin harus satu batch; proses operator dengan Admin SDK juga wajib membersihkan keduanya, termasuk data pihak ketiga dan subkoleksi lain sesuai runbook.

Tidak ada Cloud Function baru yang diperlukan untuk menyinkronkan perubahan profil dari client ini. Tindakan Admin SDK/Console di luar aplikasi tetap harus memperbarui proyeksi atau menjalankan migrasi ulang, dan diaudit sebelum membuka layanan publik.
