import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/users_controller.dart';
import '../../../routes/app_pages.dart';

int adminUsersColumnCount(double width) {
  if (width >= 1080) return 3;
  if (width >= 680) return 2;
  return 1;
}

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final basePadding = constraints.maxWidth < 600 ? 16.0 : 28.0;
            final centeredGutter = constraints.maxWidth > 1336
                ? (constraints.maxWidth - 1336) / 2
                : 0.0;
            final horizontalPadding = basePadding + centeredGutter;

            return Obx(() {
              final isMentor = controller.selectedTab.value == 1;
              final source = isMentor
                  ? controller.mentorsList
                  : controller.usersList;
              final visibleUsers = isMentor
                  ? controller.filteredMentors
                  : controller.filteredUsers;

              return CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      8,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1280),
                          child: _UsersHeader(
                            usersCount: controller.usersList.length,
                            mentorsCount: controller.mentorsList.length,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      16,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1280),
                          child: _UsersToolbar(
                            selectedTab: controller.selectedTab.value,
                            visibleCount: visibleUsers.length,
                            totalCount: source.length,
                            onTabChanged: controller.changeTab,
                            onSearchChanged: controller.updateSearchQuery,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (controller.isLoading.value)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (visibleUsers.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyUsersState(
                        isMentor: isMentor,
                        hasSearch: controller.searchQuery.value.isNotEmpty,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        constraints.maxWidth < 600 ? 108 : 32,
                      ),
                      sliver: SliverLayoutBuilder(
                        builder: (context, sliverConstraints) {
                          final contentWidth = sliverConstraints.crossAxisExtent
                              .clamp(0.0, 1280.0);
                          final columns = adminUsersColumnCount(contentWidth);

                          return SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  mainAxisExtent: isMentor ? 126 : 112,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => AdminUserCard(
                                user: visibleUsers[index],
                                isMentor: isMentor,
                                isUpdating: controller.isUpdating.value,
                                onOpen: () => Get.toNamed(
                                  isMentor
                                      ? Routes.adminMentorDetail(
                                          visibleUsers[index].id,
                                        )
                                      : Routes.adminUserDetail(
                                          visibleUsers[index].id,
                                        ),
                                ),
                                onToggleMentor: () =>
                                    controller.toggleMentorStatus(
                                      visibleUsers[index].id,
                                      visibleUsers[index].verificationStatus,
                                    ),
                              ),
                              childCount: visibleUsers.length,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            });
          },
        ),
      ),
    );
  }
}

class _UsersHeader extends StatelessWidget {
  const _UsersHeader({required this.usersCount, required this.mentorsCount});

  final int usersCount;
  final int mentorsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.checkoutButtonColor,
            AppColors.lightPrimaryColor.withValues(alpha: 0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.14),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTag(label: 'USER MANAGEMENT'),
              const SizedBox(height: 12),
              Text(
                'Kelola pengguna Cermatify',
                style: GoogleFonts.poppins(
                  fontSize: compact ? 23 : 28,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Pantau akun pengguna dan verifikasi mentor dari satu tempat.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
          final counts = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CountPill(
                icon: Icons.people_outline_rounded,
                label: '$usersCount pengguna',
              ),
              _CountPill(
                icon: Icons.school_outlined,
                label: '$mentorsCount mentor',
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 18), counts],
            );
          }

          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 24),
              counts,
            ],
          );
        },
      ),
    );
  }
}

class _UsersToolbar extends StatelessWidget {
  const _UsersToolbar({
    required this.selectedTab,
    required this.visibleCount,
    required this.totalCount,
    required this.onTabChanged,
    required this.onSearchChanged,
  });

  final int selectedTab;
  final int visibleCount;
  final int totalCount;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final tabs = Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Pengguna',
                  icon: Icons.people_outline_rounded,
                  isSelected: selectedTab == 0,
                  onTap: () => onTabChanged(0),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'Mentor',
                  icon: Icons.school_outlined,
                  isSelected: selectedTab == 1,
                  onTap: () => onTabChanged(1),
                ),
              ),
            ],
          ),
        );
        final search = TextField(
          onChanged: onSearchChanged,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Cari nama atau email...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(Icons.search_rounded, size: 21),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
          ),
        );
        final result = Text(
          visibleCount == totalCount
              ? '$totalCount akun'
              : '$visibleCount dari $totalCount akun',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tabs,
              const SizedBox(height: 12),
              search,
              const SizedBox(height: 10),
              result,
            ],
          );
        }

        return Row(
          children: [
            SizedBox(width: 330, child: tabs),
            const SizedBox(width: 14),
            Expanded(child: search),
            const SizedBox(width: 18),
            result,
          ],
        );
      },
    );
  }
}

class AdminUserCard extends StatelessWidget {
  const AdminUserCard({
    super.key,
    required this.user,
    required this.isMentor,
    required this.isUpdating,
    required this.onToggleMentor,
    this.onOpen,
  });

  final UserData user;
  final bool isMentor;
  final bool isUpdating;
  final VoidCallback onToggleMentor;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final isVerified = user.verificationStatus == 'verified';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _UserAvatar(user: user),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RoleBadge(isMentor: isMentor, isVerified: isVerified),
                  ],
                ),
              ),
              if (isMentor) ...[
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: isVerified,
                  onChanged: isUpdating ? null : (_) => onToggleMentor(),
                  activeTrackColor: AppColors.greenColor,
                ),
              ] else
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user});

  final UserData user;

  @override
  Widget build(BuildContext context) {
    final hasImage = user.image != null && user.image!.isNotEmpty;
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.checkoutButtonColor,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.18),
        ),
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.checkoutButtonColor,
        backgroundImage: hasImage ? NetworkImage(user.image!) : null,
        child: hasImage
            ? null
            : Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.isMentor, required this.isVerified});

  final bool isMentor;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final color = !isMentor
        ? AppColors.primaryColor
        : isVerified
        ? AppColors.greenColor
        : AppColors.yellow2Color;
    final label = !isMentor
        ? 'Pengguna'
        : isVerified
        ? 'Terverifikasi'
        : 'Menunggu verifikasi';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.surface : AppColors.textSecondary,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTag extends StatelessWidget {
  const _SectionTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: AppColors.primaryColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.primaryColor),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyUsersState extends StatelessWidget {
  const _EmptyUsersState({required this.isMentor, required this.hasSearch});

  final bool isMentor;
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off_rounded : Icons.people_outline,
              size: 52,
              color: AppColors.textSecondary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 14),
            Text(
              hasSearch
                  ? 'Akun tidak ditemukan'
                  : isMentor
                  ? 'Belum ada mentor'
                  : 'Belum ada pengguna',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
