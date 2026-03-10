import 'dashboard_models.dart';

enum AccessType {
  manualGuardia,
  sinQr,
}

enum AccessResult {
  autorizado,
  rechazado,
}

class AccessRecord {
  const AccessRecord({
    required this.id,
    required this.person,
    required this.type,
    required this.result,
    required this.residence,
    this.createdAt,
  });

  final int id;
  final String person;
  final AccessType type;
  final AccessResult result;
  final String residence;
  final DateTime? createdAt;
}

class AccessListFilters {
  const AccessListFilters({
    this.dateFrom,
    this.dateTo,
    this.result,
    this.type,
    this.visitor = '',
    this.residence = '',
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final AccessResult? result;
  final AccessType? type;
  final String visitor;
  final String residence;

  static const empty = AccessListFilters();

  AccessListFilters copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    AccessResult? result,
    bool clearResult = false,
    AccessType? type,
    bool clearType = false,
    String? visitor,
    String? residence,
  }) {
    return AccessListFilters(
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      result: clearResult ? null : (result ?? this.result),
      type: clearType ? null : (type ?? this.type),
      visitor: visitor ?? this.visitor,
      residence: residence ?? this.residence,
    );
  }

  bool get isEmpty {
    return dateFrom == null &&
        dateTo == null &&
        result == null &&
        type == null &&
        visitor.trim().isEmpty &&
        residence.trim().isEmpty;
  }

  String get cacheKey {
    return [
      dateFrom?.toIso8601String() ?? '',
      dateTo?.toIso8601String() ?? '',
      result?.name ?? '',
      type?.name ?? '',
      visitor.trim().toLowerCase(),
      residence.trim().toLowerCase(),
    ].join('|');
  }
}

class AccessListData {
  const AccessListData({
    required this.filters,
    required this.records,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  final List<DashboardFilterField> filters;
  final List<AccessRecord> records;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
}
