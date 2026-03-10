import 'package:flutter/foundation.dart';

import '../../../data/models/dashboard_models.dart';
import '../../../data/repository/dashboard_repository.dart';
import '../data/home_dashboard_repository.dart';

class HomeDashboardController extends ChangeNotifier {
  HomeDashboardController({DashboardRepository? repository})
      : _repository = repository ?? HomeDashboardRepository();

  static DashboardData? _cache;

  final DashboardRepository _repository;

  bool isLoading = true;
  String? errorMessage;
  DashboardData? data;

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      data = _cache;
      errorMessage = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.getDashboardData();
      _cache = data;
    } catch (_) {
      errorMessage = 'No se pudo cargar el dashboard.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
