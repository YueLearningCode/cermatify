import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/faq/controllers/faq_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

int faqColumnCount(double width) => width >= 900 ? 2 : 1;

class FaqView extends GetView<FaqController> {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final padding = viewport.maxWidth < 600 ? 16.0 : 28.0;
            final gutter = viewport.maxWidth > 1256
                ? (viewport.maxWidth - 1200) / 2
                : padding;
            final columns = faqColumnCount(viewport.maxWidth);
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, padding, gutter, 0),
                  sliver: SliverToBoxAdapter(
                    child: FaqHeader(questionCount: controller.faqs.length),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pertanyaan yang sering diajukan',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pilih pertanyaan untuk melihat penjelasan lengkap.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 40),
                  sliver: SliverList.separated(
                    itemCount: (controller.faqs.length / columns).ceil(),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, rowIndex) {
                      final first = rowIndex * columns;
                      if (columns == 1) {
                        return FaqCard(
                          index: first,
                          item: controller.faqs[first],
                        );
                      }
                      final second = first + 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: FaqCard(
                              index: first,
                              item: controller.faqs[first],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: second < controller.faqs.length
                                ? FaqCard(
                                    index: second,
                                    item: controller.faqs[second],
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
}

class FaqHeader extends StatelessWidget {
  const FaqHeader({super.key, required this.questionCount});
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 22 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.07),
            AppColors.lightPrimaryColor.withValues(alpha: 0.32),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.lightPrimaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pusat bantuan mentor',
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.sizeOf(context).width < 600 ? 20 : 25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Temukan jawaban seputar penggunaan dan layanan Cermatify.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 560)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$questionCount topik',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FaqCard extends StatelessWidget {
  const FaqCard({super.key, required this.index, required this.item});
  final int index;
  final Map<String, String> item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          title: Text(
            item['question'] ?? '',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                item['answer'] ?? '',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
