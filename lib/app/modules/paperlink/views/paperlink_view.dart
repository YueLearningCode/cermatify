import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/mentor_discovery_layout.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/paperlink_controller.dart';
import 'list_mentor_view.dart';

class PaperlinkView extends GetView<PaperlinkController> {
  const PaperlinkView({super.key});

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
        'Filter belum lengkap',
        'Pilih kampus, jurusan, dan layanan terlebih dahulu.',
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
          .doc(controller.selectedLayanan.value)
          .get();
      price = (document.data()?['harga'] as num?)?.toInt();
    } catch (error) {
      AppLogger.info('Error fetching layanan price: $error');
    }

    Get.to(
      () => ListMentorView(
        kampus: controller.selectedUniversitasName,
        jurusan: controller.selectedJurusanName,
        layanan: controller.selectedLayananName,
        layananId: controller.selectedLayanan.value,
        layananPrice: price,
        layananType: 'paperlink',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MentorDiscoveryPage(
      eyebrow: 'Cermat Paper',
      title: 'Temukan mentor riset',
      subtitle:
          'Pilih bidang yang sesuai untuk mendapatkan pendampingan penelitian dan publikasi.',
      guideTitle: 'Riset lebih terarah',
      guideDescription:
          'Mentor Cermat Paper membantu dari penyusunan ide, metodologi, hingga persiapan publikasi.',
      guideIcon: Icons.description_outlined,
      onBack: _goBack,
      form: Obx(
        () => DiscoveryFormCard(
          title: 'Kebutuhan pendampingan',
          subtitle:
              'Pilihan jurusan akan menyesuaikan kampus yang Anda tentukan.',
          loading: controller.isLoading.value,
          errorMessage: controller.loadError.value,
          onRetry: controller.fetchMasterData,
          onSubmit: _searchMentors,
          children: [
            DiscoverySelectField(
              label: 'Kampus',
              hint: 'Pilih kampus',
              icon: Icons.account_balance_outlined,
              value: _safeValue(
                controller.selectedUniversitas.value,
                controller.listKampus,
              ),
              items: _items(controller.listKampus),
              onChanged: (value) =>
                  controller.selectedUniversitas.value = value ?? '',
            ),
            DiscoverySelectField(
              label: 'Jurusan',
              hint: controller.selectedUniversitas.value.isEmpty
                  ? 'Pilih kampus terlebih dahulu'
                  : 'Pilih jurusan',
              icon: Icons.menu_book_outlined,
              enabled: controller.selectedUniversitas.value.isNotEmpty,
              value: _safeValue(
                controller.selectedJurusan.value,
                controller.filteredJurusan,
              ),
              items: _items(controller.filteredJurusan),
              onChanged: (value) =>
                  controller.selectedJurusan.value = value ?? '',
            ),
            DiscoverySelectField(
              label: 'Layanan riset dan publikasi',
              hint: 'Pilih layanan',
              icon: Icons.analytics_outlined,
              value: _safeValue(
                controller.selectedLayanan.value,
                controller.filteredLayanan,
              ),
              items: _items(controller.filteredLayanan),
              onChanged: (value) =>
                  controller.selectedLayanan.value = value ?? '',
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _items(List<Map<String, String>> source) =>
      source
          .map(
            (item) => DropdownMenuItem<String>(
              value: item['id'],
              child: Text(
                item['name'] ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false);

  String? _safeValue(String value, List<Map<String, String>> source) {
    if (value.isEmpty) return null;
    return source.any((item) => item['id'] == value) ? value : null;
  }
}
