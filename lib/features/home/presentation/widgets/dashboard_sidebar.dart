import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../logic/sidebar_state_controller.dart';

enum SidebarDestination {
  dashboard,
  accessList,
}

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.stateController,
  });

  final SidebarDestination selected;
  final ValueChanged<SidebarDestination> onSelected;
  final SidebarStateController? stateController;

  @override
  Widget build(BuildContext context) {
    final controller = stateController ?? SidebarStateController.instance;

    return MouseRegion(
      onEnter: (_) => controller.setHoverExpanded(true),
      onExit: (_) => controller.setHoverExpanded(false),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final isOpen = controller.isOpen;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: isOpen ? 220 : 78,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: AppColors.sidebarBorder)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // During width animation, avoid rendering expanded content too early.
                final contentExpanded = constraints.maxWidth >= 160;
                final itemWidth = contentExpanded
                    ? (constraints.maxWidth - 20).clamp(46.0, 190.0)
                    : 46.0;

                return Column(
                  children: [
                    const SizedBox(height: 14),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: contentExpanded ? 14 : 0,
                      ),
                      child: Row(
                        mainAxisAlignment: contentExpanded
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.center,
                        children: [
                          const _SidebarLogo(),
                          if (contentExpanded)
                            IconButton(
                              onPressed: controller.togglePin,
                              icon: Icon(
                                controller.pinned
                                    ? Icons.push_pin_rounded
                                    : Icons.push_pin_outlined,
                                size: 20,
                                color: const Color(0xFF5E7792),
                              ),
                              tooltip: controller.pinned
                                  ? 'Desfijar sidebar'
                                  : 'Fijar sidebar',
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SidebarItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      expanded: contentExpanded,
                      width: itemWidth,
                      selected: selected == SidebarDestination.dashboard,
                      onTap: () => onSelected(SidebarDestination.dashboard),
                    ),
                    _SidebarItem(
                      icon: Icons.list_alt_rounded,
                      label: 'Listado',
                      expanded: contentExpanded,
                      width: itemWidth,
                      selected: selected == SidebarDestination.accessList,
                      onTap: () => onSelected(SidebarDestination.accessList),
                    ),
                    const Spacer(),
                    if (contentExpanded)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextButton.icon(
                          onPressed: controller.togglePin,
                          icon: Icon(
                            controller.pinned
                                ? Icons.keyboard_double_arrow_left
                                : Icons.keyboard_double_arrow_right,
                            size: 18,
                          ),
                          label: Text(
                            controller.pinned ? 'Contraer' : 'Expandir',
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SidebarLogo extends StatelessWidget {
  const _SidebarLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C9E8), Color(0xFF0A7DFF)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.shield, color: Colors.white),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool expanded;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: width,
        height: 46,
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: expanded ? 14 : 0),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.sidebarSelectedBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment:
              expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  selected ? const Color(0xFF008CA8) : const Color(0xFF8192A6),
            ),
            if (expanded) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF008CA8)
                        : const Color(0xFF425D79),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
