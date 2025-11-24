import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class KuesionerDetailView extends StatelessWidget {
  final Kuesioner kuesioner;

  const KuesionerDetailView({super.key, required this.kuesioner});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String currentUid = auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Detail Kuesioner",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: Column(
        children: [
          // Header Information
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary.withOpacity(0.9), AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(Icons.assignment_rounded, color: AppColors.surface, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kuesioner Selesai",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.surface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tanggal: ${_formatDate(kuesioner.createdAt)}",
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.surface.withOpacity(0.9)),
                      ),
                      const SizedBox(height: 4),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection('kuesioners').doc(kuesioner.id).snapshots(),
                        builder: (context, snapshot) {
                          final List<dynamic> signedBy = (snapshot.data?.data()?['signedBy'] as List<dynamic>?) ?? [];
                          final int jumlahResponden = signedBy.length;
                          return Text(
                            "Jumlah Responden: $jumlahResponden",
                            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.surface.withOpacity(0.8)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions / Link area driven by Firestore doc (realtime)
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('kuesioners').doc(kuesioner.id).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
              final data = snapshot.data!.data() ?? {};
              final String userId = data['userId'] as String? ?? data['createdBy'] as String? ?? '';
              final String link = data['link'] as String? ?? '';
              final List<dynamic> signedBy = (data['signedBy'] as List<dynamic>?) ?? [];
              final bool isCreator = currentUid.isNotEmpty && currentUid == userId;
              final bool alreadySigned =
                  currentUid.isNotEmpty && signedBy.map((e) => e.toString()).contains(currentUid);

              if (isCreator || alreadySigned) {
                if (link.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.link_rounded, color: AppColors.primary),
                      title: Text('Buka Link Kuesioner', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: Text(link, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins()),
                      trailing: const Icon(Icons.copy_rounded, color: AppColors.primary),
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: link));
                        Get.snackbar(
                          'Disalin',
                          'Link kuesioner disalin ke clipboard',
                          backgroundColor: AppColors.primary,
                          colorText: AppColors.surface,
                        );
                      },
                    ),
                  ),
                );
              }

              // Not creator and not signed yet → show apply button
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (currentUid.isEmpty) return;

                      try {
                        // Check if user is already in signedBy to avoid duplicate rewards
                        final kuesionerDoc = await firestore.collection('kuesioners').doc(kuesioner.id).get();
                        final kuesionerData = kuesionerDoc.data();
                        final List<dynamic> signedBy = (kuesionerData?['signedBy'] as List<dynamic>?) ?? [];
                        final bool alreadySigned = signedBy.map((e) => e.toString()).contains(currentUid);

                        if (alreadySigned) {
                          Get.snackbar(
                            'Info',
                            'Anda sudah terdaftar sebagai responden',
                            backgroundColor: AppColors.primary,
                            colorText: AppColors.surface,
                          );
                          return;
                        }

                        // Add user to signedBy array
                        final docRef = firestore.collection('kuesioners').doc(kuesioner.id);
                        await docRef.set({
                          'signedBy': FieldValue.arrayUnion([currentUid]),
                          'updatedAt': FieldValue.serverTimestamp(),
                        }, SetOptions(merge: true));

                        // Update user's saldo - add Rp. 100 (only if not already signed)
                        final userDocRef = firestore.collection('users').doc(currentUid);
                        final userDoc = await userDocRef.get();

                        if (userDoc.exists) {
                          final userData = userDoc.data();
                          final currentSaldo = (userData?['saldo'] as int?) ?? 0;
                          final newSaldo = currentSaldo + 100;

                          await userDocRef.update({'saldo': newSaldo, 'updatedAt': FieldValue.serverTimestamp()});
                        }

                        Get.snackbar(
                          'Berhasil',
                          'Anda terdaftar sebagai responden. Saldo bertambah Rp. 100',
                          backgroundColor: AppColors.primary,
                          colorText: AppColors.surface,
                          duration: const Duration(seconds: 3),
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Gagal mendaftar sebagai responden: ${e.toString()}',
                          backgroundColor: AppColors.redColor,
                          colorText: AppColors.surface,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.person_add_rounded),
                    label: Text('Ajukan sebagai Responden', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            },
          ),
          // Questions List
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  ...kuesioner.answers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final qa = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Stack(
                        children: [
                          // Main Card
                          Card(
                            elevation: 6,
                            shadowColor: AppColors.primary.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.surface, AppColors.background.withOpacity(0.5)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Question Number
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [AppColors.primary, AppColors.primaryDark],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: AppColors.surface,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Question
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  qa.question,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                    color: AppColors.textPrimary,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Answer
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.lightbulb_outline_rounded,
                                                  color: AppColors.primary,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    qa.answer,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: AppColors.textSecondary,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                          // Decorative element
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
