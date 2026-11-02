/// Shared availability-aware copy for the landing page and help centre.
class HelpContent {
  static const supportEmail = 'cermatifycompany@gmail.com';
  static const supportHours = 'Senin–Sabtu, 09.00–17.00 WIB';
  static const supportResponse =
      'Target respons awal maksimal 1 hari kerja. Waktu penyelesaian bergantung pada masalah yang diperiksa.';

  static const services = {
    'question': 'Layanan apa saja yang bisa saya pilih?',
    'answer':
        'Cermat Paper untuk pendampingan karya ilmiah, Cermat Competition untuk persiapan kompetisi, dan Cermat Kuesioner untuk pengajuan tautan serta kebutuhan responden penelitian.',
  };
  static const account = {
    'question': 'Apakah saya harus punya akun?',
    'answer':
        'Informasi layanan dan FAQ publik dapat dibaca tanpa akun. Untuk menggunakan layanan, daftar atau masuk terlebih dahulu. Rilis pertama ditujukan bagi pengguna berusia 18 tahun ke atas.',
  };
  static const mentor = {
    'question': 'Bagaimana cara memilih mentor?',
    'answer':
        'Setelah masuk, pilih pendampingan karya ilmiah atau kompetisi. Pilih bidang layanan dan tinjau profil mentor agar sesuai dengan kebutuhanmu. Periksa cakupan dan harga pada pemesanan sebelum menyetujui pembayaran.',
  };
  static const payment = {
    'question': 'Bagaimana pembayaran diverifikasi?',
    'answer':
        'Ikuti metode yang tersedia pada halaman pemesanan. Jika diminta mengunggah bukti pembayaran, statusnya menunggu pemeriksaan admin. Untuk pembelian melalui Google Play, status pesanan diperbarui setelah verifikasi sistem. Layanan yang belum tersedia untuk dibeli akan menampilkan pemberitahuan; jangan membayar ulang hanya karena status belum berubah.',
  };
  static const recruitment = {
    'question': 'Bagaimana cara mendaftar sebagai mentor?',
    'answer':
        'Pilih Jadi Mentor, lalu lengkapi profil, bidang layanan, dan tautan LinkedIn pada formulir. Pengajuan ditinjau sebelum akses mentor diberikan. Seleksi diarahkan berdasarkan kompetensi dan interview; semester 5 menjadi acuan pengalaman. Jika formulir belum sesuai dengan latar belakangmu, hubungi bantuan untuk arahan.',
  };
  static const integrity = {
    'question': 'Apakah pendampingan mencakup pengerjaan tugas saya?',
    'answer':
        'Pendampingan membantu kamu memahami dan mengembangkan pekerjaanmu sendiri melalui arahan serta masukan. Layanan tidak mencakup pengerjaan tugas atas namamu atau pembuatan data, referensi, dan respons penelitian fiktif. Hasil akademik dan kemenangan lomba tidak dijamin.',
  };
  static const meetings = {
    'question': 'Bagaimana jadwal dan pertemuan mentoring diatur?',
    'answer':
        'Pertemuan awal diarahkan daring melalui layanan pertemuan eksternal. Pemilihan slot otomatis belum tersedia; konfirmasikan waktu, zona waktu, durasi, dan tautan pertemuan melalui chat terkait pesanan. Tatap muka dan video call internal belum ditawarkan.',
  };
  static const support = {
    'question': 'Bagaimana cara menghubungi bantuan?',
    'answer':
        'Gunakan menu Hubungi admin pada profil atau email $supportEmail. Jam dukungan $supportHours. $supportResponse Sertakan ID pesanan bila terkait transaksi; jangan mengirim password atau kode OTP.',
  };
  static const questionnaire = {
    'question': 'Apakah Kuesioner sama dengan Sourcelink?',
    'answer':
        'Cermat Kuesioner mencakup pengajuan kebutuhan responden dan penelusuran kuesioner penelitian. Tombol membuat kuesioner membuka formulir pengajuan yang sebelumnya bernama Sourcelink. Ini bukan formulir penilaian sesi mentoring. Pengajuan baru menunggu pemeriksaan sebelum ditampilkan kepada responden.',
  };
  static const rewards = {
    'question': 'Apakah mengisi kuesioner langsung menambah saldo?',
    'answer':
        'Tidak. Pendaftaran responden baru dan klaim reward belum diaktifkan. Membuka atau menyalin tautan tidak membuktikan respons sah dan tidak menambah saldo. Jika program reward dibuka, syarat, nominal, dan proses validasinya harus ditampilkan sebelum kamu ikut.',
  };
  static const withdrawal = {
    'question': 'Kapan pendapatan dapat ditarik?',
    'answer':
        'Penarikan hanya untuk pendapatan terverifikasi yang sudah tersedia, dengan minimum Rp20.000. Saldo tertunda, ditahan, atau sedang dicairkan tidak dapat ditarik ulang. Permintaan pencairan belum berarti transfer berhasil. Jika layanan penarikan belum tersedia, hubungi bantuan; jangan menganggap saldo sudah masuk ke rekening.',
  };
  static const changes = {
    'question': 'Bagaimana jika perlu mengubah jadwal atau mengajukan keluhan?',
    'answer':
        'Hubungi mentor melalui chat terkait pesanan dan bantuan admin dengan ID pesanan, jadwal, serta penjelasan masalah. Perubahan jadwal dan pengembalian dana perlu ditinjau; mengirim permintaan belum berarti jadwal berubah atau dana dikembalikan. Tidak ada tombol reschedule atau refund otomatis saat ini.',
  };
  static const privacy = {
    'question': 'Bagaimana mengelola privasi dan menghapus akun?',
    'answer':
        'Baca Kebijakan Privasi dan panduan Hapus Akun dari halaman profil atau footer situs. Permintaan penghapusan diajukan melalui email bantuan dan diproses setelah verifikasi kepemilikan. Penghapusan tidak langsung terjadi saat email dikirim; data transaksi tertentu dapat memerlukan penyimpanan sesuai ketentuan yang dijelaskan.',
  };
  static const chatSafety = {
    'question': 'Bagaimana melaporkan atau memblokir pengguna di chat?',
    'answer':
        'Buka menu keamanan pada ruang chat untuk melaporkan pengguna atau pesan dan memblokir kontak. Laporan ditinjau admin. Pemblokiran membatasi pengiriman pesan, tetapi tidak otomatis membatalkan pesanan atau mengembalikan pembayaran.',
  };

  static const landing = [
    services,
    account,
    mentor,
    payment,
    recruitment,
    integrity,
    meetings,
    support,
  ];
  static const dashboard = [
    ...landing,
    questionnaire,
    rewards,
    withdrawal,
    changes,
    privacy,
    chatSafety,
  ];
}
