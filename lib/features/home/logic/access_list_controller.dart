import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/access_list_models.dart';
import '../../../data/repository/access_list_repository.dart';
import '../data/home_access_list_repository.dart';

class AccessListController extends ChangeNotifier {
  AccessListController({AccessListRepository? repository})
      : _repository = repository ?? HomeAccessListRepository();

  static final Map<String, AccessListData> _cacheByPage = {};

  final AccessListRepository _repository;

  bool isLoading = true;
  String? errorMessage;
  AccessListData? data;
  AccessListFilters filters = AccessListFilters.empty;
  int currentPage = 1;
  int pageSize = 50;
  int totalRecords = 0;

  int get totalPages {
    return data?.totalPages ?? 1;
  }

  List<AccessRecord> get currentRecords {
    return data?.records ?? const [];
  }

  Future<void> load({int page = 1, bool forceRefresh = false}) async {
    final cacheKey = '$page:$pageSize:${filters.cacheKey}';
    if (!forceRefresh && _cacheByPage.containsKey(cacheKey)) {
      data = _cacheByPage[cacheKey];
      currentPage = data?.page ?? page;
      pageSize = data?.pageSize ?? pageSize;
      totalRecords = data?.total ?? 0;
      errorMessage = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _repository.getAccessListData(
        page: page,
        pageSize: pageSize,
        filters: filters,
      );
      currentPage = data?.page ?? page;
      pageSize = data?.pageSize ?? pageSize;
      totalRecords = data?.total ?? 0;
      final resolvedKey = '$currentPage:$pageSize:${filters.cacheKey}';
      if (data != null) {
        _cacheByPage[resolvedKey] = data!;
      }
    } catch (_) {
      errorMessage = 'No se pudo cargar el listado de accesos.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (isLoading || page < 1 || page > totalPages || page == currentPage) {
      return;
    }
    unawaited(load(page: page));
  }

  Future<void> applyFilters(AccessListFilters newFilters) async {
    filters = newFilters;
    await load(page: 1, forceRefresh: true);
  }

  Future<void> clearFilters() async {
    filters = AccessListFilters.empty;
    await load(page: 1, forceRefresh: true);
  }
}
