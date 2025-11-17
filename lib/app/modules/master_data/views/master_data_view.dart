import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import '../controllers/master_data_controller.dart';

class MasterDataView extends GetView<MasterDataController> {
  const MasterDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Master Data",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: Column(
        children: [
          // Tab Selector
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: AppColors.border.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabButton(
                      label: 'Kampus',
                      index: 0,
                      icon: Icons.school_outlined,
                      isSelected: controller.selectedTab.value == 0,
                    ),
                    _buildTabButton(
                      label: 'Jurusan',
                      index: 1,
                      icon: Icons.menu_book_outlined,
                      isSelected: controller.selectedTab.value == 1,
                    ),
                    _buildTabButton(
                      label: 'Layanan',
                      index: 2,
                      icon: Icons.work_outline,
                      isSelected: controller.selectedTab.value == 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Filter for Jurusan (Kampus selector)
          Obx(
            () => controller.selectedTab.value == 1
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Text(
                          'Kampus:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => DropdownButton<String?>(
                              value: controller.selectedKampus.value.isEmpty ? null : controller.selectedKampus.value,
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: Text(
                                'Select Kampus',
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Select Kampus', style: GoogleFonts.poppins(fontSize: 12)),
                                ),
                                ...controller.kampusList.map(
                                  (kampus) => DropdownMenuItem<String?>(
                                    value: kampus.id,
                                    child: Text(kampus.name, style: GoogleFonts.poppins(fontSize: 12)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                controller.changeKampusFilter(value ?? '');
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Filter for Layanan
          Obx(
            () => controller.selectedTab.value == 2
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Text(
                          'Filter:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => DropdownButton<String>(
                              value: controller.selectedLayananFilter.value,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'all', child: Text('All')),
                                DropdownMenuItem(value: 'complink', child: Text('Cermat Competition')),
                                DropdownMenuItem(value: 'paperlink', child: Text('Cermat Paper')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  controller.changeLayananFilter(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          // Content
          Expanded(
            child: Obx(
              () => controller.isLoading.value ? const Center(child: CircularProgressIndicator()) : _buildDataList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.surface),
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
        title: Text('Delete Item', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to delete "${item.name}"?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteItem(item.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.redColor),
            child: Text('Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showItemDialog({MasterDataItem? item}) {
    final isEdit = item != null;
    final isLayanan = controller.selectedTab.value == 2;
    final isJurusan = controller.selectedTab.value == 1;

    Get.dialog(
      AlertDialog(
        title: Text(isEdit ? 'Edit Item' : 'Create Item', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: const OutlineInputBorder(),
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
                          .firstWhereOrNull((k) => k.id == controller.selectedKampusForJurusan.value)
                          ?.name ??
                      'No Kampus Selected';
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school_outlined, color: AppColors.primary, size: 20),
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
                      controller.kampusList.firstWhereOrNull((k) => k.id == controller.selectedKampus.value)?.name ??
                      'No Kampus Selected';
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school_outlined, color: AppColors.primary, size: 20),
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
                  final selectedTypeName = controller.typeController.value == 'complink'
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
                        Icon(Icons.category_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Type',
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
                    border: const OutlineInputBorder(),
                    labelStyle: GoogleFonts.poppins(),
                    prefixText: 'Rp ',
                    prefixStyle: GoogleFonts.poppins(),
                  ),
                  style: GoogleFonts.poppins(),
                  onChanged: (value) {
                    // Remove non-numeric characters
                    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (numericValue != value) {
                      controller.hargaController.value = TextEditingValue(
                        text: numericValue,
                        selection: TextSelection.collapsed(offset: numericValue.length),
                      );
                    }
                  },
                ),
              ],
              if (isLayanan && !isEdit) ...[
                const SizedBox(height: 16),
                Obx(() {
                  final selectedTypeName = controller.typeController.value == 'complink'
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
                        Icon(Icons.category_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Type',
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
                    border: const OutlineInputBorder(),
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Rp',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary),
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
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () {
                      if (isEdit) {
                        final harga = controller.hargaController.text.isNotEmpty
                            ? int.tryParse(controller.hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''))
                            : null;
                        controller.updateItem(
                          item.id,
                          controller.nameController.text,
                          type: isLayanan ? controller.typeController.value : null,
                          kampusId: isJurusan ? controller.selectedKampusForJurusan.value : null,
                          harga: isLayanan ? harga : null,
                        );
                      } else {
                        final harga = controller.hargaController.text.isNotEmpty
                            ? int.tryParse(controller.hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''))
                            : null;
                        controller.createItem(
                          controller.nameController.text,
                          type: isLayanan ? controller.typeController.value : null,
                          kampusId: isJurusan ? controller.selectedKampusForJurusan.value : null,
                          harga: isLayanan ? harga : null,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.surface),
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                      ),
                    )
                  : Text(isEdit ? 'Update' : 'Create', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required int index,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.surface : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList() {
    final items = controller.getCurrentList();
    final isJurusan = controller.selectedTab.value == 1;
    final hasSelectedKampus = controller.selectedKampus.value.isNotEmpty;

    if (isJurusan && !hasSelectedKampus) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Select a Kampus',
              style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Please select a kampus from the dropdown above to view jurusan',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              controller.selectedTab.value == 0
                  ? Icons.school_outlined
                  : controller.selectedTab.value == 1
                  ? Icons.menu_book_outlined
                  : Icons.work_outline,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No data found',
              style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add new item',
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(MasterDataItem item) {
    final isJurusan = controller.selectedTab.value == 1;
    final kampusName = isJurusan && item.kampusId != null
        ? controller.kampusList.firstWhereOrNull((k) => k.id == item.kampusId)?.name ?? ''
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.border.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                if (isJurusan && kampusName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    kampusName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (item.type != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.type == 'complink'
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.type == 'complink' ? 'Cermat Competition' : 'Cermat Paper',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: item.type == 'complink' ? AppColors.primary : AppColors.greenColor,
                      ),
                    ),
                  ),
                ],
                if (item.harga != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppFormats.hargaPendek(item.harga!),
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => _showEditDialog(item),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: AppColors.redColor),
            onPressed: () => _showDeleteDialog(item),
          ),
        ],
      ),
    );
  }
}
