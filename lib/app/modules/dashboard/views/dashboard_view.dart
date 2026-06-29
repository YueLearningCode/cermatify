import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cermatify/app/data/widgets/bottom_navbar.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/views/home_view.dart';
import '../../chat/views/chat_list_view.dart';
import '../../profile/views/profile_view.dart';
import '../../kuesioner/views/kuesioner_view.dart';
import '../../faq/views/faq_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: _buildAppBar(controller.currentIndex.value),
        body: _buildBody(controller.currentIndex.value),
        bottomNavigationBar: Obx(() {
          final bool isMentor = Get.isRegistered<HomeController>() ? Get.find<HomeController>().isMentor.value : false;
          final int chatCount = Get.isRegistered<ChatController>() ? Get.find<ChatController>().chatRoomCount.value : 0;
          // Map controller index to nav index when Beranda hidden
          int navIndex = controller.currentIndex.value;
          if (isMentor) {
            navIndex = controller.currentIndex.value == 0 ? 0 : controller.currentIndex.value - 1;
          }
          return BottomNavbar(
            currentIndex: navIndex,
            onTap: (int tapped) {
              if (isMentor) {
                final mapped = tapped == 0 ? 1 : tapped + 1;
                controller.changeTab(mapped);
              } else {
                controller.changeTab(tapped);
              }
            },
            chatBadgeCount: chatCount,
            hideBeranda: isMentor,
          );
        }),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(int currentIndex) {
    // Hide app bar for Beranda (index 0), Chat (index 1), Kuesioner (index 2), FAQ (index 3), and Profil (index 4) since they have their own headers
    if (currentIndex == 0 || currentIndex == 1 || currentIndex == 2 || currentIndex == 3 || currentIndex == 4) {
      return null;
    }

    String title;
    switch (currentIndex) {
      case 2:
        title = 'Kuesioner';
        break;
      case 3:
        title = 'FAQ';
        break;
      case 4:
        title = 'Profil';
        break;
      default:
        return null;
    }

    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildBody(int currentIndex) {
    switch (currentIndex) {
      case 0:
        // If logged-in user is a mentor, skip Beranda and show Chat
        final bool isMentor = Get.isRegistered<HomeController>() ? Get.find<HomeController>().isMentor.value : false;
        return isMentor ? _buildChatView() : _buildBerandaView();
      case 1:
        return _buildChatView();
      case 2:
        return _buildKuesionerView();
      case 3:
        return _buildFAQView();
      case 4:
        return _buildProfilView();
      default:
        return _buildBerandaView();
    }
  }

  Widget _buildBerandaView() {
    final bool isMentor = Get.isRegistered<HomeController>() ? Get.find<HomeController>().isMentor.value : false;
    return isMentor ? const ChatListView() : const HomeContent();
  }

  Widget _buildChatView() {
    return const ChatListView();
  }

  Widget _buildKuesionerView() {
    return const KuesionerView();
  }

  Widget _buildFAQView() {
    return const FaqView();
  }

  Widget _buildProfilView() {
    return const ProfileView();
  }
}
