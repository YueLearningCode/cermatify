import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// [AppStyles] adalah kelas yang menyediakan berbagai gaya teks yang dapat digunakan di seluruh aplikasi.
/// Gaya teks ini disesuaikan untuk berbagai ukuran font, bobot font, dan warna berdasarkan preferensi aplikasi.
class AppStyles {
  // Gaya teks dengan ukuran besar dan berat font medium (w600).
  static TextStyle headline1({Color? color}) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.black414, // Menggunakan warna default jika tidak diberikan warna.
    fontFamily: GoogleFonts.poppins().fontFamily, // Menggunakan font Poppins.
  );

  // Gaya teks dengan ukuran sedang dan berat font lebih tebal (w800).
  static TextStyle headline2({Color? color}) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: color ?? AppColors.black414,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  // Gaya teks untuk heading dengan ukuran 20 dan berat font tebal (w700).
  static TextStyle headline3({Color? color}) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.black414,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  // Gaya teks untuk heading dengan ukuran 16 dan berat font tebal (w700).
  static TextStyle headline4({Color? color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.black414,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  // Gaya teks untuk judul besar dengan ukuran font 40.
  static TextStyle title1({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 40, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk judul dengan ukuran font 34.
  static TextStyle title2({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 34, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk judul dengan ukuran font 30.
  static TextStyle title3({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 30, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk judul dengan ukuran font 28.
  static TextStyle title4({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 28, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk subtitle dengan ukuran font 24.
  static TextStyle subtitle1({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 24, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk subtitle dengan ukuran font 20.
  static TextStyle subtitle2({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 20, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk subtitle dengan ukuran font 18.
  static TextStyle subtitle3({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 18, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk subtitle dengan ukuran font 16.
  static TextStyle subtitle4({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 16, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk subtitle dengan ukuran font 15.
  static TextStyle subtitle5({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 15, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk tubuh utama dengan ukuran font 14.
  static TextStyle body1({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 14, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk tubuh dengan ukuran font 13.
  static TextStyle body2({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 13, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk tubuh dengan ukuran font 11.
  static TextStyle body3({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 11, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks kecil dengan ukuran font 9.
  static TextStyle small({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 9, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks sangat kecil dengan ukuran font 8.
  static TextStyle verySmall({Color? color, FontWeight? fontWeight}) =>
      TextStyle(fontSize: 8, color: color, fontWeight: fontWeight, fontFamily: GoogleFonts.poppins().fontFamily);

  // Gaya teks untuk tautan dengan ukuran font 18.
  static TextStyle link({Color? color, FontWeight? fontWeight}) => TextStyle(
    fontSize: 18,
    color: color ?? Colors.blue, // Menggunakan biru sebagai default jika tidak ada warna.
  );

  // Bobot font yang digunakan dalam aplikasi
  static FontWeight superBold = FontWeight.w900;
  static FontWeight bold = FontWeight.bold;
  static FontWeight semiBold = FontWeight.w600;
  static FontWeight mediumBold = FontWeight.w500;
  static FontWeight normalBold = FontWeight.normal;
  static FontWeight regularBold = FontWeight.w400;
}
