import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/modules/kuesioner/controllers/kuesioner_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

int respondentFormColumnCount(double width) => width >= 900 ? 2 : 1;

class DataUserKuesionerView extends StatefulWidget {
  const DataUserKuesionerView({
    super.key,
    this.initialUsia,
    this.initialKelamin,
    this.initialPenghasilan,
    this.initialPendidikan,
  });
  final String? initialUsia;
  final String? initialKelamin;
  final String? initialPenghasilan;
  final String? initialPendidikan;

  @override
  State<DataUserKuesionerView> createState() => _DataUserKuesionerViewState();
}

class _DataUserKuesionerViewState extends State<DataUserKuesionerView> {
  static const _ages = [
    '18-25 tahun',
    '26-35 tahun',
    '36-45 tahun',
    '46-55 tahun',
    '56 tahun ke atas',
  ];
  static const _genders = ['Laki-laki', 'Perempuan'];
  static const _incomes = [
    '< Rp 2.000.000',
    'Rp 2.000.000 - Rp 5.000.000',
    'Rp 5.000.000 - Rp 10.000.000',
    'Rp 10.000.000 - Rp 20.000.000',
    '> Rp 20.000.000',
  ];
  static const _educations = [
    'SD/Sederajat',
    'SMP/Sederajat',
    'SMA/Sederajat',
    'D1/D2/D3',
    'S1/D4',
    'S2',
    'S3',
  ];

  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? _age;
  String? _gender;
  String? _income;
  String? _education;
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _age = _valid(widget.initialUsia, _ages);
    _gender = _valid(widget.initialKelamin, _genders);
    _income = _valid(widget.initialPenghasilan, _incomes);
    _education = _valid(widget.initialPendidikan, _educations);
    if ([_age, _gender, _income, _education].every((value) => value == null)) {
      _loadExistingData();
    }
  }

  String? _valid(String? value, List<String> options) =>
      value != null && options.contains(value) ? value : null;

  Future<void> _loadExistingData() async {
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    setState(() => _loading = true);
    try {
      final snapshot = await _firestore.collection('data_diri').doc(uid).get();
      final data = snapshot.data();
      if (mounted && data != null) {
        setState(() {
          _age = _valid(data['rentangUsia'] as String?, _ages);
          _gender = _valid(data['jenisKelamin'] as String?, _genders);
          _income = _valid(data['tingkatPenghasilan'] as String?, _incomes);
          _education = _valid(
            data['pendidikanTerakhir'] as String?,
            _educations,
          );
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final desktop = respondentFormColumnCount(viewport.maxWidth) == 2;
            final padding = viewport.maxWidth < 600 ? 16.0 : 28.0;
            final gutter = viewport.maxWidth > 1156
                ? (viewport.maxWidth - 1100) / 2
                : padding;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(gutter, padding, gutter, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RespondentFormHeader(onBack: Get.back),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (desktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 330,
                          child: RespondentPrivacyPanel(),
                        ),
                        const SizedBox(width: 20),
                        Expanded(child: _buildForm()),
                      ],
                    )
                  else ...[
                    const RespondentPrivacyPanel(compact: true),
                    const SizedBox(height: 14),
                    _buildForm(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Data demografi', style: _text(18, FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Isi setiap pilihan sesuai kondisi Anda saat ini.',
              style: _text(11, FontWeight.w400, AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _dropdown(
              label: 'Rentang usia',
              icon: Icons.calendar_today_outlined,
              value: _age,
              items: _ages,
              onChanged: (value) => setState(() => _age = value),
            ),
            const SizedBox(height: 15),
            _dropdown(
              label: 'Jenis kelamin',
              icon: Icons.people_alt_outlined,
              value: _gender,
              items: _genders,
              onChanged: (value) => setState(() => _gender = value),
            ),
            const SizedBox(height: 15),
            _dropdown(
              label: 'Tingkat penghasilan per bulan',
              icon: Icons.payments_outlined,
              value: _income,
              items: _incomes,
              onChanged: (value) => setState(() => _income = value),
            ),
            const SizedBox(height: 15),
            _dropdown(
              label: 'Pendidikan terakhir',
              icon: Icons.school_outlined,
              value: _education,
              items: _educations,
              onChanged: (value) => setState(() => _education = value),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_saving ? 'Menyimpan...' : 'Simpan data responden'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text(12, FontWeight.w400),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (selected) => selected == null ? '$label wajib dipilih' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: _text(11, FontWeight.w400, AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final uid =
          _auth.currentUser?.uid ??
          (await _auth.signInAnonymously()).user?.uid ??
          '';
      if (uid.isEmpty) throw StateError('Akun pengguna tidak tersedia');
      await _firestore.collection('data_diri').doc(uid).set({
        'userId': uid,
        'rentangUsia': _age,
        'jenisKelamin': _gender,
        'tingkatPenghasilan': _income,
        'pendidikanTerakhir': _education,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (Get.isRegistered<KuesionerController>()) {
        await Get.find<KuesionerController>().reloadRespondenData();
      }
      Get.snackbar(
        'Data tersimpan',
        'Rekomendasi kuesioner telah diperbarui.',
        backgroundColor: AppColors.greenColor,
        colorText: AppColors.surface,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      Get.snackbar(
        'Gagal menyimpan',
        'Tidak dapat menyimpan data: $error',
        backgroundColor: AppColors.redColor,
        colorText: AppColors.surface,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class RespondentFormHeader extends StatelessWidget {
  const RespondentFormHeader({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.07),
            AppColors.lightPrimaryColor.withValues(alpha: 0.31),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
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
                  'Data responden',
                  style: _text(
                    MediaQuery.sizeOf(context).width < 600 ? 20 : 24,
                    FontWeight.w800,
                  ),
                ),
                Text(
                  'Lengkapi profil untuk memperoleh rekomendasi yang relevan.',
                  style: _text(11, FontWeight.w400, AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RespondentPrivacyPanel extends StatelessWidget {
  const RespondentPrivacyPanel({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 22),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Privasi tetap terjaga',
            style: _text(17, FontWeight.w700, AppColors.surface),
          ),
          const SizedBox(height: 7),
          Text(
            'Data digunakan untuk pencocokan kriteria penelitian dan tidak ditampilkan sebagai identitas publik.',
            style: GoogleFonts.poppins(
              color: AppColors.surface.withValues(alpha: 0.78),
              fontSize: 11,
              height: 1.6,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 20),
            for (final text in const [
              'Digunakan untuk rekomendasi',
              'Dapat diperbarui kapan saja',
              'Tersimpan pada akun Anda',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.surface,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: _text(10, FontWeight.w500, AppColors.surface),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
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
