import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/profile/controllers/withdraw_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WithdrawDialogView extends StatelessWidget {
  const WithdrawDialogView({super.key, required this.currentSaldo});
  final int currentSaldo;

  String get formattedBalance =>
      'Rp ${currentSaldo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WithdrawController());
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 540,
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.14),
                blurRadius: 34,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 480 ? 18 : 24,
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ajukan withdraw',
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Dana akan diverifikasi oleh admin.',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tutup',
                        onPressed: () => _close(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  if (currentSaldo < WithdrawController.minWithdraw) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.yellowColor.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.yellowColor.withValues(alpha: .4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.orange2Color,
                            size: 19,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Saldo belum mencapai minimal withdraw Rp 50.000.',
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontSize: 10,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primaryColor.withValues(alpha: 0.86),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.surface,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saldo tersedia',
                              style: GoogleFonts.poppins(
                                color: AppColors.surface.withValues(
                                  alpha: 0.75,
                                ),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              formattedBalance,
                              style: GoogleFonts.poppins(
                                color: AppColors.surface,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _WithdrawField(
                    controller: controller.nominalController,
                    label: 'Nominal withdraw',
                    hint: 'Minimal Rp 50.000',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      final amount = int.tryParse(value?.trim() ?? '') ?? 0;
                      if (amount < WithdrawController.minWithdraw) {
                        return 'Minimal withdraw Rp 50.000';
                      }
                      if (amount > currentSaldo) return 'Saldo tidak mencukupi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _WithdrawField(
                    controller: controller.namaRekeningController,
                    label: 'Nama pemilik rekening',
                    hint: 'Sesuai data rekening',
                    icon: Icons.person_outline_rounded,
                    validator: (value) => value?.trim().isEmpty ?? true
                        ? 'Nama pemilik rekening wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _WithdrawField(
                    controller: controller.nomorRekeningController,
                    label: 'Nomor rekening',
                    hint: 'Masukkan nomor rekening',
                    icon: Icons.account_balance_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => value?.trim().isEmpty ?? true
                        ? 'Nomor rekening wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pastikan nama dan nomor rekening sudah benar sebelum mengirim permintaan.',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => FilledButton.icon(
                      onPressed:
                          controller.isLoading.value ||
                              currentSaldo < WithdrawController.minWithdraw
                          ? null
                          : controller.submitWithdraw,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: controller.isLoading.value
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.surface,
                              ),
                            )
                          : const Icon(Icons.send_outlined, size: 18),
                      label: Text(
                        controller.isLoading.value
                            ? 'Mengirim permintaan...'
                            : currentSaldo < WithdrawController.minWithdraw
                            ? 'Saldo belum mencukupi'
                            : 'Kirim permintaan withdraw',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _close(BuildContext context) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
    if (Get.isRegistered<WithdrawController>()) {
      Get.delete<WithdrawController>();
    }
  }
}

class _WithdrawField extends StatelessWidget {
  const _WithdrawField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.inputFormatters,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(fontSize: 11),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textLight,
          fontSize: 11,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
