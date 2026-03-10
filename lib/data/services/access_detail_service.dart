import '../models/access_detail_models.dart';

abstract class AccessDetailService {
  Future<AccessDetailData> fetchAccessDetail(int accessId);
}
