# Moderasi dan akses usia — kandidat 1.0.0+3

Disiapkan 1 November 2026. Belum diterapkan ke Firebase/Hosting/Google Play. Pemilik menetapkan usia 18+ untuk rilis pertama dan menyebut nama pengelola Windia/Cermatify.

## Perilaku aplikasi

- Pendaftaran memerlukan dua persetujuan terpisah: pernyataan berusia minimal 18 tahun dan persetujuan ketentuan. Nilai awal tidak dicentang. Profil menyimpan `adultConfirmed`, `termsVersion: 2026-11-01`, dan server timestamp `termsAcceptedAt`. Tidak mengumpulkan tanggal lahir atau KTP. Ini deklarasi pengguna, **bukan verifikasi usia dengan dokumen**.
- Rute privat menampilkan pemeriksaan profil dan persetujuan untuk akun lama. Halaman privasi/syarat/penghapusan tetap publik. Akun nonaktif atau mentor yang belum berstatus `verified` tidak dapat melewati tampilan tersebut. Akun lama tidak disetujui secara massal.
- Chat menyediakan **Laporkan pengguna**, **Laporkan pesan**, **Blokir pengguna**, dan **Buka blokir**. Blokir menghentikan pesan baru dalam kedua arah dan di seluruh room antarkedua UID. Rules menolak pengiriman langsung melalui SDK/API; menyembunyikan tombol saja bukan pengamanan.
- Riwayat chat tetap dapat dibuka untuk pelaporan. Pesan asli tidak dapat diedit atau dihapus oleh peserta; laporan menyimpan referensi bukti, bukan kutipan buatan client. Pesan terkait dapat ditinjau admin. Tidak menjanjikan penghapusan konten otomatis ketika laporan dikirim.
- Admin mengakses **Laporan pengguna** melalui akses cepat beranda, atau `/admin/reports`. Daftar dimuat bertahap. Tindakan memerlukan catatan; admin dapat menandai ditinjau, ditindaklanjuti, atau tidak ditemukan pelanggaran. Pilihan menonaktifkan akun juga menyelaraskan `status` dan `accountStatus`.
- Nonaktif berarti akun tidak boleh membuat pesan/pembelian/pencairan baru sesuai pemeriksaan yang diperbarui. Pemulihan transaksi yang sudah dibayar tetap tersedia pada backend; jangan menghilangkan hak transaksi pengguna dengan memblokir verifikasi receipt.
- Blokir dan penonaktifan **tidak** mengeksekusi refund atau menghapus kewajiban layanan. Admin harus menangani pesanan, komplain, dan payout secara terpisah.

## Operasi sebelum produksi

1. Tunjuk operator yang memeriksa antrean laporan secara rutin dalam jam bantuan. Isi catatan berdasarkan bukti, pertimbangkan konteks, batasi akun bila tepat, dan sediakan peninjauan keberatan melalui email bantuan. Tidak menganggap antrean UI sebagai moderasi otomatis.
2. Periksa akun admin yang nyata: `role: admin`, `status: active`, dan tidak `accountStatus: disabled`. Jangan memperbaiki akun/menambah admin tanpa memeriksa hak pemilik terlebih dahulu.
3. Tambahkan `userBlocks/{uid}/blocked/*`, blokir pengguna lain yang mengarah ke UID tersebut, serta `moderationReports` pelapor/target ke inventaris penghapusan. Tinjau kebutuhan menyimpan bukti sengketa secara terbatas; jangan menghapus bukti aktif tanpa prosedur.
4. Periksa nama pengembang pada listing terhadap nama Windia dan nama aplikasi Cermatify. Target audience untuk rilis ini **18 and over**. Isi content rating berdasarkan konten/fungsi yang benar-benar ada; target audience 18+ **bukan** alasan otomatis menjawab rating konten dewasa. Periksa [panduan target audience Google](https://support.google.com/googleplay/android-developer/answer/9867159?hl=en).
5. Migrasi rules dan client secara terkoordinasi. Rules baru memerlukan persetujuan profil yang tidak diterima rules lama; client baru tidak boleh dipublikasikan lebih dahulu. Seluruh file rules juga memuat migrasi withdrawal/backend sebelumnya; jangan deploy file ini sendirian sebelum infrastruktur keuangan siap.

## Uji penerimaan dengan akun uji

- Daftar tanpa konfirmasi usia, tanpa persetujuan ketentuan, lalu dengan keduanya. Baca legal sebelum menyetujui. Verifikasi waktu persetujuan berasal dari server.
- Login akun lama: tidak bisa masuk ruang pengguna sebelum konfirmasi; dapat keluar atau membaca legal. Putus koneksi saat menyimpan: tampilkan kesalahan dan izinkan retry, jangan anggap berhasil.
- Customer mengirim pesan ke mentor, lalu salah satu memblokir. Coba kirim dari kedua akun dan melalui room lain. Riwayat tetap bisa dibuka, termasuk oleh mentor/admin peserta yang sebelumnya memanggil pembuatan room saat navigasi.
- Laporkan satu pesan dan seorang pengguna. Laporan tidak terlihat oleh pengguna yang dilaporkan. Uji kirim ulang setelah timeout memakai ID laporan yang sama, dan uji rincian panjang di layar 320 px.
- Login admin: tinjau teks asli, simpan catatan, nonaktifkan akun uji. Akun nonaktif tidak dapat mengirim pesan baru, membeli, atau mengajukan pencairan; admin nonaktif tidak boleh memproses dana.
- Periksa pesanan aktif secara terpisah setelah blokir. Selesaikan kewajiban melalui prosedur operator tanpa mengubah hak dana hanya karena akun dibatasi.

## Batas yang tetap harus diselesaikan

Tes widget dan emulator tidak membuktikan alur pada Firebase produksi atau perangkat Play. Pemisahan profil publik/privat sudah diimplementasikan dan diuji secara lokal pada 2 November, tetapi migrasi/deployment belum dijalankan; lihat [rencana migrasi profil](PUBLIC_PROFILE_MIGRATION.md). Pelaporan pada konten publik di luar chat, seperti profil mentor dan kuesioner, juga perlu ditinjau sesuai cakupan konten yang akhirnya dipublikasikan.

Sumber kebijakan: [User Generated Content Google Play](https://support.google.com/googleplay/android-developer/answer/9876937?hl=en).
