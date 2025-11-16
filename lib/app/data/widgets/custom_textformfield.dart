// ignore_for_file: deprecated_member_use

import 'package:cermatify/app/data/widgets/custom_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_styles.dart';

/// [CustomTextFormField] adalah widget kustom yang membungkus `TextFormField` dengan penyesuaian tambahan seperti ikon, validasi, dan pengaturan tampilan khusus.
class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Icon prefixIcon;
  final String? Function(String?)? validator;
  final int? maxLength;
  final bool isPassword; // Menentukan apakah field ini adalah untuk kata sandi.
  final TextInputType keyType; // Menentukan jenis keyboard untuk input.
  final Function(String)? onChanged; // Callback untuk perubahan teks.

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
    this.maxLength,
    this.isPassword = false,
    required this.keyType,
    this.onChanged, // Tambahkan parameter onChanged
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true; // Mengatur visibilitas kata sandi.

  @override
  void initState() {
    super.initState();
    // Menambahkan listener ke controller untuk memantau perubahan teks.
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // Menghapus listener saat widget di-dispose untuk menghindari memory leak.
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  // Fungsi untuk mengubah visibilitas kata sandi.
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Fungsi yang dipanggil saat teks dalam controller berubah.
  void _onTextChanged() {
    // Memanggil setState untuk membangun ulang widget saat teks berubah.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.isPassword ? _obscureText : false, // Mengatur kata sandi disembunyikan jika diperlukan.
      style: AppStyles.body1(), // Menggunakan gaya teks dari AppStyles.
      keyboardType: widget.keyType, // Menggunakan tipe keyboard sesuai parameter.
      onChanged: widget.onChanged, // Terapkan onChanged ke TextFormField
      maxLength: widget.maxLength, // Menentukan panjang maksimum input.
      inputFormatters: [
        if (widget.keyType == TextInputType.number)
          ThousandsSeparatorInputFormatter(), // Apply the formatter for number input
      ],
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        prefixIcon: IconTheme(
          data: IconThemeData(
            color: MaterialStateColor.resolveWith((Set<MaterialState> states) {
              // Mengubah warna ikon saat fokus atau saat teks tidak kosong.
              if (states.contains(MaterialState.focused) || widget.controller.text.isNotEmpty) {
                return AppColors.primaryColor; // Warna saat fokus atau field terisi.
              }
              return Colors.grey; // Warna default.
            }),
          ),
          child: widget.prefixIcon,
        ),
        hintText: widget.hintText, // Teks petunjuk untuk input.
        hintStyle: AppStyles.body1(), // Gaya teks untuk hint.

        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey, // Warna border saat tidak fokus.
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(30.0), // Menambahkan radius pada border.
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.secondaryColor, // Warna border saat fokus.
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(30.0),
        ),
        // Menambahkan ikon untuk visibilitas kata sandi jika diperlukan.
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: AppColors.secondaryColor),
                onPressed: _togglePasswordVisibility, // Fungsi untuk toggle visibilitas.
              )
            : null,
      ),

      controller: widget.controller, // Controller untuk mengontrol input.
      validator: widget.validator ?? (input) => input == '' ? "Tidak boleh kosong" : null, // Validasi input.
    );
  }
}
