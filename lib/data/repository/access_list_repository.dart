import '../models/access_list_models.dart';

abstract class AccessListRepository {
  Future<AccessListData> getAccessListData({
    required int page,
    required int pageSize,
    required AccessListFilters filters,
  });
}
