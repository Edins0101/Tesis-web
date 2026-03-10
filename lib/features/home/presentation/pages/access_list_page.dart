import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../data/models/access_list_models.dart';
import '../../logic/access_list_controller.dart';
import '../widgets/access_list_filter_panel.dart';
import '../widgets/access_records_table.dart';
import '../widgets/app_screen_layout.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart' show SidebarDestination;

class AccessListPage extends StatefulWidget {
  const AccessListPage({super.key});

  @override
  State<AccessListPage> createState() => _AccessListPageState();
}

class _AccessListPageState extends State<AccessListPage> {
  late final AccessListController _controller;

  void _onSidebarSelected(SidebarDestination destination) {
    if (destination == SidebarDestination.dashboard) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    }
  }

  void _onViewRecord(AccessRecord record) {
    Navigator.pushNamed(
      context,
      AppRoutes.accessDetail,
      arguments: record.id,
    );
  }

  Future<void> _onSearchFilters(AccessListFilters filters) async {
    await _controller.applyFilters(filters);
  }

  Future<void> _onClearFilters() async {
    await _controller.clearFilters();
  }

  @override
  void initState() {
    super.initState();
    _controller = AccessListController()..load();
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

            final accessData = _controller.data;
            if (accessData == null) {
              return const SizedBox.shrink();
            }

            return AppScreenLayout(
              selectedDestination: SidebarDestination.accessList,
              onSidebarSelected: _onSidebarSelected,
              content: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 1100;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(compact ? 12 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const DashboardHeader(
                          title: 'Listado',
                          subtitle: 'Registro de Accesos',
                        ),
                        const SizedBox(height: 18),
                        AccessListFilterPanel(
                          initialFilters: _controller.filters,
                          compact: compact,
                          onSearch: _onSearchFilters,
                          onClear: _onClearFilters,
                        ),
                        const SizedBox(height: 18),
                        AccessRecordsTable(
                          records: _controller.currentRecords,
                          currentPage: _controller.currentPage,
                          totalPages: _controller.totalPages,
                          totalRecords: _controller.totalRecords,
                          onPageChanged: _controller.goToPage,
                          onViewRecord: _onViewRecord,
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
