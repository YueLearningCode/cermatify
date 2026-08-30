import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/users_controller.dart';

class MentorDetailView extends StatelessWidget {
  const MentorDetailView({super.key, required this.mentorId});

  final String mentorId;

  @override
  Widget build(BuildContext context) {
    return AdminAccountDetailView(userId: mentorId, isMentor: true);
  }
}

class AdminAccountDetailView extends GetView<UsersController> {
  const AdminAccountDetailView({
    super.key,
    required this.userId,
    required this.isMentor,
  });

  final String userId;
  final bool isMentor;

  Future<void> _launchUrl(String value) async {
    final normalized =
        value.startsWith('http://') || value.startsWith('https://')
        ? value
        : 'https://$value';
    final uri = Uri.tryParse(normalized);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    Get.snackbar(
      'Tautan tidak dapat dibuka',
      'Periksa kembali alamat LinkedIn akun ini.',
      backgroundColor: AppColors.redColor,
      colorText: AppColors.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final source = isMentor ? controller.mentorsList : controller.usersList;
      final account = source.firstWhereOrNull((user) => user.id == userId);

      if (account == null) {
        return _AccountNotFoundView(isMentor: isMentor);
      }

      return FutureBuilder<Map<String, dynamic>?>(
        future: controller.fetchUserFullData(userId),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, viewport) {
                  final basePadding = viewport.maxWidth < 600 ? 16.0 : 28.0;
                  final gutter = viewport.maxWidth > 1236
                      ? (viewport.maxWidth - 1236) / 2
                      : 0.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      basePadding + gutter,
                      18,
                      basePadding + gutter,
                      42,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailToolbar(
                          title: isMentor ? 'Detail mentor' : 'Detail pengguna',
                        ),
                        const SizedBox(height: 18),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const LinearProgressIndicator(minHeight: 2),
                        AdminAccountDetailContent(
                          account: account,
                          data: snapshot.data ?? const {},
                          isMentor: isMentor,
                          isUpdating: controller.isUpdating.value,
                          onToggleVerification: () =>
                              controller.toggleMentorStatus(
                                userId,
                                account.verificationStatus,
                              ),
                          onOpenLinkedin: _launchUrl,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    });
  }
}

class AdminAccountDetailContent extends StatelessWidget {
  const AdminAccountDetailContent({
    super.key,
    required this.account,
    required this.data,
    required this.isMentor,
    required this.isUpdating,
    required this.onToggleVerification,
    required this.onOpenLinkedin,
  });

  final UserData account;
  final Map<String, dynamic> data;
  final bool isMentor;
  final bool isUpdating;
  final VoidCallback onToggleVerification;
  final ValueChanged<String> onOpenLinkedin;

  String _text(String key) => data[key]?.toString().trim() ?? '';

