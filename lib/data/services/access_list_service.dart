import '../models/access_list_models.dart';

abstract class AccessListService {
  Future<AccessListData> fetchAccessListData({
    required int page,
    required int pageSize,
    required AccessListFilters filters,
  });
}
