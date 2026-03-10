import '../models/dashboard_models.dart';

abstract class DashboardService {
  Future<DashboardData> fetchDashboardData();
}
