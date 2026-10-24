import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewPreviewSection extends StatefulWidget {
  const ReviewPreviewSection({super.key});

  @override
  State<ReviewPreviewSection> createState() => _ReviewPreviewSectionState();
}

class _ReviewPreviewSectionState extends State<ReviewPreviewSection> {
  ScrollPosition? _position;
  bool _visible = false;
  bool _paused = false;
  bool _hovered = false;
  bool _focused = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (_position != position) {
      _position?.removeListener(_updateVisibility);
      _position = position;
      _position?.addListener(_updateVisibility);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibility());
  }

  void _updateVisibility() {
    if (!mounted || !kDebugMode) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final visible =
        top < MediaQuery.sizeOf(context).height && top + box.size.height > 72;
    if (visible != _visible) setState(() => _visible = visible);
  }

  @override
  void dispose() {
    _position?.removeListener(_updateVisibility);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final media = MediaQuery.of(context);
    final reduceMotion = media.disableAnimations || media.accessibleNavigation;
    final animate =
        _visible &&
        !_paused &&
        !_hovered &&
        !_focused &&
        !reduceMotion &&
        TickerMode.valuesOf(context).enabled;

    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Focus(
          canRequestFocus: false,
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pratinjau ulasan',
                style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Contoh desain: seluruh kutipan, rating, nama, dan status di bawah ini fiktif.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              if (!reduceMotion)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _paused = !_paused),
                  icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                  label: Text(_paused ? 'Lanjutkan animasi' : 'Jeda animasi'),
                )
              else
                Text(
                  'Animasi dinonaktifkan. Geser untuk membaca contoh lainnya.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 24)
                      .clamp(220.0, 340.0)
                      .toDouble();
                  return Column(
                    children: [
                      for (var row = 0; row < 2; row++) ...[
                        if (row > 0) const SizedBox(height: 16),
                        _ReviewMarquee(
                          key: ValueKey('review-row-$row'),
                          reviews: _examples.sublist(row * 6, row * 6 + 6),
                          cardWidth: cardWidth,
                          reverse: row == 1,
                          animate: animate,
                          reduceMotion: reduceMotion,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewMarquee extends StatefulWidget {
  const _ReviewMarquee({
    super.key,
    required this.reviews,
    required this.cardWidth,
    required this.reverse,
    required this.animate,
    required this.reduceMotion,
  });

  final List<_ExampleReview> reviews;
  final double cardWidth;
  final bool reverse;
  final bool animate;
  final bool reduceMotion;

  @override
  State<_ReviewMarquee> createState() => _ReviewMarqueeState();
}

class _ReviewMarqueeState extends State<_ReviewMarquee>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    )..addListener(_scroll);
    if (widget.animate) _animation.repeat();
  }

  void _scroll() {
    if (!_scrollController.hasClients ||
        !_scrollController.position.hasContentDimensions) {
      return;
    }
    final cycleWidth = (widget.cardWidth + 16) * widget.reviews.length;
    final fraction = widget.reverse ? 1 - _animation.value : _animation.value;
    _scrollController.jumpTo(
      (cycleWidth * fraction)
          .clamp(0.0, _scrollController.position.maxScrollExtent)
          .toDouble(),
    );
  }

  @override
  void didUpdateWidget(covariant _ReviewMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _animation.repeat();
      } else {
        _animation.stop();
      }
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: widget.animate
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var copy = 0; copy < (widget.reduceMotion ? 1 : 2); copy++)
            ExcludeSemantics(
              excluding: copy > 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final review in widget.reviews)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: widget.cardWidth,
                        child: _ExampleReviewCard(review: review),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExampleReviewCard extends StatelessWidget {
  const _ExampleReviewCard({required this.review});

  final _ExampleReview review;

  @override
  Widget build(BuildContext context) {
    final score = review.rating
        .toString()
        .replaceFirst(RegExp(r'\.0$'), '')
        .replaceFirst('.', ',');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contoh fiktif',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ExcludeSemantics(
                child: Row(
                  children: [
                    for (var i = 0; i < 5; i++)
                      Icon(
                        review.rating >= i + 1
                            ? Icons.star_rounded
                            : review.rating >= i + 0.5
                            ? Icons.star_half_rounded
                            : Icons.star_border_rounded,
                        size: 18,
                        color: AppColors.orange2Color,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$score/5',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            review.quote,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.65,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            review.name,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            review.role,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleReview {
  const _ExampleReview(
    this.quote,
    this.rating,
    this.name, {
    this.role = 'Mahasiswa',
  });

  final String quote;
  final double rating;
  final String name;
  final String role;
}

// Fictional examples supplied by the owner for development previews only.
const _examples = [
  _ExampleReview(
    'Cermatify membantu saya menyusun persiapan lomba dengan lebih terarah. Masukan mentornya membuat saya tahu bagian yang perlu diperbaiki.',
    4.5,
    'Aditya Pratama',
  ),
  _ExampleReview(
    'Awalnya saya bingung menentukan topik penelitian. Setelah berdiskusi, saya lebih memahami cara mempersempit topik sesuai kemampuan saya.',
    5,
    'Nabila Putri',
  ),
  _ExampleReview(
    'Penjelasan mentornya mudah dipahami. Saya bisa bertanya tentang materi yang belum saya kuasai tanpa merasa sungkan.',
    4.5,
    'Fajar Ramadhan',
  ),
  _ExampleReview(
    'Saya terbantu saat menyusun langkah awal penelitian. Akan lebih nyaman kalau pilihan jadwal mentornya semakin banyak.',
    4,
    'Alya Safitri',
  ),
  _ExampleReview(
    'Diskusinya membantu saya memahami metode penelitian, jadi saya lebih percaya diri menjelaskan alasan pemilihan metode kepada dosen.',
    5,
    'Rizky Maulana',
  ),
  _ExampleReview(
    'Umpan balik untuk presentasi saya cukup jelas dan bisa langsung saya praktikkan. Persiapan presentasi jadi lebih teratur.',
    4.5,
    'Dinda Maharani',
  ),
  _ExampleReview(
    'Saya suka karena mendapat arahan untuk memperbaiki pekerjaan sendiri. Pembahasannya membantu saya memahami kesalahan saya.',
    5,
    'Bagas Firmansyah',
  ),
  _ExampleReview(
    'Informasi layanan membantu saya memilih pendampingan sesuai kebutuhan. Beberapa istilah masih perlu dijelaskan lebih sederhana.',
    4,
    'Salma Azzahra',
  ),
  _ExampleReview(
    'Sebagai mentor, informasi kebutuhan mahasiswa sebelum sesi membantu saya menyiapkan pembahasan yang lebih relevan.',
    4.5,
    'Ardi Wicaksana',
    role: 'Mentor Akademik',
  ),
  _ExampleReview(
    'Pendampingannya membantu saya mengevaluasi struktur proposal. Saya jadi tahu bagian mana yang perlu diperjelas sebelum konsultasi berikutnya.',
    5,
    'Intan Permata',
  ),
  _ExampleReview(
    'Cermatify membantu saya membagi target belajar menjadi langkah yang lebih kecil. Saya jadi lebih mudah menentukan prioritas.',
    4.5,
    'Yoga Saputra',
  ),
  _ExampleReview(
    'Sesi diskusinya bermanfaat untuk memahami konsep yang sebelumnya membingungkan. Semoga pilihan bidang mentornya terus bertambah.',
    4,
    'Kirana Larasati',
  ),
];
