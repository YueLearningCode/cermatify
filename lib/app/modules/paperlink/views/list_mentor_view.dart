import 'package:cermatify/app/data/models/mentor_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/widgets/responsive_content.dart';
import 'package:cermatify/app/data/widgets/workspace_page_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'detail_mentor_view.dart';

int mentorResultColumnCount(double width) {
  if (width >= 1080) return 3;
  if (width >= 700) return 2;
  return 1;
}

class ListMentorView extends StatefulWidget {
  const ListMentorView({
    super.key,
    this.kampus,
    this.jurusan,
    this.layanan,
    this.layananId,
    this.layananPrice,
    this.layananType,
  });

  final String? kampus;
  final String? jurusan;
  final String? layanan;
  final String? layananId;
  final int? layananPrice;
  final String? layananType;

  @override
  State<ListMentorView> createState() => _ListMentorViewState();
}

class _ListMentorViewState extends State<ListMentorView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _toText(dynamic value) {
    if (value == null) return '';
    if (value is List) return value.map((item) => '$item').join(', ');
    return value.toString();
  }

  Query<Map<String, dynamic>> get _mentorQuery {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'mentor');
    final kampus = widget.kampus?.trim() ?? '';
    final jurusan = widget.jurusan?.trim() ?? '';
    if (kampus.isNotEmpty) query = query.where('kampus', isEqualTo: kampus);
    if (jurusan.isNotEmpty) query = query.where('jurusan', isEqualTo: jurusan);
    return query;
  }

  void _goBack() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 1280,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                WorkspacePageHeader(
                  eyebrow: 'Mentor terverifikasi',
                  title: 'Pilih mentor',
                  subtitle:
                      'Bandingkan profil mentor dan pilih pendamping yang paling sesuai.',
                  onBack: _goBack,
                ),
                const SizedBox(height: 14),
                _SearchAndFilters(
                  controller: _searchController,
                  filters: [
                    if (widget.kampus?.isNotEmpty == true)
                      (Icons.account_balance_outlined, widget.kampus!),
                    if (widget.jurusan?.isNotEmpty == true)
                      (Icons.menu_book_outlined, widget.jurusan!),
                    if (widget.layanan?.isNotEmpty == true)
                      (Icons.design_services_outlined, widget.layanan!),
                  ],
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                ),
                const SizedBox(height: 14),
                Expanded(child: _buildResults()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _mentorQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        if (snapshot.hasError) {
          return const MentorResultEmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Mentor belum dapat dimuat',
            subtitle: 'Periksa koneksi lalu buka kembali halaman ini.',
          );
        }

        final serviceNeedle = widget.layanan?.trim().toLowerCase() ?? '';
        final mentors = (snapshot.data?.docs ?? const [])
            .where((document) {
              final data = document.data();
              if (data['verificationStatus']?.toString() != 'verified') {
                return false;
              }
              final service = _toText(data['layanan']).toLowerCase();
              if (serviceNeedle.isNotEmpty &&
                  !service.contains(serviceNeedle)) {
                return false;
              }
              final searchable = [
                _toText(data['nama'] ?? data['name']),
                _toText(data['kampus']),
                _toText(data['jurusan']),
                service,
              ].join(' ').toLowerCase();
              return _query.isEmpty || searchable.contains(_query);
            })
            .map((document) {
              final data = document.data();
              return Mentor(
                id: document.id,
                name: _toText(data['nama'] ?? data['name']).trim().isEmpty
                    ? 'Mentor Cermatify'
                    : _toText(data['nama'] ?? data['name']),
                kampus: _toText(data['kampus']),
                jurusan: _toText(data['jurusan']),
                layanan: _toText(data['layanan']),
                image: _toText(data['image']),
                email: _toText(data['email']),
                bio: _toText(data['bio']),
                rating: (data['rating'] as num?)?.toDouble() ?? 0,
                totalSessions: (data['totalSessions'] as num?)?.toInt() ?? 0,
              );
            })
            .toList(growable: false);

        if (mentors.isEmpty) {
          return MentorResultEmptyState(
            icon: _query.isEmpty
                ? Icons.person_search_outlined
                : Icons.search_off_rounded,
            title: _query.isEmpty
                ? 'Belum ada mentor yang sesuai'
                : 'Mentor tidak ditemukan',
            subtitle: _query.isEmpty
                ? 'Kembali dan coba kombinasi filter lainnya.'
                : 'Coba kata kunci nama atau bidang yang berbeda.',
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = mentorResultColumnCount(constraints.maxWidth);
            return GridView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 220,
              ),
              itemCount: mentors.length,
              itemBuilder: (context, index) => MentorResultCard(
                mentor: mentors[index],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DetailMentorView(
                      mentor: mentors[index],
                      layananId: widget.layananId,
                      layananPrice: widget.layananPrice,
                      layananType: widget.layananType ?? 'paperlink',
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.filters,
    required this.onChanged,
  });

  final TextEditingController controller;
  final List<(IconData, String)> filters;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Cari nama atau bidang mentor...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (filters.isNotEmpty) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters
                    .map(
                      (filter) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.checkoutButtonColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filter.$1,
                              size: 14,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              filter.$2,
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MentorResultCard extends StatelessWidget {
  const MentorResultCard({
    super.key,
    required this.mentor,
    required this.onTap,
  });

  final Mentor mentor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.checkoutButtonColor,
                    backgroundImage: mentor.image.isEmpty
                        ? null
                        : NetworkImage(mentor.image),
                    child: mentor.image.isEmpty
                        ? const Icon(
                            Icons.person_outline,
                            color: AppColors.primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mentor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppColors.greenColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Terverifikasi',
                              style: GoogleFonts.poppins(
                                color: AppColors.greenColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _MentorMeta(
                icon: Icons.account_balance_outlined,
                value: mentor.kampus.isEmpty
                    ? 'Kampus belum diisi'
                    : mentor.kampus,
              ),
              const SizedBox(height: 7),
              _MentorMeta(
                icon: Icons.menu_book_outlined,
                value: mentor.jurusan.isEmpty
                    ? 'Jurusan belum diisi'
                    : mentor.jurusan,
              ),
              const Spacer(),
              Text(
                mentor.layanan.isEmpty
                    ? 'Layanan pendampingan'
                    : mentor.layanan,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MentorMeta extends StatelessWidget {
  const _MentorMeta({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textLight),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class MentorResultEmptyState extends StatelessWidget {
  const MentorResultEmptyState({
    super.key,
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
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textLight),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
