import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cermatify/app/routes/app_pages.dart';

int kuesionerDetailColumnCount(double width) => width >= 920 ? 2 : 1;

class KuesionerDetailView extends StatelessWidget {
  const KuesionerDetailView({super.key, required this.kuesioner});
  final Kuesioner kuesioner;

  void _goBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }
    Get.offAllNamed(
      Routes.DASHBOARD,
      arguments: const <String, dynamic>{'initialTab': 2},
    );
  }

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
                      onBack: _goBack,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
                  sliver: SliverToBoxAdapter(
                    child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: firestore
                          .collection('kuesioners')
                          .doc(kuesioner.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text(
                            'Akses kuesioner belum dapat diperiksa. Kembali dan buka lagi untuk mencoba ulang.',
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final data = snapshot.data?.data();
                        if (data == null) {
                          return const Text('Kuesioner tidak lagi tersedia.');
                        }
                        final signedBy = data['signedBy'] is List
                            ? data['signedBy'] as List
                            : const [];
                        return KuesionerAccessCard(
                          link: data['link']?.toString() ?? '',
                          isCreator:
                              currentUid.isNotEmpty &&
                              currentUid ==
                                  (data['userId']?.toString() ??
                                      data['createdBy']?.toString()),
                          alreadySigned:
                              currentUid.isNotEmpty &&
                              signedBy
                                  .map((value) => value.toString())
                                  .contains(currentUid),
                          respondentCount: signedBy.length,
                          onCopy: (link) => _copyLink(link),
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
  });
  final String link;
  final bool isCreator;
  final bool alreadySigned;
  final int respondentCount;
  final ValueChanged<String> onCopy;

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
                      '$respondentCount pendaftaran tercatat',
                      style: _text(13, FontWeight.w700),
                    ),
                    Text(
                      canAccess
                          ? (link.isEmpty ? 'Tautan belum tersedia' : link)
                          : 'Pendaftaran responden baru belum tersedia.',
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
                  onPressed: null,
                  icon: const Icon(Icons.hourglass_empty_rounded, size: 17),
                  label: const Text('Pendaftaran belum tersedia'),
                );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [information, const SizedBox(height: 14), action],
                )
              else
                Row(
                  children: [
                    Expanded(child: information),
                    const SizedBox(width: 16),
                    action,
                  ],
                ),
              const SizedBox(height: 16),
              const QuestionnaireRewardNotice(),
            ],
          );
        },
      ),
    );
  }
}

/// Availability only: no simulated claim, enrollment, or balance mutations.
class QuestionnaireRewardNotice extends StatelessWidget {
  const QuestionnaireRewardNotice({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reward belum tersedia', style: _text(13, FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          'Membuka tautan atau terdaftar sebagai responden tidak menambah saldo. Klaim reward belum diaktifkan.',
          style: _text(12, FontWeight.w400, AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          'Saat program tersedia, respons perlu dikirim dan divalidasi sebelum reward disetujui. Syarat dan nominal akan dijelaskan sebelum kamu ikut.',
          style: _text(12, FontWeight.w400, AppColors.textSecondary),
        ),
      ],
    ),
  );
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