  @override
  Widget build(BuildContext context) {
    final phone = _text('noTelp').isNotEmpty
        ? _text('noTelp')
        : _text('noTelepon');
    final linkedin = _text('linkedin');
    final isVerified = account.verificationStatus == 'verified';
    final services = data['layanan'] is List
        ? List<String>.from(data['layanan'] as List)
        : <String>[];
    final information = <_AccountField>[
      _AccountField(
        icon: Icons.badge_outlined,
        label: 'Tipe akun',
        value: isMentor ? 'Mentor' : 'Pengguna',
      ),
      _AccountField(
        icon: Icons.email_outlined,
        label: 'Email',
        value: account.email,
      ),
      if (phone.isNotEmpty)
        _AccountField(
          icon: Icons.phone_outlined,
          label: 'Nomor telepon',
          value: phone,
        ),
      if (_text('kampus').isNotEmpty)
        _AccountField(
          icon: Icons.account_balance_outlined,
          label: 'Kampus',
          value: _text('kampus'),
        ),
      if (_text('jurusan').isNotEmpty)
        _AccountField(
          icon: Icons.menu_book_outlined,
          label: 'Jurusan',
          value: _text('jurusan'),
        ),
      if (_text('semester').isNotEmpty)
        _AccountField(
          icon: Icons.calendar_month_outlined,
          label: 'Semester',
          value: _text('semester'),
        ),
      if (_text('status').isNotEmpty)
        _AccountField(
          icon: Icons.toggle_on_outlined,
          label: 'Status akun',
          value: _accountStatusLabel(_text('status')),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _AccountHero(
          account: account,
          isMentor: isMentor,
          isVerified: isVerified,
          campus: _text('kampus'),
        ),
        const SizedBox(height: 30),
        const _SectionHeading(
          title: 'Informasi akun',
          subtitle: 'Data identitas yang tersimpan pada akun ini.',
        ),
        const SizedBox(height: 14),
        _ResponsiveFieldGrid(fields: information),
        if (isMentor) ...[
          const SizedBox(height: 30),
          const _SectionHeading(
            title: 'Informasi mentor',
            subtitle: 'Keahlian, layanan, dan profil profesional mentor.',
          ),
          const SizedBox(height: 14),
          _ResponsiveFieldGrid(
            fields: [
              if (_text('mentorRole').isNotEmpty)
                _AccountField(
                  icon: Icons.work_outline_rounded,
                  label: 'Peran mentor',
                  value: _mentorRoleLabel(_text('mentorRole')),
                ),
              if (services.isNotEmpty)
                _AccountField(
                  icon: Icons.category_outlined,
                  label: 'Layanan',
                  value: services.join(', '),
                ),
              if (linkedin.isNotEmpty)
                _AccountField(
                  icon: Icons.link_rounded,
                  label: 'LinkedIn',
                  value: linkedin,
                  accent: const Color(0xFF0A66C2),
                  onTap: () => onOpenLinkedin(linkedin),
                ),
            ],
          ),
          const SizedBox(height: 30),
          _VerificationPanel(
            isVerified: isVerified,
            isUpdating: isUpdating,
            onToggle: onToggleVerification,
          ),
        ],
      ],
    );
  }
}

class _DetailToolbar extends StatelessWidget {
  const _DetailToolbar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: Get.back,
            borderRadius: BorderRadius.circular(12),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.arrow_back_rounded, size: 21),
            ),
          ),
        ),
        const SizedBox(width: 13),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Admin workspace',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero({
    required this.account,
    required this.isMentor,
    required this.isVerified,
    required this.campus,
  });

  final UserData account;
  final bool isMentor;
  final bool isVerified;
  final String campus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.checkoutButtonColor,
            AppColors.lightPrimaryColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.14),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final avatar = _AccountAvatar(account: account, compact: compact);
          final identity = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: compact ? 22 : 27,
                  height: 1.18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                account.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (campus.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  campus,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          );
          final status = _StatusBadge(
            label: isMentor
                ? isVerified
                      ? 'Mentor terverifikasi'
                      : 'Menunggu verifikasi'
                : 'Akun pengguna',
            color: isMentor
                ? isVerified
                      ? AppColors.greenColor
                      : AppColors.yellow2Color
                : AppColors.primaryColor,
            icon: isMentor
                ? isVerified
                      ? Icons.verified_rounded
                      : Icons.schedule_rounded
                : Icons.person_rounded,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(height: 16),
                identity,
                const SizedBox(height: 16),
                status,
              ],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 18),
              Expanded(child: identity),
              const SizedBox(width: 20),
              status,
            ],
          );
        },
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.account, required this.compact});

  final UserData account;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hasImage = account.image != null && account.image!.isNotEmpty;
    final size = compact ? 72.0 : 84.0;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.checkoutButtonColor,
        backgroundImage: hasImage ? NetworkImage(account.image!) : null,
        child: hasImage
            ? null
            : Text(
                account.name.isEmpty ? '?' : account.name[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
      ),
    );
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({required this.fields});

  final List<_AccountField> fields;

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return const _EmptyDetailNotice();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fields.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 88,
          ),
          itemBuilder: (context, index) => fields[index],
        );
      },
    );
  }
}

class _AccountField extends StatelessWidget {
  const _AccountField({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = AppColors.primaryColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: onTap == null ? AppColors.textPrimary : accent,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.open_in_new_rounded, color: accent, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationPanel extends StatelessWidget {
  const _VerificationPanel({
    required this.isVerified,
    required this.isUpdating,
    required this.onToggle,
  });

  final bool isVerified;
  final bool isUpdating;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? AppColors.greenColor : AppColors.yellow2Color;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final message = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status verifikasi mentor',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isVerified
                    ? 'Mentor telah diverifikasi dan dapat menggunakan layanan mentor.'
                    : 'Periksa data mentor sebelum memberikan akses layanan.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
          final button = FilledButton.icon(
            onPressed: isUpdating ? null : onToggle,
            style: FilledButton.styleFrom(
              backgroundColor: isVerified
                  ? AppColors.redColor
                  : AppColors.greenColor,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: isUpdating
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surface,
                    ),
                  )
                : Icon(
                    isVerified
                        ? Icons.schedule_rounded
                        : Icons.verified_rounded,
                    size: 18,
                  ),
            label: Text(
              isVerified ? 'Ubah menjadi pending' : 'Verifikasi mentor',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );

          if (constraints.maxWidth < 680) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [message, const SizedBox(height: 18), button],
            );
          }

          return Row(
            children: [
              Expanded(child: message),
              const SizedBox(width: 24),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EmptyDetailNotice extends StatelessWidget {
  const _EmptyDetailNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Belum ada data tambahan pada akun ini.',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AccountNotFoundView extends StatelessWidget {
  const _AccountNotFoundView({required this.isMentor});

  final bool isMentor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_search_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              isMentor ? 'Mentor tidak ditemukan' : 'Pengguna tidak ditemukan',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

String _mentorRoleLabel(String value) {
  switch (value.toLowerCase()) {
    case 'complink':
      return 'CompLink';
    case 'paperlink':
      return 'PaperLink';
    case 'sourcelink':
      return 'SourceLink';
    default:
      return value;
  }
}

String _accountStatusLabel(String value) {
  switch (value.toLowerCase()) {
    case 'active':
      return 'Aktif';
    case 'inactive':
      return 'Tidak aktif';
    default:
      return value;
  }
}
