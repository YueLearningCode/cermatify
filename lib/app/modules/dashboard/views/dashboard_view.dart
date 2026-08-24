import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cermatify/app/data/widgets/bottom_navbar.dart';
import 'package:cermatify/app/data/widgets/responsive_navigation_scaffold.dart';
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
      final int currentIndex = controller.currentIndex.value;
      final int navIndex = isMentor
          ? (currentIndex == 0 ? 0 : currentIndex - 1)
          : currentIndex;

      void changeNavigationTab(int tapped) {
        if (isMentor) {
          controller.changeTab(tapped == 0 ? 1 : tapped + 1);
        } else {
          controller.changeTab(tapped);
        }
      }

      return ResponsiveNavigationScaffold(
        appBar: _buildAppBar(currentIndex),
        body: _buildBody(currentIndex),
        selectedIndex: navIndex,
        destinations: _buildDesktopDestinations(
          hideBeranda: isMentor,
          chatCount: chatCount,
        ),
        onDestinationSelected: changeNavigationTab,
        mobileNavigation: BottomNavbar(
          currentIndex: navIndex,
          onTap: changeNavigationTab,
          chatBadgeCount: chatCount,
          hideBeranda: isMentor,
        ),
      );
    });
  }

  List<NavigationRailDestination> _buildDesktopDestinations({
    required bool hideBeranda,
    required int chatCount,
  }) {
    final chatDestination = NavigationRailDestination(
      icon: Badge(
        isLabelVisible: chatCount > 0,
        label: Text(chatCount > 99 ? '99+' : '$chatCount'),
        child: const Icon(Icons.chat_bubble_outline),
      ),
      selectedIcon: const Icon(Icons.chat_bubble),
      label: const Text('Chat'),
    );

    return [
      if (!hideBeranda)
        const NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Beranda'),
        ),
      chatDestination,
      const NavigationRailDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: Text('Kuesioner'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.help_outline),
        selectedIcon: Icon(Icons.help),
        label: Text('FAQ'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outlined),
        selectedIcon: Icon(Icons.person),
        label: Text('Profil'),
      ),
    ];
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
