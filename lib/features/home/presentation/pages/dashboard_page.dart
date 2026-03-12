import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../data/models/access_list_models.dart';
import '../../logic/home_dashboard_controller.dart';
import '../widgets/access_records_table.dart';
import '../widgets/app_screen_layout.dart';
import '../widgets/charts.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart' show SidebarDestination;
import '../widgets/kpi_grid.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final HomeDashboardController _controller;

  void _onSidebarSelected(SidebarDestination destination) {
    if (destination == SidebarDestination.accessList) {
      Navigator.pushReplacementNamed(context, AppRoutes.accessList);
    }
  }

  void _onViewRecord(AccessRecord record) {
    Navigator.pushNamed(
      context,
      AppRoutes.accessDetail,
      arguments: record.id,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = HomeDashboardController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_controller.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_controller.errorMessage!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _controller.load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final dashboardData = _controller.data;
            if (dashboardData == null) {
              return const SizedBox.shrink();
            }

            return AppScreenLayout(
              selectedDestination: SidebarDestination.dashboard,
              onSidebarSelected: _onSidebarSelected,
              content: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 1100;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(compact ? 12 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: DashboardHeader(
                            title: 'Dashboard',
                            subtitle: 'Reporteria de Accesos',
                          ),
                        ),
                        const SizedBox(height: 18),
                        KpiGrid(kpis: dashboardData.kpis),
                        const SizedBox(height: 18),
                        BottomCharts(
                          data: dashboardData,
                          compact: compact,
                        ),
                        const SizedBox(height: 18),
                        AccessRecordsTable(
                          title: 'Ultimos ingresos',
                          records: _controller.recentRecords,
                          totalRecords: _controller.recentRecords.length,
                          onViewRecord: _onViewRecord,
                          showPagination: false,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
