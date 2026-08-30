import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import '../controllers/master_data_controller.dart';

int adminMasterDataColumnCount(double width) => width >= 900 ? 2 : 1;

class MasterDataView extends GetView<MasterDataController> {
  const MasterDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final basePadding = viewport.maxWidth < 600 ? 16.0 : 28.0;
            final gutter = viewport.maxWidth > 1336
                ? (viewport.maxWidth - 1336) / 2
                : 0.0;
            final horizontalPadding = basePadding + gutter;

            return Obx(() {
              final selectedTab = controller.selectedTab.value;
              final visibleItems = controller.getVisibleList();

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      0,
                    ),
                    child: _MasterDataHeader(
                      kampusCount: controller.kampusList.length,
                      jurusanCount: controller.jurusanList.length,
                      layananCount: controller.layananList.length,
                      onAdd: _showCreateDialog,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      0,
                    ),
                    child: _MasterDataTabs(
                      selectedIndex: selectedTab,
                      onSelected: controller.changeTab,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      14,
                    ),
                    child: _MasterDataToolbar(
                      selectedTab: selectedTab,
                      visibleCount: visibleItems.length,
                      kampusList: controller.kampusList,
                      selectedKampus: controller.selectedKampus.value,
                      selectedLayananFilter:
                          controller.selectedLayananFilter.value,
                      onSearchChanged: controller.updateSearchQuery,
                      onKampusChanged: controller.changeKampusFilter,
                      onLayananChanged: controller.changeLayananFilter,
                    ),
                  ),
                  Expanded(
                    child: controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : _buildDataList(
                            viewportWidth: viewport.maxWidth,
                            horizontalPadding: horizontalPadding,
                            items: visibleItems,
                          ),
                  ),
                ],
              );
            });
          },
        ),
      ),
    );
  }

  void _showCreateDialog() {
    controller.openCreateDialog();
    _showItemDialog();
  }

  void _showEditDialog(MasterDataItem item) {
    controller.openEditDialog(item);
    _showItemDialog(item: item);
  }

  void _showDeleteDialog(MasterDataItem item) {
    Get.dialog(
      AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        constraints: const BoxConstraints(maxWidth: 480),
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus data',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Yakin ingin menghapus “${item.name}”? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteItem(item.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.redColor),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDialog({MasterDataItem? item}) {
    final isEdit = item != null;
    final isLayanan = controller.selectedTab.value == 2;
    final isJurusan = controller.selectedTab.value == 1;
    final dataLabel = _masterDataLabel(controller.selectedTab.value);

    Get.dialog(
      AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        constraints: const BoxConstraints(maxWidth: 560),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 22, 16, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        actionsOverflowAlignment: OverflowBarAlignment.end,
        actionsOverflowButtonSpacing: 10,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.checkoutButtonColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                _masterDataIcon(controller.selectedTab.value),
                color: AppColors.primaryColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit $dataLabel' : 'Tambah $dataLabel',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEdit
                        ? 'Perbarui informasi data yang dipilih.'
                        : 'Lengkapi informasi data baru.',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Tutup',
              onPressed: Get.back,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Nama $dataLabel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: GoogleFonts.poppins(),
                ),
                style: GoogleFonts.poppins(),
                autofocus: true,
              ),
              if (isJurusan && isEdit) ...[
                const SizedBox(height: 16),
                Obx(() {
                  final selectedKampusName =
                      controller.kampusList
                          .firstWhereOrNull(
                            (k) =>
                                k.id ==
                                controller.selectedKampusForJurusan.value,
                          )
                          ?.name ??
                      'Kampus belum dipilih';
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kampus',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedKampusName,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              if (isJurusan && !isEdit) ...[
                const SizedBox(height: 16),
                Obx(() {
                  final selectedKampusName =
                      controller.kampusList
                          .firstWhereOrNull(
                            (k) => k.id == controller.selectedKampus.value,
                          )
                          ?.name ??
                      'Kampus belum dipilih';
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kampus',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedKampusName,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              if (isLayanan && isEdit) ...[
                const SizedBox(height: 16),
                Obx(() {
                  final selectedTypeName =
                      controller.typeController.value == 'complink'
                      ? 'Cermat Competition'
                      : 'Cermat Paper';
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tipe layanan',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedTypeName,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.hargaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga (Rupiah)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelStyle: GoogleFonts.poppins(),
                    prefixText: 'Rp ',
                    prefixStyle: GoogleFonts.poppins(),
                  ),
                  style: GoogleFonts.poppins(),
                  onChanged: (value) {
                    // Remove non-numeric characters
                    final numericValue = value.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    if (numericValue != value) {
                      controller.hargaController.value = TextEditingValue(
                        text: numericValue,
                        selection: TextSelection.collapsed(
                          offset: numericValue.length,
                        ),
                      );
                    }
                  },
                ),
              ],
              if (isLayanan && !isEdit) ...[
                const SizedBox(height: 16),
                Obx(() {
                  final selectedTypeName =
                      controller.typeController.value == 'complink'
                      ? 'Cermat Competition'
                      : 'Cermat Paper';
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tipe layanan',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedTypeName,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.hargaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga (Rupiah)',
                    hintText: 'Contoh: 500000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Rp',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  style: GoogleFonts.poppins(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              minimumSize: const Size(88, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () {
                      if (isEdit) {
                        final harga = controller.hargaController.text.isNotEmpty
                            ? int.tryParse(
                                controller.hargaController.text.replaceAll(
                                  RegExp(r'[^0-9]'),
                                  '',
                                ),
                              )
                            : null;
                        controller.updateItem(
                          item.id,
                          controller.nameController.text,
                          type: isLayanan
                              ? controller.typeController.value
                              : null,
                          kampusId: isJurusan
                              ? controller.selectedKampusForJurusan.value
                              : null,
                          harga: isLayanan ? harga : null,
                        );
                      } else {
                        final harga = controller.hargaController.text.isNotEmpty
                            ? int.tryParse(
                                controller.hargaController.text.replaceAll(
                                  RegExp(r'[^0-9]'),
                                  '',
                                ),
                              )
                            : null;
                        controller.createItem(
                          controller.nameController.text,
                          type: isLayanan
                              ? controller.typeController.value
                              : null,
                          kampusId: isJurusan
                              ? controller.selectedKampusForJurusan.value
                              : null,
                          harga: isLayanan ? harga : null,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                minimumSize: const Size(142, 46),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.surface,
                        ),
                      ),
                    )
                  : Text(
                      isEdit ? 'Simpan perubahan' : 'Tambah data',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataList({
    required double viewportWidth,
    required double horizontalPadding,
    required List<MasterDataItem> items,
  }) {
    final isJurusan = controller.selectedTab.value == 1;
    final hasSelectedKampus = controller.selectedKampus.value.isNotEmpty;

    if (isJurusan && !hasSelectedKampus) {
      return const _MasterDataEmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Pilih kampus terlebih dahulu',
        subtitle: 'Daftar jurusan akan ditampilkan berdasarkan kampus.',
      );
    }

    if (items.isEmpty) {
      return _MasterDataEmptyState(
        icon: controller.searchQuery.value.isNotEmpty
            ? Icons.search_off_rounded
            : _masterDataIcon(controller.selectedTab.value),
        title: controller.searchQuery.value.isNotEmpty
            ? 'Data tidak ditemukan'
            : 'Belum ada data',
        subtitle: controller.searchQuery.value.isNotEmpty
            ? 'Coba gunakan kata pencarian yang berbeda.'
            : 'Gunakan tombol Tambah data untuk membuat data baru.',
      );
    }

    final availableWidth = viewportWidth - (horizontalPadding * 2);
    final columns = adminMasterDataColumnCount(availableWidth);
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        viewportWidth < 600 ? 108 : 34,
      ),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 108,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final kampusName = isJurusan && item.kampusId != null
            ? controller.kampusList
                      .firstWhereOrNull((kampus) => kampus.id == item.kampusId)
                      ?.name ??
                  ''
            : '';

        return AdminMasterDataCard(
          item: item,
          tabIndex: controller.selectedTab.value,
          kampusName: kampusName,
          onOpen: controller.selectedTab.value == 0
              ? () => controller.openJurusanForKampus(item.id)
              : null,
          onEdit: () => _showEditDialog(item),
          onDelete: () => _showDeleteDialog(item),
        );
      },
    );
  }
}

class _MasterDataHeader extends StatelessWidget {
  const _MasterDataHeader({
    required this.kampusCount,
    required this.jurusanCount,
    required this.layananCount,
    required this.onAdd,
  });

  final int kampusCount;
  final int jurusanCount;
  final int layananCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.checkoutButtonColor,
            AppColors.lightPrimaryColor.withValues(alpha: 0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.14),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final description = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'DATA MANAGEMENT',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kelola master data',
                style: GoogleFonts.poppins(
                  fontSize: compact ? 22 : 27,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Atur kampus, jurusan, dan layanan yang digunakan Cermatify.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
          final actions = Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _MasterDataCount(label: 'Kampus', value: kampusCount),
              _MasterDataCount(label: 'Jurusan', value: jurusanCount),
              _MasterDataCount(label: 'Layanan', value: layananCount),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 19),
                label: Text(
                  'Tambah data',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [description, const SizedBox(height: 18), actions],
            );
          }

          return Row(
            children: [
              Expanded(child: description),
              const SizedBox(width: 20),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _MasterDataTabs extends StatelessWidget {
  const _MasterDataTabs({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (label: 'Kampus', icon: Icons.school_outlined),
      (label: 'Jurusan', icon: Icons.menu_book_outlined),
      (label: 'Layanan', icon: Icons.work_outline_rounded),
    ];

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(11),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[index].icon,
                      size: 18,
                      color: selected
                          ? AppColors.surface
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        tabs[index].label,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.surface
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MasterDataToolbar extends StatelessWidget {
  const _MasterDataToolbar({
    required this.selectedTab,
    required this.visibleCount,
    required this.kampusList,
    required this.selectedKampus,
    required this.selectedLayananFilter,
    required this.onSearchChanged,
    required this.onKampusChanged,
    required this.onLayananChanged,
  });

  final int selectedTab;
  final int visibleCount;
  final List<MasterDataItem> kampusList;
  final String selectedKampus;
  final String selectedLayananFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onKampusChanged;
  final ValueChanged<String> onLayananChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final search = TextField(
          key: ValueKey('master-search-$selectedTab'),
          onChanged: onSearchChanged,
          style: GoogleFonts.poppins(fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Cari ${_masterDataLabel(selectedTab).toLowerCase()}...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
          ),
        );
        final filter = _buildFilter();
        final count = Text(
          '$visibleCount data',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              search,
              if (filter != null) ...[const SizedBox(height: 10), filter],
              const SizedBox(height: 9),
              count,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: search),
            if (filter != null) ...[
              const SizedBox(width: 12),
              SizedBox(width: 300, child: filter),
            ],
            const SizedBox(width: 16),
            count,
          ],
        );
      },
    );
  }

  Widget? _buildFilter() {
    if (selectedTab == 1) {
      return DropdownButtonFormField<String>(
        initialValue: selectedKampus.isEmpty ? null : selectedKampus,
        isExpanded: true,
        hint: Text('Pilih kampus', style: GoogleFonts.poppins(fontSize: 12)),
        decoration: _filterDecoration(Icons.school_outlined),
        items: kampusList
            .map(
              (kampus) => DropdownMenuItem(
                value: kampus.id,
                child: Text(
                  kampus.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 11),
                ),
              ),
            )
            .toList(),
        onChanged: (value) => onKampusChanged(value ?? ''),
      );
    }

    if (selectedTab == 2) {
      return DropdownButtonFormField<String>(
        initialValue: selectedLayananFilter,
        decoration: _filterDecoration(Icons.filter_alt_outlined),
        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textPrimary),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('Semua layanan')),
          DropdownMenuItem(
            value: 'complink',
            child: Text('Cermat Competition'),
          ),
          DropdownMenuItem(value: 'paperlink', child: Text('Cermat Paper')),
        ],
        onChanged: (value) {
          if (value != null) onLayananChanged(value);
        },
      );
    }

    return null;
  }

  InputDecoration _filterDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 19),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
    );
  }
}

