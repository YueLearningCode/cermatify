import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/routes/app_pages.dart';

import 'kuesioner_detail_view.dart';

class KuesionerDetailRouteView extends StatelessWidget {
  const KuesionerDetailRouteView({super.key});

  void _goBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }
    Get.offAllNamed(
      Routes.DASHBOARD,
      arguments: const <String, dynamic>{'initialTab': 2},
    );
  }

  @override
  Widget build(BuildContext context) {
    final argument = Get.arguments;
    if (argument is Kuesioner) {
      return KuesionerDetailView(kuesioner: argument);
    }
    final id = Get.parameters['kuesionerId'] ?? '';
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('kuesioners').doc(id).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.assignment_late_outlined,
                    color: AppColors.textLight,
                    size: 44,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kuesioner tidak ditemukan',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          );
        }
        return KuesionerDetailView(
          kuesioner: Kuesioner.fromJson(snapshot.data!.data()!, id),
        );
      },
    );
  }
}
