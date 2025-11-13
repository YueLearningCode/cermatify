import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// [CustomSnackbar] menyediakan cara kustom untuk menampilkan pesan Snackbar dengan opsi konfigurasi tambahan.
class CustomSnackbar {
  static void show({
    required String message,
    required String title,
    Widget? closeIcon,
    Duration duration = const Duration(seconds: 3),
    EdgeInsets? margin,
    Color backgroundColor = const Color(0xFFE6333C),
    Color textColor = Colors.white,
    double borderRadius = 8.0,
    bool isNav = false,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      borderRadius: borderRadius,
      margin: margin ?? EdgeInsets.only(left: 16, right: 16, top: 16),
      snackPosition: SnackPosition.TOP,
      mainButton: closeIcon != null
          ? TextButton(
              onPressed: () {
                Get.closeCurrentSnackbar();
              },
              child: closeIcon,
            )
          : null,
    );
  }
}
