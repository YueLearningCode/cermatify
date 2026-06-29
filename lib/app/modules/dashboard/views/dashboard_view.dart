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
    return Obx(() {
      final bool isMentor = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>().isMentor.value
          : false;
      final int chatCount = Get.isRegistered<ChatController>()
          ? Get.find<ChatController>().chatRoomCount.value
          : 0;
      final int navIndex = _navIndexFromPageIndex(
        controller.currentIndex.value,
        isMentor,
      );

      return Scaffold(
        appBar: _buildAppBar(controller.currentIndex.value),
        body: _buildBody(controller.currentIndex.value),
        bottomNavigationBar: BottomNavbar(
          currentIndex: navIndex,
          onTap: (int tapped) =>
              controller.changeTab(_pageIndexFromNavIndex(tapped, isMentor)),
          chatBadgeCount: chatCount,
          hideBeranda: isMentor,
        ),
      );
    });
  }

  int _navIndexFromPageIndex(int pageIndex, bool isMentor) {
    if (!isMentor) return pageIndex;
    return pageIndex == 0 ? 0 : pageIndex - 1;
  }

  int _pageIndexFromNavIndex(int navIndex, bool isMentor) {
    if (!isMentor) return navIndex;
    return navIndex == 0 ? 1 : navIndex + 1;
  }

  PreferredSizeWidget? _buildAppBar(int currentIndex) {
    // Hide app bar for Beranda (index 0), Chat (index 1), Kuesioner (index 2), FAQ (index 3), and Profil (index 4) since they have their own headers
    if (currentIndex == 0 ||
        currentIndex == 1 ||
        currentIndex == 2 ||
        currentIndex == 3 ||
        currentIndex == 4) {
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
        final bool isMentor = Get.isRegistered<HomeController>()
            ? Get.find<HomeController>().isMentor.value
            : false;
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
    final bool isMentor = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().isMentor.value
        : false;
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
