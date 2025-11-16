import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataUserKuesionerView extends StatefulWidget {
  final String? initialUsia;
  final String? initialKelamin;
  final String? initialPenghasilan;
  final String? initialPendidikan;
  const DataUserKuesionerView({
    super.key,
    this.initialUsia,
    this.initialKelamin,
    this.initialPenghasilan,
    this.initialPendidikan,
  });

  @override
  State<DataUserKuesionerView> createState() => _DataUserKuesionerViewState();
}

class _DataUserKuesionerViewState extends State<DataUserKuesionerView> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedUsia;
  String? _selectedKelamin;
  String? _selectedPenghasilan;
  String? _selectedPendidikan;

  // Dummy data untuk dropdown
  final List<String> _rentangUsia = ['18-25 tahun', '26-35 tahun', '36-45 tahun', '46-55 tahun', '56 tahun ke atas'];

  final List<String> _jenisKelamin = ['Laki-laki', 'Perempuan'];

  final List<String> _tingkatPenghasilan = [
    '< Rp 2.000.000',
    'Rp 2.000.000 - Rp 5.000.000',
    'Rp 5.000.000 - Rp 10.000.000',
    'Rp 10.000.000 - Rp 20.000.000',
    '> Rp 20.000.000',
  ];

  final List<String> _pendidikanTerakhir = [
    'SD/Sederajat',
    'SMP/Sederajat',
    'SMA/Sederajat',
    'D1/D2/D3',
    'S1/D4',
    'S2',
    'S3',
  ];

  @override
  void initState() {
    super.initState();
    // Prefill from initial values if provided
    _selectedUsia = widget.initialUsia;
    _selectedKelamin = widget.initialKelamin;
    _selectedPenghasilan = widget.initialPenghasilan;
    _selectedPendidikan = widget.initialPendidikan;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Ensure user id
        final String uid = _auth.currentUser?.uid ?? (await _auth.signInAnonymously()).user!.uid;
        // Save to users collection under 'responden' fields
        await _firestore.collection('users').doc(uid).set({
          'responden': {
            'rentangUsia': _selectedUsia,
            'jenisKelamin': _selectedKelamin,
            'tingkatPenghasilan': _selectedPenghasilan,
            'pendidikanTerakhir': _selectedPendidikan,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        }, SetOptions(merge: true));

        // Show success dialog
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 24),
                const SizedBox(width: 8),
                Text(
                  "Berhasil!",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
            content: Text(
              "Data diri Anda telah tersimpan. Sekarang Anda dapat mengisi kuesioner yang tersedia.",
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                child: Text(
                  "Kembali ke Kuesioner",
                  style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        Get.snackbar(
          'Gagal',
          'Tidak dapat menyimpan data: $e',
          backgroundColor: AppColors.error,
          colorText: AppColors.surface,
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header dengan gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Data Diri Responden',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Lengkapi data diri Anda terlebih dahulu',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Data ini akan membantu peneliti dalam menganalisis hasil kuesioner',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Konten form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Informasi penting
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Penting',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Data yang Anda berikan akan dijaga kerahasiaannya dan hanya digunakan untuk keperluan penelitian akademis.',
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Form container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section header
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  "Data Demografi",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Rentang Usia
                          _buildFormField(
                            icon: Icons.calendar_today_rounded,
                            title: "Rentang Usia",
                            subtitle: "Pilih rentang usia Anda",
                            child: DropdownButtonFormField<String>(
                              value: _selectedUsia,
                              isExpanded: true,
                              decoration: _buildInputDecoration(),
                              items: _rentangUsia
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item, style: GoogleFonts.poppins(color: AppColors.textPrimary)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUsia = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pilih rentang usia';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Jenis Kelamin
                          _buildFormField(
                            icon: Icons.people_alt_rounded,
                            title: "Jenis Kelamin",
                            subtitle: "Pilih jenis kelamin Anda",
                            child: DropdownButtonFormField<String>(
                              value: _selectedKelamin,
                              isExpanded: true,
                              decoration: _buildInputDecoration(),
                              items: _jenisKelamin
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item, style: GoogleFonts.poppins(color: AppColors.textPrimary)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedKelamin = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pilih jenis kelamin';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Tingkat Penghasilan
                          _buildFormField(
                            icon: Icons.attach_money_rounded,
                            title: "Tingkat Penghasilan",
                            subtitle: "Pilih tingkat penghasilan per bulan",
                            child: DropdownButtonFormField<String>(
                              value: _selectedPenghasilan,
                              isExpanded: true,
                              decoration: _buildInputDecoration(),
                              items: _tingkatPenghasilan
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item, style: GoogleFonts.poppins(color: AppColors.textPrimary)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPenghasilan = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pilih tingkat penghasilan';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Pendidikan Terakhir
                          _buildFormField(
                            icon: Icons.school_rounded,
                            title: "Pendidikan Terakhir",
                            subtitle: "Pilih tingkat pendidikan terakhir",
                            child: DropdownButtonFormField<String>(
                              value: _selectedPendidikan,
                              isExpanded: true,
                              decoration: _buildInputDecoration(),
                              items: _pendidikanTerakhir
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item, style: GoogleFonts.poppins(color: AppColors.textPrimary)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPendidikan = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pilih pendidikan terakhir';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                elevation: 2,
                                shadowColor: AppColors.primary.withOpacity(0.3),
                              ),
                              onPressed: _submitForm,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Simpan Data Diri",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.check_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
