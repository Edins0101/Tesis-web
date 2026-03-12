import 'package:flutter/foundation.dart';

import '../../../data/models/access_list_models.dart';
import '../../../data/models/dashboard_models.dart';
import '../../../data/repository/access_list_repository.dart';
import '../../../data/repository/dashboard_repository.dart';
import '../data/home_access_list_repository.dart';
import '../data/home_dashboard_repository.dart';

class HomeDashboardController extends ChangeNotifier {
  HomeDashboardController({
    DashboardRepository? repository,
    AccessListRepository? accessListRepository,
  })  : _repository = repository ?? HomeDashboardRepository(),
        _accessListRepository =
            accessListRepository ?? HomeAccessListRepository();

  static DashboardData? _cache;
  static List<AccessRecord>? _recentRecordsCache;

  final DashboardRepository _repository;
  final AccessListRepository _accessListRepository;

  bool isLoading = true;
  String? errorMessage;
  DashboardData? data;
  List<AccessRecord> recentRecords = const [];

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null && _recentRecordsCache != null) {
      data = _cache;
      recentRecords = _recentRecordsCache!;
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

      try {
        final recentData = await _accessListRepository.getAccessListData(
          page: 1,
          pageSize: 10,
          filters: AccessListFilters.empty,
        );
        recentRecords = recentData.records.take(10).toList(growable: false);
        _recentRecordsCache = recentRecords;
      } catch (_) {
        recentRecords = _recentRecordsCache ?? const [];
      }
    } catch (_) {
      errorMessage = 'No se pudo cargar el dashboard.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
