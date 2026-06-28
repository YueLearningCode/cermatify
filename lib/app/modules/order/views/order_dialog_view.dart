import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import '../controllers/order_controller.dart';
import '../../chat/controllers/chat_controller.dart';

class OrderDialogView extends StatelessWidget {
  final String mentorId;
  final String mentorName;
  final String layananId;
  final String layananName;
  final int price;
  final String? layananType; // Layanan type: 'paperlink' or 'complink'

  const OrderDialogView({
    super.key,
    required this.mentorId,
    required this.mentorName,
    required this.layananId,
    required this.layananName,
    required this.price,
    this.layananType,
  });

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.put(OrderController());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Order',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Order Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Details',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Mentor', mentorName),
                    const SizedBox(height: 8),
                    _buildDetailRow('Layanan', layananName),
                    const SizedBox(height: 8),
                    _buildDetailRow('Price', AppFormats.hargaPendek(price)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // QR Code Section
              Text(
                'Payment QR Code',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // QR Code Image from Assets
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Image.asset('assets/images/qrqris.jpeg', width: 500, height: 300, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 16),
                    // Price display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              'Rp',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppFormats.hargaPendek(price),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Payment Proof Section
              Text(
                'Payment Proof',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.paymentProofImage.value != null) {
                  return Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(controller.paymentProofImage.value!, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.pickPaymentProofImage(ImageSource.gallery),
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text('Change', style: GoogleFonts.poppins()),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.removePaymentProofImage(),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: Text('Remove', style: GoogleFonts.poppins()),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.redColor,
                                side: const BorderSide(color: AppColors.redColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              'No payment proof uploaded',
                              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.pickPaymentProofImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: Text('Camera', style: GoogleFonts.poppins()),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.pickPaymentProofImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library, size: 18),
                              label: Text('Gallery', style: GoogleFonts.poppins()),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              }),
              const SizedBox(height: 24),
              // Action Buttons
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.isLoading.value ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value || controller.paymentProofImage.value == null
                            ? null
                            : () async {
                                final orderId = await controller.createOrder(
                                  mentorId: mentorId,
                                  layananId: layananId,
                                  price: price,
                                  layananType: layananType,
                                );
                                if (orderId.isNotEmpty) {
                                  // Create chat room with orderId
                                  try {
                                    final ChatController chatController = Get.isRegistered<ChatController>()
                                        ? Get.find<ChatController>()
                                        : Get.put(ChatController());
                                    await chatController.createOrGetChatRoom(mentorId: mentorId, orderId: orderId);
                                  } catch (e) {
                                    print('Error creating chat room: $e');
                                  }

                                  // Close dialog first
                                  Get.back(result: true);
                                  // Show success snackbar
                                  Get.snackbar(
                                    'Success',
                                    'Order created successfully. Waiting for approval.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColors.greenColor,
                                    colorText: AppColors.surface,
                                    borderRadius: 12,
                                    margin: const EdgeInsets.all(16),
                                    duration: const Duration(seconds: 2),
                                  );
                                  // Navigate to order history after a short delay
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  Get.offNamed(Routes.ORDER_HISTORY);
                                }
                              },
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
                            : Text('Create Order', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
