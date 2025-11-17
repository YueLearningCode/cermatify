import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_textfield.dart';
import 'package:cermatify/app/data/widgets/custom_button_simple.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Obx(
          () => controller.isCheckingSession.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Center(
                              child: Hero(tag: 'logo', child: Image.asset('assets/images/logo.jpeg', height: 150)),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              "Selamat Datang Kembali",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black414,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Masuk ke akun Anda untuk melanjutkan",
                              style: GoogleFonts.poppins(color: AppColors.greyTextSecondaryColor, fontSize: 16),
                            ),
                            const SizedBox(height: 30),
                            CustomTextField(
                              key: const ValueKey('email_field'),
                              controller: controller.emailController,
                              hintText: "Email",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Masukkan email yang valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              key: const ValueKey('password_field'),
                              controller: controller.passwordController,
                              hintText: "Kata Sandi",
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Kata sandi tidak boleh kosong';
                                }
                                if (value.length < 6) {
                                  return 'Kata sandi minimal 6 karakter';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Obx(
                              () => CustomButtonSimple(
                                text: controller.isLoading.value ? "Memproses..." : "Masuk",
                                onPressed: controller.isLoading.value ? null : () => controller.login(),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.REGISTER);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.poppins(color: AppColors.greyTextSecondaryColor),
                                    children: const [
                                      TextSpan(text: "Belum punya akun? "),
                                      TextSpan(
                                        text: "Daftar Sekarang",
                                        style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.REGISTER, arguments: 'mentor');
                              },
                              child: Center(
                                child: Text(
                                  "Daftar Mentor",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
