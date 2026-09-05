import 'package:cermatify/app/data/models/mentor_model.dart';
import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import 'package:cermatify/app/data/widgets/responsive_content.dart';
import 'package:cermatify/app/data/widgets/workspace_page_header.dart';
import 'package:cermatify/app/modules/chat/controllers/chat_controller.dart';
import 'package:cermatify/app/modules/order/controllers/order_history_controller.dart';
import 'package:cermatify/app/modules/order/views/order_dialog_view.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

int mentorDetailColumnCount(double width) => width >= 880 ? 2 : 1;

class DetailMentorView extends StatefulWidget {
  const DetailMentorView({
    super.key,
    required this.mentor,
    this.layananId,
    this.layananPrice,
    this.layananType,
  });

  final Mentor mentor;
  final String? layananId;
  final int? layananPrice;
  final String? layananType;

  @override
  State<DetailMentorView> createState() => _DetailMentorViewState();
}

class _DetailMentorViewState extends State<DetailMentorView> {
  bool _openingService = false;

  Mentor get mentor => widget.mentor;

  void _goBack() => Navigator.of(context).pop();

  Future<void> _openLinkedIn(String value) async {
    final normalized =
        value.startsWith('http://') || value.startsWith('https://')
        ? value
        : 'https://$value';
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Tautan tidak dapat dibuka',
        'Periksa kembali alamat LinkedIn mentor.',
      );
    }
  }

  Future<void> _handlePrimaryAction() async {
    if (_openingService) return;
    setState(() => _openingService = true);
    try {
      var serviceType = widget.layananType;
      if ((serviceType == null || serviceType.isEmpty) &&
          widget.layananId?.isNotEmpty == true) {
        try {
          final document = await FirebaseFirestore.instance
              .collection('layanan')
              .doc(widget.layananId)
              .get();
          serviceType = document.data()?['type']?.toString();
        } catch (error) {
          AppLogger.info('Error fetching layanan type: $error');
        }
      }

      final history = Get.isRegistered<OrderHistoryController>()
          ? Get.find<OrderHistoryController>()
          : OrderHistoryController(autoLoad: false);
      final hasProgress = await history.hasProgressOrder(
        mentor.id,
        layananType: serviceType,
      );
      if (hasProgress) {
        final orderId = await history.getProgressOrderId(
          mentor.id,
          layananType: serviceType,
        );
        final chat = Get.isRegistered<ChatController>()
            ? Get.find<ChatController>()
            : Get.put(ChatController());
        await chat.createOrGetChatRoom(mentorId: mentor.id, orderId: orderId);
        Get.toNamed(
          Routes.chatRoom(mentor.id),
          arguments: {'orderId': orderId, 'partnerName': mentor.name},
        );
        return;
      }

      final serviceName = mentor.layanan.trim().isEmpty
          ? 'Layanan pendampingan'
          : mentor.layanan.split(',').first.trim();
      await Get.dialog<void>(
        OrderDialogView(
          mentorId: mentor.id,
          mentorName: mentor.name,
          layananId: widget.layananId ?? '',
          layananName: serviceName,
          price: widget.layananPrice ?? 100000,
          layananType: serviceType,
        ),
        barrierDismissible: false,
      );
    } finally {
      if (mounted) setState(() => _openingService = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(mentor.id)
              .get(),
          builder: (context, snapshot) {
            final linkedin =
                snapshot.data?.data()?['linkedin']?.toString() ?? '';
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ResponsiveContent(
                maxWidth: 1120,
                child: Column(
                  children: [
                    WorkspacePageHeader(
                      eyebrow: 'Profil pendamping',
                      title: 'Detail mentor',
                      subtitle:
                          'Kenali pengalaman dan layanan mentor sebelum memulai pendampingan.',
                      onBack: _goBack,
                    ),
                    const SizedBox(height: 16),
                    MentorProfileHero(
                      mentor: mentor,
                      price: widget.layananPrice,
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide =
                            mentorDetailColumnCount(constraints.maxWidth) == 2;
                        final information = _InformationCard(
                          mentor: mentor,
                          linkedin: linkedin,
                          onLinkedIn: _openLinkedIn,
                        );
                        final about = _AboutAndServicesCard(mentor: mentor);
                        if (!wide) {
                          return Column(
                            children: [
                              information,
                              const SizedBox(height: 14),
                              about,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: information),
                            const SizedBox(width: 14),
                            Expanded(child: about),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      key: const Key('mentor-primary-action'),
                      onPressed: _openingService ? null : _handlePrimaryAction,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _openingService
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.surface,
                              ),
                            )
                          : const Icon(Icons.chat_bubble_outline_rounded),
                      label: Text(
                        _openingService
                            ? 'Memeriksa layanan...'
                            : 'Mulai pendampingan',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MentorProfileHero extends StatelessWidget {
  const MentorProfileHero({
    super.key,
    required this.mentor,
    required this.price,
  });

  final Mentor mentor;
  final int? price;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final avatar = CircleAvatar(
          radius: compact ? 42 : 48,
          backgroundColor: AppColors.surface.withValues(alpha: 0.8),
          backgroundImage: mentor.image.isEmpty
              ? null
              : NetworkImage(mentor.image),
          child: mentor.image.isEmpty
              ? const Icon(
                  Icons.person_outline_rounded,
                  size: 40,
                  color: AppColors.primaryColor,
                )
              : null,
        );
        final details = Column(
          crossAxisAlignment: compact
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              mentor.name,
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: compact ? 21 : 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.greenColor,
                  size: 17,
                ),
                const SizedBox(width: 5),
                Text(
                  'Mentor terverifikasi',
                  style: GoogleFonts.poppins(
                    color: AppColors.greenColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: compact ? WrapAlignment.center : WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeroMetric(
                  icon: Icons.star_rounded,
                  value: mentor.rating.toStringAsFixed(1),
                ),
                _HeroMetric(
                  icon: Icons.schedule_rounded,
                  value: '${mentor.totalSessions} sesi',
                ),
                if (price != null)
                  _HeroMetric(
                    icon: Icons.payments_outlined,
                    value: AppFormats.hargaPendek(price!),
                  ),
              ],
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 22 : 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.1),
                AppColors.lightPrimaryColor.withValues(alpha: 0.32),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppColors.lightPrimaryColor.withValues(alpha: 0.32),
            ),
          ),
          child: compact
              ? Column(children: [avatar, const SizedBox(height: 15), details])
              : Row(
                  children: [
                    avatar,
                    const SizedBox(width: 20),
                    Expanded(child: details),
                  ],
                ),
        );
      },
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primaryColor),
          const SizedBox(width: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.mentor,
    required this.linkedin,
    required this.onLinkedIn,
  });

  final Mentor mentor;
  final String linkedin;
  final ValueChanged<String> onLinkedIn;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Informasi akademik',
      icon: Icons.school_outlined,
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.account_balance_outlined,
            label: 'Kampus',
            value: mentor.kampus,
          ),
          _InfoTile(
            icon: Icons.menu_book_outlined,
            label: 'Jurusan',
            value: mentor.jurusan,
          ),
          _InfoTile(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: mentor.email,
          ),
          if (linkedin.isNotEmpty)
            _InfoTile(
              icon: Icons.link_rounded,
              label: 'LinkedIn',
              value: linkedin,
              onTap: () => onLinkedIn(linkedin),
            ),
        ],
      ),
    );
  }
}

class _AboutAndServicesCard extends StatelessWidget {
  const _AboutAndServicesCard({required this.mentor});

  final Mentor mentor;

  @override
  Widget build(BuildContext context) {
    final services = mentor.layanan
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return _DetailCard(
      title: 'Tentang dan layanan',
      icon: Icons.design_services_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mentor.bio.trim().isEmpty
                ? 'Mentor ini siap mendampingi kebutuhan akademik Anda.'
                : mentor.bio,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (services.isEmpty ? ['Layanan pendampingan'] : services)
                .map(
                  (service) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.checkoutButtonColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      service,
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 9),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.checkoutButtonColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
                Text(
                  value.trim().isEmpty ? '-' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: onTap == null
                        ? AppColors.textPrimary
                        : AppColors.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.open_in_new_rounded,
              size: 17,
              color: AppColors.primaryColor,
            ),
        ],
      ),
    );
    return onTap == null
        ? content
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: content,
          );
  }
}
