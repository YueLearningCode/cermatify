import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingFaq extends StatelessWidget {
  const LandingFaq({super.key});

  static const _questions = [
    (
      'Layanan apa saja yang bisa saya pilih?',
      'Cermat Paper untuk pendampingan karya ilmiah, Cermat Competition untuk persiapan kompetisi, dan Cermat Kuesioner untuk pengajuan tautan serta kebutuhan responden penelitian.',
    ),
    (
      'Apakah saya harus punya akun?',
      'Kamu bisa membaca informasi layanan dan FAQ di halaman ini tanpa akun. Untuk memilih mentor, mengirim pengajuan, atau menggunakan layanan di aplikasi, masuk atau daftar terlebih dahulu.',
    ),
    (
      'Bagaimana cara memilih mentor?',
      'Setelah masuk, pilih pendampingan karya ilmiah atau kompetisi. Gunakan pilihan bidang layanan yang tersedia, lalu tinjau profil mentor agar sesuai dengan kebutuhanmu.',
    ),
    (
      'Bagaimana pembayaran diverifikasi?',
      'Ikuti petunjuk pembayaran pada pemesanan dan unggah buktinya. Admin akan meninjau bukti pembayaran dan memperbarui status pesanan di aplikasi.',
    ),
    (
      'Bagaimana cara mendaftar sebagai mentor?',
      'Pilih menu Jadi Mentor untuk membuka formulir pendaftaran mentor. Lengkapi profil, bidang layanan, dan tautan LinkedIn. Pengajuan akan ditinjau sebelum akun dapat digunakan sebagai mentor.',
    ),
    (
      'Apakah pendampingan mencakup pengerjaan tugas saya?',
      'Pendampingan membantu kamu memahami dan mengembangkan pekerjaanmu sendiri melalui arahan serta masukan. Layanan tidak mencakup pengerjaan tugas atas namamu atau pembuatan data, referensi, dan respons penelitian fiktif.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _questions.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                iconColor: AppColors.primaryDark,
                title: Text(
                  _questions[i].$1,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _questions[i].$2,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.65,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
