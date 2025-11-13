import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// [CustomShimmer] adalah ekstensi untuk widget yang memungkinkan menambahkan efek shimmer (animasi loading) pada widget.
extension CustomShimmer on Widget {
  /// Menambahkan efek shimmer pada widget jika [enabled] bernilai true.
  ///
  /// [enabled] menentukan apakah efek shimmer diaktifkan.
  /// [baseColor] adalah warna dasar dari efek shimmer. Secara default, menggunakan warna abu-abu terang.
  /// [highlightColor] adalah warna sorotan dari efek shimmer. Secara default, menggunakan warna abu-abu lebih terang.
  ///
  /// Jika [enabled] bernilai false, widget akan ditampilkan tanpa efek shimmer.
  Widget shimmer(bool enabled, {Color? baseColor, Color? highlightColor}) {
    if (!enabled) return this;

    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!, // Warna dasar shimmer
      highlightColor: highlightColor ?? Colors.grey[100]!, // Warna sorotan shimmer
      child: this, // Widget yang diberi efek shimmer
    );
  }
}
