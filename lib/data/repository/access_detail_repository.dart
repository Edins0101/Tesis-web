import '../models/access_detail_models.dart';

abstract class AccessDetailRepository {
  Future<AccessDetailData> getAccessDetail(int accessId);
}
