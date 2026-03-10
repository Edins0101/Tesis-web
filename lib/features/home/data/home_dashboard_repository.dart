import '../../../data/models/dashboard_models.dart';
import '../../../data/repository/dashboard_repository.dart';
import '../../../data/services/api_dashboard_service.dart';
import '../../../data/services/dashboard_service.dart';
import '../../../data/services/mock_dashboard_service.dart';

class HomeDashboardRepository implements DashboardRepository {
  HomeDashboardRepository({
    DashboardService? service,
    DashboardService? fallbackService,
  })  : _service = service ?? ApiDashboardService(),
        _fallbackService = fallbackService ?? MockDashboardService();

  final DashboardService _service;
  final DashboardService _fallbackService;

  @override
  Future<DashboardData> getDashboardData() async {
    try {
      return await _service.fetchDashboardData();
    } catch (_) {
      return _fallbackService.fetchDashboardData();
    }
  }
}
