import '../../../data/models/access_detail_models.dart';
import '../../../data/repository/access_detail_repository.dart';
import '../../../data/services/api_access_detail_service.dart';
import '../../../data/services/access_detail_service.dart';
import '../../../data/services/mock_access_detail_service.dart';

class HomeAccessDetailRepository implements AccessDetailRepository {
  HomeAccessDetailRepository({
    AccessDetailService? service,
    AccessDetailService? fallbackService,
  })  : _service = service ?? ApiAccessDetailService(),
        _fallbackService = fallbackService ?? MockAccessDetailService();

  final AccessDetailService _service;
  final AccessDetailService _fallbackService;

  @override
  Future<AccessDetailData> getAccessDetail(int accessId) async {
    try {
      return await _service.fetchAccessDetail(accessId);
    } catch (_) {
      return _fallbackService.fetchAccessDetail(accessId);
    }
  }
}
