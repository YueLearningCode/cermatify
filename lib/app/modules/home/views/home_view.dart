import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cermatify/app/modules/paperlink/views/list_mentor_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/utils/responsive.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../../chat/views/chat_list_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const HomeContent(),
    );
  }
}

class HomeContent extends GetView<HomeController> {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // If current user is a mentor, show chat list only
      if (controller.isMentor.value) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: const ChatListView(embed: false),
        );
      }
      final bool isDesktop = Responsive.isDesktop(context);
      final bool isTablet = Responsive.isTablet(context);
      final int featureColumns = isDesktop ? 4 : (isTablet ? 3 : 2);

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 40 : 16,
          isDesktop ? 40 : 52,
          isDesktop ? 40 : 16,
          24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              "Hai, ${controller.userName.value} 👋",
                              style: GoogleFonts.poppins(
                                fontSize: isDesktop ? 28 : 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Mari tingkatkan kemampuan belajarmu",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.surface,
                          backgroundImage: controller.userImage.value.isNotEmpty
                              ? NetworkImage(controller.userImage.value)
                                    as ImageProvider
                              : const AssetImage(
                                  'assets/images/profile_dummy.jpg',
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // // Search Bar
                // Container(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(14),
                //     boxShadow: [
                //       BoxShadow(color: AppColors.border.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2)),
                //     ],
                //   ),
                //   child: TextField(
                //     readOnly: true,
                //     onTap: () {
                //       // Buka daftar mentor tanpa filter (tampilkan semua mentor)
                //       Get.to(() => const ListMentorView());
                //     },
                //     decoration: InputDecoration(
                //       hintText: "Cari mentor atau topik...",
                //       hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
                //       prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                //       filled: true,
                //       fillColor: AppColors.surface,
                //       contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                //       enabledBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(14),
                //         borderSide: BorderSide.none,
                //       ),
                //       focusedBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(14),
                //         borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 20),
                // Carousel Banner dengan auto slide
                Column(
                  children: [
                    Container(
                      height: isDesktop ? 220 : 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: PageView.builder(
                        controller: controller.pageController,
                        itemCount: controller.bannerImages.length,
                        onPageChanged: controller.onPageChanged,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              image: DecorationImage(
                                image: AssetImage(
                                  controller.bannerImages[index],
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Dot indicators
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.bannerImages.length,
                          (index) {
                            return Container(
                              width: 7,
                              height: 10,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.currentPage.value == index
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Fitur Mentoring",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Feature Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: featureColumns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: isDesktop ? 1.35 : 1.1,
                  padding: EdgeInsets.zero,
                  children: const [
                    FeatureCard(
                      title: "Cermat Paper",
                      subtitle: "Bimbingan Paper",
                      icon: Icons.description_rounded,
                      color: AppColors.primaryLight,
                    ),
                    FeatureCard(
                      title: "Cermat Competition",
                      subtitle: "Kompetisi & Beasiswa",
                      icon: Icons.school_rounded,
                      color: AppColors.primary,
                    ),
                    FeatureCard(
                      title: "Cermat Kuesioner",
                      subtitle: "Sumber Belajar",
                      icon: Icons.library_books_rounded,
                      color: AppColors.primaryDark,
                    ),
                    FeatureCard(
                      title: "Order History",
                      subtitle: "Riwayat Pesanan",
                      icon: Icons.shopping_bag_rounded,
                      color: AppColors.primaryLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (title) {
          case "Cermat Paper":
            Get.toNamed(Routes.PAPERLINK);
            break;
          case "Cermat Competition":
            Get.toNamed(Routes.COMPLINK);
            break;
          case "Cermat Kuesioner":
            Get.toNamed(Routes.SOURCELINK);
            break;
          case "Order History":
            Get.toNamed(Routes.ORDER_HISTORY);
            break;
          default:
            Get.snackbar(
              title,
              "Menu '$title' sedang dalam pengembangan",
              backgroundColor: AppColors.primary,
              colorText: AppColors.surface,
              snackPosition: SnackPosition.BOTTOM,
              borderRadius: 12,
              margin: const EdgeInsets.all(16),
            );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.9), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              switch (title) {
                case "Cermat Paper":
                  Get.toNamed(Routes.PAPERLINK);
                  break;
                case "Cermat Competition":
                  Get.toNamed(Routes.COMPLINK);
                  break;
                case "Cermat Kuesioner":
                  Get.toNamed(Routes.SOURCELINK);
                  break;
                case "Order History":
                  Get.toNamed(Routes.ORDER_HISTORY);
                  break;
                default:
                  Get.snackbar(
                    title,
                    "Menu '$title' sedang dalam pengembangan",
                    backgroundColor: AppColors.primary,
                    colorText: AppColors.surface,
                    snackPosition: SnackPosition.BOTTOM,
                    borderRadius: 12,
                    margin: const EdgeInsets.all(16),
                  );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.surface, size: 26),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.surface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
