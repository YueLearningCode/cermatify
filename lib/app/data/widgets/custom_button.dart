import 'package:flutter/material.dart';

/// [CustomButton] adalah widget kustom yang menyediakan tombol dengan berbagai penyesuaian gaya, termasuk warna, ukuran, dan aksi saat ditekan.
class CustomButton extends StatelessWidget {
  final VoidCallback onTap; // Fungsi yang dipanggil ketika tombol ditekan.
  final double height; // Tinggi tombol.
  final double?
      width; // Lebar tombol (opsional, jika tidak diberikan akan menggunakan lebar default).
  final Color color; // Warna latar belakang tombol.
  final Widget
      widget; // Widget kustom yang ditempatkan di dalam tombol (misalnya teks atau ikon).
  final bool?
      withBorder; // Menentukan apakah tombol memiliki border (opsional).
  final Color? borderColor; // Warna border tombol (opsional).

  const CustomButton({
    super.key,
    required this.onTap,
    required this.height,
    this.width,
    required this.color,
    required this.widget,
    this.withBorder,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Menetapkan aksi ketika tombol ditekan.
      child: Container(
        height: height, // Menetapkan tinggi tombol.
        width: width, // Menetapkan lebar tombol.
        decoration: BoxDecoration(
          color: color, // Menetapkan warna latar belakang tombol.
          borderRadius: BorderRadius.circular(
              20), // Menambahkan radius pada sudut tombol.
          border: withBorder == true
              ? Border.all(
                  color: borderColor ??
                      Colors
                          .black, // Menggunakan borderColor jika ada, jika tidak default ke hitam.
                  width: 1.0,
                )
              : null, // Tidak ada border jika withBorder bukan true.
        ),
        child: widget, // Menampilkan widget yang diberikan di dalam tombol.
      ),
    );
  }
}
