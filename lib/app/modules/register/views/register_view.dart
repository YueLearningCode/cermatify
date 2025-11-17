import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_styles.dart';
import 'package:cermatify/app/data/widgets/custom_textfield.dart';
import 'package:cermatify/app/data/widgets/custom_button_simple.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Hero(tag: 'logo', child: Image.asset('assets/images/logo.png', height: 150)),
                    ),
                    const SizedBox(height: 40),
                    Obx(
                      () => Text(
                        controller.userRole.value == 'mentor' ? "Daftar Sebagai Mentor" : "Buat Akun Baru",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black414,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => Text(
                        controller.userRole.value == 'mentor'
                            ? "Bergabunglah sebagai mentor dan bagikan pengetahuan Anda"
                            : "Bergabunglah dengan kami dan mulai perjalanan belajar Anda",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.greyTextSecondaryColor, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: controller.namaController,
                      hintText: "Nama Lengkap",
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        if (value.length < 3) {
                          return 'Nama minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
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
                    CustomTextField(
                      controller: controller.confirmPasswordController,
                      hintText: "Konfirmasi Kata Sandi",
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi kata sandi tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Konfirmasi kata sandi minimal 6 karakter';
                        }
                        // Access password value directly - it's an observable getter
                        if (value != controller.passwordController.text) {
                          return 'Kata sandi tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: controller.noTelpController,
                      hintText: "Nomor Telepon",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Nomor telepon harus berupa angka';
                          }
                          if (value.length < 10) {
                            return 'Nomor telepon minimal 10 digit';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: controller.selectedKampus.value.isNotEmpty ? AppColors.secondaryColor : Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: controller.selectedKampus.value.isEmpty ? null : controller.selectedKampus.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            prefixIcon: IconTheme(
                              data: IconThemeData(
                                color: controller.selectedKampus.value.isNotEmpty
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                              ),
                              child: const Icon(Icons.school_outlined),
                            ),
                            hintText: "Kampus",
                            hintStyle: AppStyles.body1(),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: AppStyles.body1(color: AppColors.black414),
                          items: controller.listKampus.map((Map<String, String> kampus) {
                            return DropdownMenuItem<String>(
                              value: kampus['id'],
                              child: Text(
                                kampus['name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: AppStyles.body1(color: AppColors.black414),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            controller.selectedKampus.value = newValue ?? '';
                          },
                          validator: (value) {
                            return null; // Optional field
                          },
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: controller.selectedKampus.value.isNotEmpty ? AppColors.primaryColor : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: controller.selectedJurusan.value.isNotEmpty ? AppColors.secondaryColor : Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: controller.selectedJurusan.value.isEmpty ? null : controller.selectedJurusan.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            prefixIcon: IconTheme(
                              data: IconThemeData(
                                color: controller.selectedJurusan.value.isNotEmpty
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                              ),
                              child: const Icon(Icons.menu_book_outlined),
                            ),
                            hintText: "Jurusan",
                            hintStyle: AppStyles.body1(),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: AppStyles.body1(color: AppColors.black414),
                          items: controller.filteredJurusan.map((Map<String, String> jurusan) {
                            return DropdownMenuItem<String>(
                              value: jurusan['id'],
                              child: Text(
                                jurusan['name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: AppStyles.body1(color: AppColors.black414),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            controller.selectedJurusan.value = newValue ?? '';
                          },
                          validator: (value) {
                            return null; // Optional field
                          },
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: controller.selectedJurusan.value.isNotEmpty ? AppColors.primaryColor : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: controller.selectedSemester.value.isNotEmpty
                                ? AppColors.secondaryColor
                                : Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: controller.selectedSemester.value.isEmpty ? null : controller.selectedSemester.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            prefixIcon: IconTheme(
                              data: IconThemeData(
                                color: controller.selectedSemester.value.isNotEmpty
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                              ),
                              child: const Icon(Icons.calendar_today_outlined),
                            ),
                            hintText: "Semester",
                            hintStyle: AppStyles.body1(),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: AppStyles.body1(color: AppColors.black414),
                          items: controller.listSemester.map((String semester) {
                            return DropdownMenuItem<String>(
                              value: semester,
                              child: Text(semester, style: AppStyles.body1(color: AppColors.black414)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            controller.selectedSemester.value = newValue ?? '';
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Semester harus dipilih';
                            }
                            return null;
                          },
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: controller.selectedSemester.value.isNotEmpty ? AppColors.primaryColor : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => controller.userRole.value == 'mentor'
                          ? Column(
                              children: [
                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(
                                      color: controller.selectedMentorRole.value.isNotEmpty
                                          ? AppColors.secondaryColor
                                          : Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: controller.selectedMentorRole.value.isEmpty
                                        ? null
                                        : controller.selectedMentorRole.value,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                      prefixIcon: IconTheme(
                                        data: IconThemeData(
                                          color: controller.selectedMentorRole.value.isNotEmpty
                                              ? AppColors.primaryColor
                                              : Colors.grey,
                                        ),
                                        child: const Icon(Icons.work_outline),
                                      ),
                                      hintText: "Role Mentor",
                                      hintStyle: AppStyles.body1(),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style: AppStyles.body1(color: AppColors.black414),
                                    items: controller.listMentorRole.map((String role) {
                                      return DropdownMenuItem<String>(
                                        value: role,
                                        child: Text(
                                          role == 'complink' ? 'CompLink' : 'PaperLink',
                                          style: AppStyles.body1(color: AppColors.black414),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      controller.selectedMentorRole.value = newValue ?? '';
                                    },
                                    validator: (value) {
                                      if (controller.userRole.value == 'mentor' && (value == null || value.isEmpty)) {
                                        return 'Role mentor harus dipilih';
                                      }
                                      return null;
                                    },
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: controller.selectedMentorRole.value.isNotEmpty
                                          ? AppColors.primaryColor
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Layanan Section
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: controller.selectedLayanan.isNotEmpty
                                          ? AppColors.secondaryColor
                                          : Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.list_alt_rounded,
                                            color: controller.selectedLayanan.isNotEmpty
                                                ? AppColors.primaryColor
                                                : Colors.grey,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Layanan yang Disediakan",
                                            style: AppStyles.body1(
                                              color: AppColors.black414,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (controller.selectedLayanan.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            'Pilih minimal satu layanan',
                                            style: AppStyles.body3(color: AppColors.redColor),
                                          ),
                                        ),
                                      const SizedBox(height: 12),
                                      ...controller.availableLayanan.map((Map<String, String> layanan) {
                                        final layananId = layanan['id'] ?? '';
                                        return Obx(
                                          () => CheckboxListTile(
                                            value: controller.selectedLayanan.contains(layananId),
                                            onChanged: (value) => controller.toggleLayanan(layananId),
                                            title: Text(
                                              layanan['name'] ?? '',
                                              style: AppStyles.body2(
                                                color: AppColors.black414,
                                                fontWeight: controller.selectedLayanan.contains(layananId)
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            activeColor: AppColors.primaryColor,
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => Row(
                        children: [
                          Checkbox(
                            value: controller.agreeToTerms.value,
                            onChanged: (value) => controller.toggleAgreeToTerms(),
                            activeColor: AppColors.primaryColor,
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(color: AppColors.greyTextSecondaryColor, fontSize: 14),
                                children: const [
                                  TextSpan(text: "Saya setuju dengan "),
                                  TextSpan(
                                    text: "Syarat dan Ketentuan",
                                    style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => CustomButtonSimple(
                        text: controller.isLoading.value
                            ? "Memproses..."
                            : (controller.userRole.value == 'mentor' ? "Daftar Mentor" : "Daftar"),
                        onPressed: (controller.isLoading.value || !controller.isFormValid.value)
                            ? null
                            : () => controller.register(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.offAllNamed(Routes.LOGIN);
                        },
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(color: AppColors.greyTextSecondaryColor),
                            children: const [
                              TextSpan(text: "Sudah punya akun? "),
                              TextSpan(
                                text: "Masuk",
                                style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
