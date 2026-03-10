import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../models/dashboard_models.dart';
import 'dashboard_service.dart';

class MockDashboardService implements DashboardService {
  @override
  Future<DashboardData> fetchDashboardData() async {
    return const DashboardData(
      filters: [
        DashboardFilterField(
          label: 'Fecha desde',
          hint: 'dd/mm/aaaa',
          icon: Icons.calendar_today_outlined,
        ),
        DashboardFilterField(
          label: 'Fecha hasta',
          hint: 'dd/mm/aaaa',
          icon: Icons.calendar_today_outlined,
        ),
        DashboardFilterField(
          label: 'Tipo',
          hint: 'Todos',
          icon: Icons.expand_more_rounded,
        ),
        DashboardFilterField(
          label: 'Resultado',
          hint: 'Todos',
          icon: Icons.expand_more_rounded,
        ),
        DashboardFilterField(label: 'Manzana', hint: 'Ej: MZ-A'),
        DashboardFilterField(label: 'Villa', hint: 'Ej: V-001'),
        DashboardFilterField(label: 'Nombre visitante', hint: 'Nombre...'),
        DashboardFilterField(label: 'Placa', hint: 'ABC-123'),
      ],
      kpis: [
        KpiCardData(
            title: 'Total accesos', value: '44', color: Color(0xFF00BEE2)),
        KpiCardData(
          title: 'Autorizados',
          value: '16',
          subtitle: '36% del total',
          color: Color(0xFF14D99B),
        ),
        KpiCardData(
          title: 'Rechazados',
          value: '28',
          subtitle: '64% del total',
          color: Color(0xFFFF5B7E),
        ),
        KpiCardData(title: 'Pendientes', value: '0', color: Color(0xFFF4C95D)),
        KpiCardData(title: 'Con llamada', value: '1', color: Color(0xFF9A8DF7)),
        KpiCardData(
            title: 'Sin llamada', value: '43', color: Color(0xFF8EA4BC)),
      ],
      results: ResultBreakdown(authorized: 16, rejected: 28),
      types: [
        AccessTypeMetric(
          label: 'Sin QR',
          value: 39,
          max: 44,
          color: Color(0xFF8D80E9),
        ),
        AccessTypeMetric(
          label: 'Manual',
          value: 5,
          max: 44,
          color: AppColors.cyan,
        ),
      ],
      byDay: [
        AccessByDayMetric(label: '01-20', value: 1.2),
        AccessByDayMetric(label: '02-22', value: 8.5),
        AccessByDayMetric(label: '02-25', value: 2.1),
        AccessByDayMetric(label: '03-01', value: 3.2),
        AccessByDayMetric(label: '03-10', value: 1.7),
      ],
    );
  }
}
