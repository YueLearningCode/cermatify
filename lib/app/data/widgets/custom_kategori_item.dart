// ignore_for_file: deprecated_member_use

import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/theme/app_styles.dart';
import 'package:cermatify/app/data/widgets/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// [CustomKategoriItem] adalah widget custom untuk item kategori
class CustomKategoriItem extends StatelessWidget {
  final String foto;
  final String judul;
  final VoidCallback onTap;
  const CustomKategoriItem({super.key, required this.foto, required this.judul, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 100,
            height: 85,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryColor),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(foto, width: 24, height: 24, color: AppColors.whiteColor).bottomPadded6(),
                  Text(
                    judul,
                    textAlign: TextAlign.center,
                    style: AppStyles.body1(color: AppColors.whiteColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).topPadded12();
  }
}
