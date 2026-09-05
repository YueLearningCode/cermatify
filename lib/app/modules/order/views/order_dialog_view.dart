import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/payment_checkout_widgets.dart';
import 'package:cermatify/app/modules/chat/controllers/chat_controller.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/order_controller.dart';

class OrderDialogView extends StatefulWidget {
  const OrderDialogView({
    super.key,
    required this.mentorId,
    required this.mentorName,
    required this.layananId,
    required this.layananName,
    required this.price,
    this.layananType,
  });

  final String mentorId;
  final String mentorName;
  final String layananId;
  final String layananName;
  final int price;
  final String? layananType;

  @override
  State<OrderDialogView> createState() => _OrderDialogViewState();
}

class _OrderDialogViewState extends State<OrderDialogView> {
  late final OrderController controller;

  @override
  void initState() {
    super.initState();
    controller = OrderController();
  }

  @override
  void dispose() {
    controller.removePaymentProofImage();
    super.dispose();
  }

  Future<void> _submit() async {
    final orderId = await controller.createOrder(
      mentorId: widget.mentorId,
      layananId: widget.layananId,
      price: widget.price,
      layananType: widget.layananType,
    );
    if (orderId.isEmpty) return;
    try {
      final chat = Get.isRegistered<ChatController>()
          ? Get.find<ChatController>()
          : Get.put(ChatController());
      await chat.createOrGetChatRoom(
        mentorId: widget.mentorId,
        orderId: orderId,
      );
    } catch (error) {
      AppLogger.info('Error creating chat room: $error');
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
    Get.snackbar(
      'Order berhasil dibuat',
      'Pembayaran Anda sedang menunggu verifikasi admin.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.greenColor,
      colorText: AppColors.surface,
      margin: const EdgeInsets.all(16),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    Get.offNamed(Routes.ORDER_HISTORY);
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: viewport.width < 600 ? 12 : 28,
        vertical: 20,
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: viewport.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.15),
              blurRadius: 34,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(viewport.width < 600 ? 18 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.checkoutButtonColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konfirmasi order',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Selesaikan pembayaran untuk memulai pendampingan.',
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
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 720;
                  final summary = PaymentQrCard(
                    amount: widget.price,
                    serviceName: widget.layananName,
                    partnerName: widget.mentorName,
                  );
                  final proof = Obx(
                    () => PaymentProofPanel(
                      bytes: controller.paymentProofImage.value?.bytes,
                      onGallery: () =>
                          controller.pickPaymentProofImage(ImageSource.gallery),
                      onCamera: kIsWeb
                          ? null
                          : () => controller.pickPaymentProofImage(
                              ImageSource.camera,
                            ),
                      onRemove: controller.removePaymentProofImage,
                    ),
                  );
                  if (!wide) {
                    return Column(
                      children: [summary, const SizedBox(height: 14), proof],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: summary),
                      const SizedBox(width: 14),
                      Expanded(child: proof),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              Obx(
                () => FilledButton.icon(
                  key: const Key('submit-order-button'),
                  onPressed:
                      controller.isLoading.value ||
                          controller.paymentProofImage.value == null
                      ? null
                      : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surface,
                          ),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: Text(
                    controller.isLoading.value
                        ? 'Mengirim order...'
                        : 'Kirim order untuk diverifikasi',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
