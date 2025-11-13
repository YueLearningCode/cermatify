import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_styles.dart';
import 'package:cermatify/app/data/widgets/custom_padding.dart';
import 'package:flutter/material.dart';

/// [CustomItemSetting] adalah widget custom untuk setting
Widget customItemSetting(IconData icon, String title, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      height: 50,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor).rightPadded16(),
            Text(title, style: AppStyles.body1(fontWeight: FontWeight.w300)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 15, color: AppColors.primaryColor),
          ],
        ),
      ),
    ),
  ).bottomPadded2();
}
