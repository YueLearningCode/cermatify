import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/models/mentor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_mentor_view.dart';

class ListMentorView extends StatelessWidget {
  final String? kampus;
  final String? jurusan;
  final String? layanan;
  final String? layananId; // Layanan ID from filter
  final int? layananPrice; // Layanan price from filter
  final String? layananType; // Layanan type: 'paperlink' or 'complink'

  const ListMentorView({
    super.key,
    this.kampus,
    this.jurusan,
    this.layanan,
    this.layananId,
    this.layananPrice,
    this.layananType,
  });

  String _toText(dynamic value) {
    if (value == null) return '-';
    if (value is String) return value;
    if (value is List) {
      try {
        return value.whereType<String>().join(', ');
      } catch (_) {
        return value.map((e) => e?.toString() ?? '').join(', ');
      }
    }
    return value.toString();
  }

  Widget _buildFilterBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build Firestore query for mentors with optional filters
    // Trim incoming filters to avoid mismatch due to leading/trailing spaces
    final String? kampusFilter = kampus?.trim();
    final String? jurusanFilter = jurusan?.trim();
    final String? layananFilter = layanan?.trim();

    Query<Map<String, dynamic>> baseQuery = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'mentor');
    // Note: isActive filtering is done client-side to avoid composite index requirements
    if (kampusFilter != null && kampusFilter.isNotEmpty) {
      baseQuery = baseQuery.where('kampus', isEqualTo: kampusFilter);
    }
    if (jurusanFilter != null && jurusanFilter.isNotEmpty) {
      baseQuery = baseQuery.where('jurusan', isEqualTo: jurusanFilter);
    }
    // NOTE:
    // We intentionally do NOT filter 'layanan' at the query level because:
    // - It is stored as an array and requires exact, case-sensitive match via arrayContains
    // - UI-provided labels may have case/spacing differences
    // Instead, we filter by 'layanan' on the client with a case-insensitive contains check.

    return Scaffold(
      appBar: AppBar(
        title: Text("Hasil Mentor", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Badges Section (tampil hanya jika ada filter)
          if ((kampus != null && kampus!.isNotEmpty) ||
              (jurusan != null && jurusan!.isNotEmpty) ||
              (layanan != null && layanan!.isNotEmpty))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(color: AppColors.border.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      "Filter:",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (kampus != null && kampus!.isNotEmpty) _buildFilterBadge(Icons.account_balance_rounded, kampus!),
                    if (kampus != null && kampus!.isNotEmpty) const SizedBox(width: 8),
                    if (jurusan != null && jurusan!.isNotEmpty) _buildFilterBadge(Icons.menu_book_rounded, jurusan!),
                    if (jurusan != null && jurusan!.isNotEmpty) const SizedBox(width: 8),
                    if (layanan != null && layanan!.isNotEmpty) _buildFilterBadge(Icons.school_rounded, layanan!),
                  ],
                ),
              ),
            ),
          // Mentor List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: baseQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Terjadi kesalahan memuat mentor",
                      style: GoogleFonts.poppins(color: AppColors.textSecondary),
                    ),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                final mentors = docs
                    .map((d) {
                      final data = d.data();
                      // Filter to show only verified mentors (verificationStatus == 'verified')
                      final verificationStatus = data['verificationStatus'] as String?;
                      if (verificationStatus != 'verified') return null;

                      return Mentor(
                        id: d.id,
                        name: _toText(data['nama'] ?? data['name'] ?? 'Mentor'),
                        kampus: _toText(data['kampus']),
                        jurusan: _toText(data['jurusan']),
                        layanan: _toText(data['layanan']),
                        image: _toText(data['image']) == '-' ? '' : _toText(data['image']),
                        email: _toText(data['email']) == '-' ? '' : _toText(data['email']),
                        bio: _toText(data['bio']) == '-' ? '' : _toText(data['bio']),
                        rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0,
                        totalSessions: (data['totalSessions'] is num) ? (data['totalSessions'] as num).toInt() : 0,
                      );
                    })
                    .whereType<Mentor>()
                    .toList();

                // Client-side layanan filter (case-insensitive, tolerant to joined strings)
                List<Mentor> filteredMentors = mentors;
                if (layananFilter != null && layananFilter.isNotEmpty) {
                  final String needle = layananFilter.toLowerCase();
                  filteredMentors = mentors.where((m) {
                    final String layananText = (m.layanan).toString().toLowerCase();
                    return layananText.contains(needle);
                  }).toList();
                }

                if (filteredMentors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_outlined, size: 80, color: AppColors.textLight),
                        const SizedBox(height: 16),
                        Text(
                          "Tidak ada mentor ditemukan",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Coba ubah filter pencarian Anda",
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredMentors.length,
                  itemBuilder: (context, index) {
                    final mentor = filteredMentors[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shadowColor: AppColors.border.withOpacity(0.1),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: mentor.image.isNotEmpty ? NetworkImage(mentor.image) : null,
                          child: mentor.image.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                        ),
                        title: Text(mentor.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "${mentor.layanan} - ${mentor.jurusan}\n${mentor.kampus}",
                            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailMentorView(
                                  mentor: mentor,
                                  layananId: layananId,
                                  layananPrice: layananPrice,
                                  layananType: layananType ?? 'paperlink', // Default to paperlink if not provided
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text("Detail", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
