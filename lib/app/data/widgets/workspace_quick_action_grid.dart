import 'package:cermatify/app/data/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

int workspaceQuickActionColumnCount(double width, int itemCount) {
  if (width < 640) return 1;
  if (width < 1040) return 2;
  if (itemCount == 4) return 4;
  return 3;
}

double workspaceQuickActionExtent(double width) {
  if (width < 640) return 120;
  if (width < 1040) return 132;
  return 154;
}

class WorkspaceQuickActionData {
  const WorkspaceQuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class WorkspaceQuickActionGrid extends StatelessWidget {
  const WorkspaceQuickActionGrid({super.key, required this.actions});

  final List<WorkspaceQuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: workspaceQuickActionColumnCount(
              constraints.maxWidth,
              actions.length,
            ),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: workspaceQuickActionExtent(constraints.maxWidth),
          ),
          itemBuilder: (context, index) =>
              WorkspaceQuickActionCard(action: actions[index]),
        );
      },
    );
  }
}

class WorkspaceQuickActionCard extends StatelessWidget {
  const WorkspaceQuickActionCard({super.key, required this.action});

  final WorkspaceQuickActionData action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: action.title,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border.withValues(alpha: .85)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: action.onTap,
          hoverColor: action.color.withValues(alpha: .06),
          focusColor: action.color.withValues(alpha: .08),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(action.icon, color: action.color, size: 23),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: action.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
