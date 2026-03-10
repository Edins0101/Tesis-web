import '../../../data/models/access_list_models.dart';
import '../../../data/repository/access_list_repository.dart';
import '../../../data/services/api_access_list_service.dart';
import '../../../data/services/access_list_service.dart';
import '../../../data/services/mock_access_list_service.dart';

class HomeAccessListRepository implements AccessListRepository {
  HomeAccessListRepository({
    AccessListService? service,
    AccessListService? fallbackService,
  })  : _service = service ?? ApiAccessListService(),
        _fallbackService = fallbackService ?? MockAccessListService();

  final AccessListService _service;
  final AccessListService _fallbackService;

  @override
  Future<AccessListData> getAccessListData({
    required int page,
    required int pageSize,
    required AccessListFilters filters,
  }) async {
    try {
      return await _service.fetchAccessListData(
        page: page,
        pageSize: pageSize,
        filters: filters,
      );
    } catch (_) {
      return _fallbackService.fetchAccessListData(
        page: page,
        pageSize: pageSize,
        filters: filters,
      );
    }
  }
}
