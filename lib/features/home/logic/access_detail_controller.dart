import 'package:flutter/foundation.dart';

import '../../../data/models/access_detail_models.dart';
import '../../../data/repository/access_detail_repository.dart';
import '../data/home_access_detail_repository.dart';

class AccessDetailController extends ChangeNotifier {
  AccessDetailController({AccessDetailRepository? repository})
      : _repository = repository ?? HomeAccessDetailRepository();

  final AccessDetailRepository _repository;

  bool isLoading = true;
  String? errorMessage;
  AccessDetailData? detail;

  Future<void> load(int accessId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      detail = await _repository.getAccessDetail(accessId);
    } catch (_) {
      errorMessage = 'No se pudo cargar el detalle del acceso.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
