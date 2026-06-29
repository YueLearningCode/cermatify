import 'package:flutter/material.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:cermatify/app/data/utils/responsive.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int chatBadgeCount;
  final bool hideBeranda;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.chatBadgeCount = 0,
    this.hideBeranda = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 24 : 0,
          0,
          isDesktop ? 24 : 0,
          isDesktop ? 16 : 0,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 760 : double.infinity,
            ),
            child: Container(
              height: 85, // Optimal height untuk bottom navigation
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(28.0),
                  topRight: const Radius.circular(28.0),
                  bottomLeft: Radius.circular(isDesktop ? 28.0 : 0),
                  bottomRight: Radius.circular(isDesktop ? 28.0 : 0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    spreadRadius: 0,
                    blurRadius: 40,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(28.0),
                  topRight: const Radius.circular(28.0),
                  bottomLeft: Radius.circular(isDesktop ? 28.0 : 0),
                  bottomRight: Radius.circular(isDesktop ? 28.0 : 0),
                ),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: onTap,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: AppColors.primaryColor,
                  unselectedItemColor: AppColors.greyTextSecondaryColor
                      .withValues(alpha: 0.6),
                  showUnselectedLabels: true,
                  elevation: 0,
                  selectedFontSize: 12,
                  unselectedFontSize: 11,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  items: hideBeranda
                      ? [
                          _buildNavBarItem(
                            Icons.chat_bubble_outline,
                            Icons.chat_bubble,
                            "Chat",
                            0,
                            showBadge: chatBadgeCount > 0,
                          ),
                          _buildNavBarItem(
                            Icons.assignment_outlined,
                            Icons.assignment,
                            "Kuesioner",
                            1,
                          ),
                          _buildNavBarItem(
                            Icons.help_outline,
                            Icons.help,
                            "FAQ",
                            2,
                          ),
                          _buildNavBarItem(
                            Icons.person_outlined,
                            Icons.person,
                            "Profil",
                            3,
                          ),
                        ]
                      : [
                          _buildNavBarItem(
                            Icons.home_outlined,
                            Icons.home,
                            "Beranda",
                            0,
                          ),
                          _buildNavBarItem(
                            Icons.chat_bubble_outline,
                            Icons.chat_bubble,
                            "Chat",
                            1,
                            showBadge: chatBadgeCount > 0,
                          ),
                          _buildNavBarItem(
                            Icons.assignment_outlined,
                            Icons.assignment,
                            "Kuesioner",
                            2,
                          ),
                          _buildNavBarItem(
                            Icons.help_outline,
                            Icons.help,
                            "FAQ",
                            3,
                          ),
                          _buildNavBarItem(
                            Icons.person_outlined,
                            Icons.person,
                            "Profil",
                            4,
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index, {
    bool showBadge = false,
  }) {
    final bool isSelected = currentIndex == index;

    return BottomNavigationBarItem(
      icon: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          border: isSelected
              ? Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelected ? filledIcon : outlinedIcon,
                size: 24,
                key: ValueKey<bool>(isSelected),
              ),
            ),
            if (showBadge && !isSelected)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    chatBadgeCount > 99 ? '99+' : chatBadgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      label: label,
    );
  }
}
