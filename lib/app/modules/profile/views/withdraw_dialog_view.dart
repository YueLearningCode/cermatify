import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/custom_textfield.dart';
import '../controllers/withdraw_controller.dart';

class WithdrawDialogView extends StatelessWidget {
  final int currentSaldo;

  const WithdrawDialogView({super.key, required this.currentSaldo});

  String _formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final WithdrawController controller = Get.put(WithdrawController());

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          // Unfocus any focused fields when dialog is closed
          FocusScope.of(context).unfocus();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9, maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ajukan Withdraw',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () {
                            // Unfocus any focused fields before closing
                            FocusScope.of(context).unfocus();
                            Get.back();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Saldo Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saldo Tersedia',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrice(currentSaldo),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Nominal Field
                    Text(
                      'Nominal Withdraw',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: controller.nominalController,
                      hintText: 'Minimal ${_formatPrice(WithdrawController.minWithdraw)}',
                      icon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nominal tidak boleh kosong';
                        }
                        final nominal = int.tryParse(value.trim().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
                        if (nominal < WithdrawController.minWithdraw) {
                          return 'Minimal withdraw adalah ${_formatPrice(WithdrawController.minWithdraw)}';
                        }
                        if (nominal > currentSaldo) {
                          return 'Saldo tidak mencukupi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Nama Rekening/E-Wallet Field
                    Text(
                      'Nama Rekening / E-Wallet',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: controller.namaRekeningController,
                      hintText: 'Contoh: BCA, Mandiri, OVO, GoPay, dll',
                      icon: Icons.account_circle_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama rekening/e-wallet tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Nomor Rekening/E-Wallet Field
                    Text(
                      'Nomor Rekening / E-Wallet',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: controller.nomorRekeningController,
                      hintText: 'Masukkan nomor rekening atau nomor e-wallet',
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor rekening/e-wallet tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Withdraw akan diproses setelah admin menyetujui permintaan Anda',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                      // Unfocus any focused fields before closing
                                      FocusScope.of(context).unfocus();
                                      Get.back();
                                    },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Batal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : () => controller.submitWithdraw(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.surface,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                                      ),
                                    )
                                  : Text('Ajukan Withdraw', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
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
