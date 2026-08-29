import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cermatify/app/data/widgets/admin_bottom_navbar.dart';
import 'package:cermatify/app/data/widgets/responsive_navigation_scaffold.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../../admin_home/views/admin_home_view.dart';
import '../../users/views/users_view.dart';
import '../../master_data/views/master_data_view.dart';
import '../../profile/views/profile_view.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ResponsiveNavigationScaffold(
        appBar: _buildAppBar(controller.currentIndex.value),
        body: _buildBody(controller.currentIndex.value),
        selectedIndex: controller.currentIndex.value,
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: Text('Users'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.storage_outlined),
            selectedIcon: Icon(Icons.storage),
            label: Text('Master Data'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: Text('Profile'),
          ),
        ],
        onDestinationSelected: controller.changeTab,
        mobileNavigation: AdminBottomNavbar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
        brandTitle: 'Cermatify',
        brandSubtitle: 'Admin Workspace',
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(int currentIndex) {
    // Hide app bar for Home (index 0), Users (index 1), Master Data (index 2), and Profile (index 3) since they have their own headers
    if (currentIndex == 0 ||
        currentIndex == 1 ||
        currentIndex == 2 ||
        currentIndex == 3) {
      return null;
    }

    return null;
  }

  Widget _buildBody(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return _buildHomeView();
      case 1:
        return _buildUsersView();
      case 2:
        return _buildMasterDataView();
      case 3:
        return _buildProfileView();
      default:
        return _buildHomeView();
    }
  }

  Widget _buildHomeView() {
    return const AdminHomeView();
  }

  Widget _buildUsersView() {
    return const UsersView();
  }

  Widget _buildMasterDataView() {
    return const MasterDataView();
  }

  Widget _buildProfileView() {
    return const ProfileView();
  }
}
