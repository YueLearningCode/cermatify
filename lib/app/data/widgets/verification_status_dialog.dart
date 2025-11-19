import 'package:flutter/material.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_styles.dart';

/// [VerificationStatusDialog] adalah dialog yang menampilkan status verifikasi dokumen mentor
class VerificationStatusDialog extends StatelessWidget {
  final int progressPercentage;
  final String estimateTime;
  final VoidCallback? onViewDetails;

  const VerificationStatusDialog({
    super.key,
    this.progressPercentage = 80,
    this.estimateTime = '1 - 2 hari',
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: progressPercentage / 100,
                          strokeWidth: 8,
                          backgroundColor: AppColors.redColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.redColor),
                        ),
                      ),
                      // Percentage text
                      Text(
                        '$progressPercentage%',
                        style: AppStyles.headline4(color: AppColors.black414).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Title and Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verifikasi Dokumen',
                        style: AppStyles.headline3(color: AppColors.black414).copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estimasi : $estimateTime',
                        style: AppStyles.body1(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data Anda sedang dalam proses verifikasi dokumen, mohon ditunggu',
                        style: AppStyles.body1(color: AppColors.greyTextSecondaryColor),
                      ),
                    ],
                  ),
                ),
                // Close Button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.greyInactiveColor, shape: BoxShape.circle),
                    child: Icon(Icons.close, size: 20, color: AppColors.greyTextSecondaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Static method to show the dialog
  static void show({
    required BuildContext context,
    int progressPercentage = 80,
    String estimateTime = '1 - 2 hari',
    VoidCallback? onViewDetails,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return VerificationStatusDialog(
          progressPercentage: progressPercentage,
          estimateTime: estimateTime,
          onViewDetails:
              onViewDetails ??
              () {
                Navigator.of(context).pop();
              },
        );
      },
    );
  }
}
