import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// [CustomCategoryTabs] adalah widget custom untuk tab kategori
class CustomCategoryTabs extends StatefulWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategoryChanged;

  const CustomCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryChanged,
  });

  @override
  State<CustomCategoryTabs> createState() => _CustomCategoryTabsState();
}

class _CustomCategoryTabsState extends State<CustomCategoryTabs> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Set initial state to show the default selected tab
    previousIndex = widget.selectedIndex;
    _animationController.value = 1.0; // Set to completed state initially
  }

  @override
  void didUpdateWidget(CustomCategoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animateSlide(oldWidget.selectedIndex, widget.selectedIndex);
    }
  }

  void _animateSlide(int fromIndex, int toIndex) {
    previousIndex = fromIndex;

    // Determine slide direction and distance
    final distance = (toIndex - fromIndex).abs();
    final isLongDistance = distance > 1;

    if (fromIndex < toIndex) {
      // Sliding from left to right
      _slideAnimation = Tween<Offset>(begin: Offset(-1.0 * (isLongDistance ? 1.2 : 1.0), 0.0), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: isLongDistance ? Curves.easeInOutCubic : Curves.easeInOut,
            ),
          );
    } else {
      // Sliding from right to left
      _slideAnimation = Tween<Offset>(begin: Offset(1.0 * (isLongDistance ? 1.2 : 1.0), 0.0), end: Offset.zero).animate(
        CurvedAnimation(parent: _animationController, curve: isLongDistance ? Curves.easeInOutCubic : Curves.easeInOut),
      );
    }

    // Adjust duration based on distance
    final duration = isLongDistance ? 500 : 400;
    _animationController.duration = Duration(milliseconds: duration);

    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey2Color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final isSelected = index == widget.selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onCategoryChanged(index),
              child: Container(
                margin: EdgeInsets.only(right: index < widget.categories.length - 1 ? 4.0 : 0.0),
                child: Stack(
                  children: [
                    // Background container for all tabs
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        category,
                        textAlign: TextAlign.center,
                        style: AppStyles.body1(color: AppColors.black414, fontWeight: FontWeight.w400),
                      ),
                    ),
                    // Animated selected tab
                    if (isSelected)
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(25.0),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blackColor.withOpacity(0.1),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              category,
                              textAlign: TextAlign.center,
                              style: AppStyles.body1(color: AppColors.black414, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
