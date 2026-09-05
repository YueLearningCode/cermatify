import 'dart:typed_data';

import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentQrCard extends StatelessWidget {
  const PaymentQrCard({
    super.key,
    required this.amount,
    required this.serviceName,
    this.partnerName,
  });

  final int amount;
  final String serviceName;
  final String? partnerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ringkasan pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Layanan', value: serviceName),
          if (partnerName?.isNotEmpty == true) ...[
            const SizedBox(height: 7),
            _SummaryRow(label: 'Mentor', value: partnerName!),
          ],
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ColoredBox(
              color: AppColors.surface,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 210),
                child: AspectRatio(
                  aspectRatio: 1.35,
                  child: Image.asset(
                    'assets/images/qrqris.jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                AppFormats.hargaPendek(amount),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentProofPanel extends StatelessWidget {
  const PaymentProofPanel({
    super.key,
    required this.bytes,
    required this.onGallery,
    required this.onRemove,
    this.onCamera,
  });

  final Uint8List? bytes;
  final VoidCallback onGallery;
  final VoidCallback onRemove;
  final VoidCallback? onCamera;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bukti pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Unggah tangkapan layar transaksi agar order dapat diverifikasi.',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 10,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 190,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: bytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.checkoutButtonColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Belum ada bukti dipilih',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                : Image.memory(
                    bytes!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onCamera != null)
                OutlinedButton.icon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.camera_alt_outlined, size: 17),
                  label: const Text('Kamera'),
                ),
              OutlinedButton.icon(
                onPressed: onGallery,
                icon: Icon(
                  bytes == null
                      ? Icons.photo_library_outlined
                      : Icons.swap_horiz_rounded,
                  size: 17,
                ),
                label: Text(bytes == null ? 'Pilih galeri' : 'Ganti bukti'),
              ),
              if (bytes != null)
                TextButton.icon(
                  onPressed: onRemove,
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  icon: const Icon(Icons.delete_outline_rounded, size: 17),
                  label: const Text('Hapus'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
