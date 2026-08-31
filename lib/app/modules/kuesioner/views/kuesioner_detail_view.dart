import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

int kuesionerDetailColumnCount(double width) => width >= 920 ? 2 : 1;

class KuesionerDetailView extends StatelessWidget {
  const KuesionerDetailView({super.key, required this.kuesioner});
  final Kuesioner kuesioner;

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final padding = viewport.maxWidth < 600 ? 16.0 : 28.0;
            final gutter = viewport.maxWidth > 1156
                ? (viewport.maxWidth - 1100) / 2
                : padding;
            final columns = kuesionerDetailColumnCount(viewport.maxWidth);
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, padding, gutter, 0),
                  sliver: SliverToBoxAdapter(
                    child: KuesionerDetailHeader(
                      item: kuesioner,
                      onBack: Get.back,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
                  sliver: SliverToBoxAdapter(
                    child:
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: firestore
                              .collection('kuesioners')
                              .doc(kuesioner.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.data() ?? const {};
                            return KuesionerAccessCard(
                              link:
                                  data['link']?.toString() ??
                                  kuesioner.link ??
                                  '',
                              isCreator:
                                  currentUid.isNotEmpty &&
                                  currentUid ==
                                      (data['userId']?.toString() ??
                                          data['createdBy']?.toString()),
                              alreadySigned:
                                  currentUid.isNotEmpty &&
                                  ((data['signedBy'] as List?) ?? const [])
                                      .map((value) => value.toString())
                                      .contains(currentUid),
                              respondentCount:
                                  ((data['signedBy'] as List?) ?? const [])
                                      .length,
                              onCopy: (link) => _copyLink(link),
                              onRegister: () => _registerRespondent(
                                firestore: firestore,
                                currentUid: currentUid,
                              ),
                            );
                          },
                        ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 26, gutter, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pertanyaan dan jawaban',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${kuesioner.answers.length} informasi tercatat pada kuesioner ini.',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (kuesioner.answers.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 40),
                    sliver: const SliverToBoxAdapter(child: _EmptyAnswers()),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 40),
                    sliver: SliverList.separated(
                      itemCount: (kuesioner.answers.length / columns).ceil(),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, rowIndex) {
                        final first = rowIndex * columns;
                        if (columns == 1) {
                          return KuesionerAnswerCard(
                            index: first,
                            answer: kuesioner.answers[first],
                          );
                        }
                        final second = first + 1;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: KuesionerAnswerCard(
                                index: first,
                                answer: kuesioner.answers[first],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: second < kuesioner.answers.length
                                  ? KuesionerAnswerCard(
                                      index: second,
                                      answer: kuesioner.answers[second],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _copyLink(String link) async {
    if (link.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: link));
    Get.snackbar(
      'Tautan disalin',
      'Tautan kuesioner telah disalin ke clipboard.',
      backgroundColor: AppColors.primary,
      colorText: AppColors.surface,
    );
  }

  Future<void> _registerRespondent({
    required FirebaseFirestore firestore,
    required String currentUid,
  }) async {
    if (currentUid.isEmpty) return;
    try {
      final questionnaireRef = firestore
          .collection('kuesioners')
          .doc(kuesioner.id);
      final snapshot = await questionnaireRef.get();
      final signedBy = (snapshot.data()?['signedBy'] as List?) ?? const [];
      if (signedBy.map((value) => value.toString()).contains(currentUid)) {
        Get.snackbar('Info', 'Anda sudah terdaftar sebagai responden.');
        return;
      }
      final userRef = firestore.collection('users').doc(currentUid);
      await firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        final balance = (userSnapshot.data()?['saldo'] as int?) ?? 0;
        transaction.set(questionnaireRef, {
          'signedBy': FieldValue.arrayUnion([currentUid]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        if (userSnapshot.exists) {
          transaction.update(userRef, {
            'saldo': balance + 100,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
      Get.snackbar(
        'Berhasil',
        'Anda terdaftar sebagai responden dan saldo bertambah Rp 100.',
        backgroundColor: AppColors.greenColor,
        colorText: AppColors.surface,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat mendaftarkan responden: $error',
        backgroundColor: AppColors.redColor,
        colorText: AppColors.surface,
      );
    }
  }
}

class KuesionerDetailHeader extends StatelessWidget {
  const KuesionerDetailHeader({
    super.key,
    required this.item,
    required this.onBack,
  });
  final Kuesioner item;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.07),
            AppColors.lightPrimaryColor.withValues(alpha: 0.31),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.lightPrimaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          IconButton.filled(
            tooltip: 'Kembali',
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail kuesioner',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: MediaQuery.sizeOf(context).width < 600 ? 20 : 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy, HH:mm').format(item.createdAt),
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.status?.toLowerCase() == 'approved'
                  ? 'Disetujui'
                  : 'Menunggu',
              style: GoogleFonts.poppins(
                color: item.status?.toLowerCase() == 'approved'
                    ? AppColors.greenColor
                    : AppColors.yellow2Color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KuesionerAccessCard extends StatelessWidget {
  const KuesionerAccessCard({
    super.key,
    required this.link,
    required this.isCreator,
    required this.alreadySigned,
    required this.respondentCount,
    required this.onCopy,
    required this.onRegister,
  });
  final String link;
  final bool isCreator;
  final bool alreadySigned;
  final int respondentCount;
  final ValueChanged<String> onCopy;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final canAccess = isCreator || alreadySigned;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;
          final information = Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$respondentCount responden',
                      style: _text(13, FontWeight.w700),
                    ),
                    Text(
                      canAccess
                          ? (link.isEmpty ? 'Tautan belum tersedia' : link)
                          : 'Daftar untuk memperoleh akses kuesioner.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _text(
                        10,
                        FontWeight.w400,
                        AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final action = canAccess
              ? OutlinedButton.icon(
                  onPressed: link.isEmpty ? null : () => onCopy(link),
                  icon: const Icon(Icons.copy_rounded, size: 17),
                  label: const Text('Salin tautan'),
                )
              : FilledButton.icon(
                  onPressed: onRegister,
                  icon: const Icon(Icons.person_add_alt_rounded, size: 17),
                  label: const Text('Jadi responden'),
                );
          if (compact) {
            return Column(
              children: [
                information,
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: action),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: information),
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }
}

class KuesionerAnswerCard extends StatelessWidget {
  const KuesionerAnswerCard({
    super.key,
    required this.index,
    required this.answer,
  });
  final int index;
  final QuestionAnswer answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index + 1}',
              style: _text(12, FontWeight.w700, AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(answer.question, style: _text(13, FontWeight.w600)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.055),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    answer.answer,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAnswers extends StatelessWidget {
  const _EmptyAnswers();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          'Belum ada pertanyaan dan jawaban.',
          style: _text(12, FontWeight.w500, AppColors.textSecondary),
        ),
      ),
    );
  }
}

TextStyle _text(double size, FontWeight weight, [Color? color]) =>
    GoogleFonts.poppins(
      color: color ?? AppColors.textPrimary,
      fontSize: size,
      fontWeight: weight,
    );
