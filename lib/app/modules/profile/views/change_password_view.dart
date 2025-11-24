import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ChangePasswordView extends GetView<ProfileController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController currentController = TextEditingController();
    final TextEditingController newController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Ubah Kata Sandi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.border.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keamanan Akun',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Masukkan kata sandi saat ini dan kata sandi baru Anda. Kata sandi baru minimal 6 karakter.',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Kata Sandi Saat Ini',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: currentController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kata Sandi Baru',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: newController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        prefixIcon: const Icon(Icons.lock_rounded),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Wajib diisi';
                        if (v.length < 6) return 'Minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Konfirmasi Kata Sandi Baru',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        prefixIcon: const Icon(Icons.lock_rounded),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Wajib diisi';
                        if (v != newController.text.trim()) return 'Konfirmasi tidak cocok';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  final ok = await controller.changePassword(
                                    currentController.text.trim(),
                                    newController.text.trim(),
                                  );
                                  if (ok) {
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    Get.offNamed(Routes.PROFILE);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Simpan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
