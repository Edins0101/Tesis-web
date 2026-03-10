import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/dashboard_models.dart';

class KpiGrid extends StatelessWidget {
  const KpiGrid({
    super.key,
    required this.kpis,
  });

  final List<KpiCardData> kpis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final maxWidth = constraints.maxWidth;
        int columns = 1;
        if (maxWidth >= 1200) {
          columns = 6;
        } else if (maxWidth >= 900) {
          columns = 3;
        } else if (maxWidth >= 560) {
          columns = 2;
        }
        final cardWidth = (maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in kpis)
              SizedBox(
                width: cardWidth,
                child: _KpiCard(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.metric});

  final KpiCardData metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120A3252),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: Border(top: BorderSide(color: metric.color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            metric.value,
            style: TextStyle(
              color: metric.color,
              fontSize: 50,
              height: 0.9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.subtitle ?? '',
            style: const TextStyle(color: Color(0xFF7A92AC), height: 1.2),
          ),
        ],
      ),
    );
  }
}
