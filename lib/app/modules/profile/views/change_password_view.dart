import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/services/session_state.dart';
import 'package:cermatify/app/modules/profile/controllers/profile_controller.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

int changePasswordColumnCount(double width) => width >= 900 ? 2 : 1;

String changePasswordFallbackRoute(String? role) =>
    role == 'admin' ? Routes.ADMIN_DASHBOARD : Routes.PROFILE;

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  late final ProfileController controller;
  final _hidden = <bool>[true, true, true];

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();
    _password.addListener(_refreshStrength);
  }

  @override
  void dispose() {
    _password.removeListener(_refreshStrength);
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _refreshStrength() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop =
                changePasswordColumnCount(constraints.maxWidth) == 2;
            final padding = constraints.maxWidth < 600 ? 16.0 : 28.0;
            final gutter = constraints.maxWidth > 1156
                ? (constraints.maxWidth - 1100) / 2
                : padding;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(gutter, padding, gutter, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SecurityHeader(onBack: _goBack),
                  const SizedBox(height: 20),
                  if (desktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 330, child: _SecurityGuide()),
                        const SizedBox(width: 20),
                        Expanded(child: _buildForm()),
                      ],
                    )
                  else ...[
                    const _SecurityGuide(compact: true),
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
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Perbarui kata sandi', style: _text(18, FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Konfirmasi kata sandi lama sebelum membuat yang baru.',
              style: _text(12, FontWeight.w400, AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _field(
              index: 0,
              controller: _current,
              label: 'Kata sandi saat ini',
              hint: 'Masukkan kata sandi saat ini',
              validator: (value) => value?.trim().isEmpty ?? true
                  ? 'Kata sandi saat ini wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            _field(
              index: 1,
              controller: _password,
              label: 'Kata sandi baru',
              hint: 'Minimal 6 karakter',
              validator: (value) {
                final password = value?.trim() ?? '';
                if (password.isEmpty) return 'Kata sandi baru wajib diisi';
                if (password.length < 6) return 'Gunakan minimal 6 karakter';
                if (password == _current.text.trim()) {
                  return 'Kata sandi baru harus berbeda';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _PasswordStrength(password: _password.text),
            const SizedBox(height: 16),
            _field(
              index: 2,
              controller: _confirmation,
              label: 'Konfirmasi kata sandi baru',
              hint: 'Ulangi kata sandi baru',
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Konfirmasi kata sandi wajib diisi';
                }
                return value!.trim() == _password.text.trim()
                    ? null
                    : 'Konfirmasi kata sandi tidak cocok';
              },
            ),
            const SizedBox(height: 22),
            Obx(
              () => FilledButton.icon(
                onPressed: controller.isLoading.value ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: controller.isLoading.value
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      )
                    : const Icon(Icons.shield_outlined, size: 19),
                label: Text(
                  controller.isLoading.value
                      ? 'Menyimpan perubahan...'
                      : 'Simpan kata sandi baru',
                  style: _text(13, FontWeight.w600, AppColors.surface),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required int index,
    required TextEditingController controller,
    required String label,
    required String hint,
    required FormFieldValidator<String> validator,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return TextFormField(
      controller: controller,
      obscureText: _hidden[index],
      validator: validator,
      autocorrect: false,
      enableSuggestions: false,
      style: _text(13, FontWeight.w400),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: _text(12, FontWeight.w400, AppColors.textSecondary),
        hintStyle: _text(12, FontWeight.w400, AppColors.textLight),
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          tooltip: _hidden[index]
              ? 'Tampilkan kata sandi'
              : 'Sembunyikan kata sandi',
          onPressed: () => setState(() => _hidden[index] = !_hidden[index]),
          icon: Icon(
            _hidden[index]
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = await controller.changePassword(
      _current.text.trim(),
      _password.text.trim(),
    );
    if (updated) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _goBack();
    }
  }

  void _goBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    Get.offAllNamed(changePasswordFallbackRoute(SessionState.role));
  }
}

TextStyle _text(double size, FontWeight weight, [Color? color]) =>
    GoogleFonts.poppins(
      color: color ?? AppColors.textPrimary,
      fontSize: size,
      fontWeight: weight,
    );

class _SecurityHeader extends StatelessWidget {
  const _SecurityHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.lightPrimaryColor.withValues(alpha: 0.30),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keamanan akun', style: _text(22, FontWeight.w700)),
                Text(
                  'Perbarui kata sandi untuk menjaga akun tetap terlindungi.',
                  style: _text(12, FontWeight.w400, AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 620)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.primary,
                    size: 19,
                  ),
                  const SizedBox(width: 7),
                  Text('Akses terlindungi', style: _text(11, FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SecurityGuide extends StatelessWidget {
  const _SecurityGuide({this.compact = false});
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
              color: AppColors.surface.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppColors.surface,
              size: 26,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Buat kata sandi yang kuat',
            style: _text(17, FontWeight.w700, AppColors.surface),
          ),
          const SizedBox(height: 8),
          Text(
            'Hindari nama, tanggal lahir, atau kata sandi yang digunakan di layanan lain.',
            style: GoogleFonts.poppins(
              color: AppColors.surface.withValues(alpha: 0.78),
              fontSize: 12,
              height: 1.6,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 24),
            for (final point in const [
              'Minimal 6 karakter',
              'Gabungkan huruf dan angka',
              'Jangan bagikan kepada siapa pun',
            ]) ...[
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.surface,
                    size: 17,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      point,
                      style: _text(11, FontWeight.w500, AppColors.surface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final score = <bool>[
      password.length >= 6,
      RegExp('[A-Za-z]').hasMatch(password),
      RegExp('[0-9]').hasMatch(password),
    ].where((valid) => valid).length;
    final color = score == 3
        ? AppColors.success
        : score == 2
        ? AppColors.yellow2Color
        : AppColors.border;
    final label = score == 3
        ? 'Kuat'
        : score == 2
        ? 'Cukup'
        : 'Belum memenuhi';
    return Row(
      children: [
        for (var index = 0; index < 3; index++)
          Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
              decoration: BoxDecoration(
                color: index < score ? color : AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Text(
          label,
          style: _text(
            10,
            FontWeight.w600,
            score == 0 ? AppColors.textSecondary : color,
          ),
        ),
      ],
    );
  }
}
