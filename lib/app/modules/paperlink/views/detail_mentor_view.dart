import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/models/mentor_model.dart';
import 'package:cermatify/app/modules/chat/controllers/chat_controller.dart';
import 'package:cermatify/app/modules/chat/views/chat_room_view.dart';
import 'package:cermatify/app/modules/order/views/order_dialog_view.dart';
import 'package:cermatify/app/modules/order/controllers/order_history_controller.dart';

class DetailMentorView extends StatelessWidget {
  final Mentor mentor;
  final String? layananId; // Layanan ID from filter
  final int? layananPrice; // Layanan price from filter (null means use default 100000)
  final String? layananType; // Layanan type: 'paperlink' or 'complink'

  const DetailMentorView({super.key, required this.mentor, this.layananId, this.layananPrice, this.layananType});

  List<Widget> _buildChips(String csv) {
    final items = csv.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (items.isEmpty) return [const SizedBox()];
    return items
        .map(
          (e) => Container(
            margin: const EdgeInsets.only(right: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
            ),
            child: Text(
              e,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        )
        .toList();
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkedInRow(String linkedinUrl) {
    // Ensure URL has https:// prefix
    String url = linkedinUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFF0077B5).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.link, color: Color(0xFF0077B5), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LinkedIn',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          linkedinUrl,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF0077B5),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new, color: Color(0xFF0077B5), size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not launch $url', backgroundColor: AppColors.redColor, colorText: AppColors.surface);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(mentor.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(mentor.id).get(),
          builder: (context, snapshot) {
            final linkedin = snapshot.data?.data() != null
                ? (snapshot.data!.data() as Map<String, dynamic>)['linkedin']?.toString() ?? ''
                : '';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.border.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: mentor.image.isNotEmpty ? NetworkImage(mentor.image) : null,
                          child: mentor.image.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 28) : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mentor.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.star_rounded, color: AppColors.yellow2Color, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    mentor.rating.toStringAsFixed(1),
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(Icons.schedule_rounded, color: AppColors.textSecondary, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${mentor.totalSessions} sesi",
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.border.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Informasi",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _infoRow(Icons.school_rounded, "Universitas", mentor.kampus),
                        _infoRow(Icons.menu_book_rounded, "Jurusan", mentor.jurusan),
                        _infoRow(Icons.email_rounded, "Email", mentor.email),
                        if (linkedin.isNotEmpty) _linkedInRow(linkedin),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Services card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.border.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Layanan",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(children: _buildChips(mentor.layanan)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Get layanan type - use provided or fetch from layananId
                        String? finalLayananType = layananType;
                        if (finalLayananType == null || finalLayananType.isEmpty) {
                          final String? currentLayananId = layananId;
                          if (currentLayananId != null && currentLayananId.isNotEmpty) {
                            try {
                              final layananDoc = await FirebaseFirestore.instance
                                  .collection('layanan')
                                  .doc(currentLayananId)
                                  .get();
                              if (layananDoc.exists) {
                                final layananData = layananDoc.data();
                                finalLayananType = layananData?['type']?.toString();
                              }
                            } catch (e) {
                              print('Error fetching layanan type: $e');
                            }
                          }
                        }

                        // Check if user has order in progress for this mentor with this layanan type
                        final orderHistoryController = Get.put(OrderHistoryController());
                        final hasProgress = await orderHistoryController.hasProgressOrder(
                          mentor.id,
                          layananType: finalLayananType,
                        );

                        if (hasProgress) {
                          // User has order in progress, get orderId and proceed to chat
                          final orderId = await orderHistoryController.getProgressOrderId(
                            mentor.id,
                            layananType: finalLayananType,
                          );
                          final ChatController chatController = Get.isRegistered<ChatController>()
                              ? Get.find<ChatController>()
                              : Get.put(ChatController());
                          await chatController.createOrGetChatRoom(mentorId: mentor.id, orderId: orderId);
                          Get.to(() => ChatRoomView(mentorId: mentor.id, mentor: mentor, orderId: orderId));
                        } else {
                          // No approved order, show order dialog
                          final String finalLayananId = layananId ?? '';
                          final int finalPrice = layananPrice ?? 100000; // Default to 100000 if no filter
                          final String layananName = mentor.layanan.isNotEmpty
                              ? mentor.layanan.split(',').first.trim()
                              : 'Layanan';

                          // Show order dialog
                          // Navigation to order history is handled inside the dialog
                          await Get.dialog(
                            OrderDialogView(
                              mentorId: mentor.id,
                              mentorName: mentor.name,
                              layananId: finalLayananId,
                              layananName: layananName,
                              price: finalPrice,
                              layananType: finalLayananType,
                            ),
                            barrierDismissible: false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                        shadowColor: AppColors.primary.withOpacity(0.25),
                      ),
                      child: Text("Chat Mentor", style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
