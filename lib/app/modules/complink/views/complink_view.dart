import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:cermatify/app/data/models/competition_catalog.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/mentor_discovery_layout.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../paperlink/views/list_mentor_view.dart';
import '../controllers/complink_controller.dart';

class ComplinkView extends GetView<ComplinkController> {
  const ComplinkView({super.key});

  void _goBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }
    Get.offAllNamed(Routes.DASHBOARD);
  }

  Future<void> _searchMentors() async {
    if (!controller.isFilterComplete) {
      Get.snackbar(
        'Kategori belum dipilih',
        'Pilih bidang kompetisi yang ingin Anda persiapkan.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    int? price;
    try {
      final document = await FirebaseFirestore.instance
          .collection('layanan')
          .doc(controller.selectedCabang.value)
          .get();
      price = (document.data()?['harga'] as num?)?.toInt();
    } catch (error) {
      AppLogger.info('Error fetching layanan price: $error');
    }

    Get.to(
      () => ListMentorView(
        layanan: controller.selectedCabangName,
        layananId: controller.selectedCabang.value,
        layananPrice: price,
        layananType: 'complink',
        competitionCategory: controller.selectedCategoryName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MentorDiscoveryPage(
      eyebrow: 'Cermat Competition',
      title: 'Persiapkan kompetisi bersama mentor',
      subtitle:
          'Temukan mentor yang sesuai dengan bidang lomba dan target pencapaian Anda.',
      guideTitle: 'Berkompetisi lebih siap',
      guideDescription:
          'Susun strategi, validasi ide, dan tingkatkan kualitas karya bersama mentor berpengalaman.',
      guideIcon: Icons.emoji_events_outlined,
      onBack: _goBack,
      form: Obx(
        () => DiscoveryFormCard(
          title: 'Pilih bidang kompetisi',
          subtitle:
              'Kami akan menampilkan mentor terverifikasi yang relevan dengan pilihan Anda.',
          loading: controller.isLoading.value,
          errorMessage: controller.loadError.value,
          onRetry: controller.fetchMasterData,
          onSubmit: _searchMentors,
          children: [
            DiscoverySelectField(
              label: 'Kategori lomba',
              hint: 'Cari kategori lomba',
              icon: Icons.category_outlined,
              value: controller.selectedCategory.value,
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Semua kategori'),
                ),
                const DropdownMenuItem(
                  value: uncategorizedCompetitionId,
                  child: Text('Belum dikategorikan'),
                ),
                ...controller.categories.map(
                  (item) => DropdownMenuItem(
                    value: item['id'],
                    child: Text(item['name'] ?? ''),
                  ),
                ),
              ],
              onChanged: (value) =>
                  controller.selectedCategory.value = value ?? '',
            ),
            DiscoverySelectField(
              label: 'Cabang atau layanan lomba',
              hint: 'Cari cabang lomba',
              icon: Icons.workspace_premium_outlined,
              value: _safeValue(
                controller.selectedCabang.value,
                controller.filteredLayanan,
              ),
              items: controller.filteredLayanan
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item['id'],
                      child: Text(
                        controller.serviceChoiceLabel(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) =>
                  controller.selectedCabang.value = value ?? '',
            ),
          ],
        ),
      ),
    );
  }

  String? _safeValue(String value, List<Map<String, String>> source) {
    if (value.isEmpty) return null;
    return source.any((item) => item['id'] == value) ? value : null;
  }
}
