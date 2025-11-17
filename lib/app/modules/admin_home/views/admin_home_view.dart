import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../controllers/admin_home_controller.dart';
import '../../admin_dashboard/controllers/admin_dashboard_controller.dart';
import '../../admin_orders/views/admin_orders_view.dart';
import '../../admin_orders/bindings/admin_orders_binding.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
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
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Admin Dashboard",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
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
                              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.surface,
                              backgroundImage: controller.userImage.value.isNotEmpty
                                  ? NetworkImage(controller.userImage.value) as ImageProvider
                                  : const AssetImage('assets/images/profile_dummy.jpg'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Statistics Cards
                    Text(
                      "Statistics",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: "Jumlah Users",
                            value: controller.totalUsers.value.toString(),
                            icon: Icons.people_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: "Master Data",
                            value: controller.totalMasterData.value.toString(),
                            icon: Icons.storage_outlined,
                            color: AppColors.greenColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: "Aktif",
                            value: "100%",
                            icon: Icons.check_circle_outline,
                            color: AppColors.greenColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: "System",
                            value: "Online",
                            icon: Icons.cloud_done_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Quick Actions
                    Text(
                      "Quick Actions",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      padding: EdgeInsets.zero,
                      children: [
                        _buildActionCard(
                          title: "Manage Users",
                          subtitle: "Lihat & Edit",
                          icon: Icons.people_rounded,
                          color: AppColors.primary,
                          onTap: () {
                            // Navigate to Users tab in admin dashboard
                            if (Get.isRegistered<AdminDashboardController>()) {
                              Get.find<AdminDashboardController>().changeTab(1);
                            }
                          },
                        ),
                        _buildActionCard(
                          title: "Master Data",
                          subtitle: "Lihat & Edit",
                          icon: Icons.storage_rounded,
                          color: AppColors.greenColor,
                          onTap: () {
                            // Navigate to Master Data tab in admin dashboard
                            if (Get.isRegistered<AdminDashboardController>()) {
                              Get.find<AdminDashboardController>().changeTab(2);
                            }
                          },
                        ),
                        _buildActionCard(
                          title: "Orders",
                          subtitle: "Mengelola Order",
                          icon: Icons.shopping_bag_rounded,
                          color: AppColors.orangeColor,
                          onTap: () {
                            // Navigate to Orders view with binding
                            Get.to(() => const AdminOrdersView(), binding: AdminOrdersBinding());
                          },
                        ),
                        // _buildActionCard(
                        //   title: "Settings",
                        //   subtitle: "App Config",
                        //   icon: Icons.settings_rounded,
                        //   color: AppColors.orangeColor,
                        //   onTap: () {
                        //     Get.snackbar(
                        //       "Coming Soon",
                        //       "Settings feature will be available soon",
                        //       backgroundColor: AppColors.primary,
                        //       colorText: AppColors.surface,
                        //       snackPosition: SnackPosition.BOTTOM,
                        //     );
                        //   },
                        // ),
                        // _buildActionCard(
                        //   title: "Reports",
                        //   subtitle: "View Reports",
                        //   icon: Icons.assessment_rounded,
                        //   color: AppColors.primaryDark,
                        //   onTap: () {
                        //     Get.snackbar(
                        //       "Coming Soon",
                        //       "Reports feature will be available soon",
                        //       backgroundColor: AppColors.primary,
                        //       colorText: AppColors.surface,
                        //       snackPosition: SnackPosition.BOTTOM,
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.surface.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(icon, color: AppColors.surface, size: 26),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.surface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.surface.withOpacity(0.8),
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