class AdminMasterDataCard extends StatelessWidget {
  const AdminMasterDataCard({
    super.key,
    required this.item,
    required this.tabIndex,
    required this.kampusName,
    required this.onEdit,
    required this.onDelete,
    this.onOpen,
  });

  final MasterDataItem item;
  final int tabIndex;
  final String kampusName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final color = tabIndex == 2 ? AppColors.greenColor : AppColors.primaryColor;
    final detail = tabIndex == 0
        ? 'Klik untuk melihat jurusan'
        : tabIndex == 1 && kampusName.isNotEmpty
        ? kampusName
        : tabIndex == 2 && item.harga != null
        ? AppFormats.hargaPendek(item.harga!)
        : _masterDataLabel(tabIndex);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.025),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_masterDataIcon(tabIndex), color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (tabIndex == 2 && item.type != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        item.type == 'complink'
                            ? 'Cermat Competition'
                            : 'Cermat Paper',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CardAction(
                tooltip: 'Edit data',
                icon: Icons.edit_outlined,
                color: AppColors.primaryColor,
                onTap: onEdit,
              ),
              const SizedBox(width: 6),
              _CardAction(
                tooltip: 'Hapus data',
                icon: Icons.delete_outline_rounded,
                color: AppColors.redColor,
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}

class _MasterDataCount extends StatelessWidget {
  const _MasterDataCount({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        '$value $label',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _MasterDataEmptyState extends StatelessWidget {
  const _MasterDataEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _masterDataIcon(int index) {
  switch (index) {
    case 1:
      return Icons.menu_book_outlined;
    case 2:
      return Icons.work_outline_rounded;
    default:
      return Icons.school_outlined;
  }
}

String _masterDataLabel(int index) {
  switch (index) {
    case 1:
      return 'Jurusan';
    case 2:
      return 'Layanan';
    default:
      return 'Kampus';
  }
}
