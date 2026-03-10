import 'package:flutter/material.dart';

import '../../../../core/utils/responsive_breakpoints.dart';
import 'dashboard_sidebar.dart';

class AppScreenLayout extends StatelessWidget {
  const AppScreenLayout({
    super.key,
    required this.selectedDestination,
    required this.onSidebarSelected,
    required this.content,
  });

  final SidebarDestination selectedDestination;
  final ValueChanged<SidebarDestination> onSidebarSelected;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = ResponsiveBreakpoints.isCompact(constraints.maxWidth);
        if (compact) {
          return content;
        }

        return Row(
          children: [
            DashboardSidebar(
              selected: selectedDestination,
              onSelected: onSidebarSelected,
            ),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}
