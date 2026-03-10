import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/dashboard_models.dart';
import '../../../../widgets/app_panel.dart';

class FilterPanel extends StatelessWidget {
  const FilterPanel({
    super.key,
    required this.filters,
    required this.compact,
  });

  final List<DashboardFilterField> filters;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppPanel(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.hasBoundedWidth ? constraints.maxWidth : 250.0;
            final baseWidth = compact ? maxWidth : 250.0;
            final fieldWidth = baseWidth > maxWidth ? maxWidth : baseWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final field in filters)
                      _FilterField(
                        width: fieldWidth,
                        field: field,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        foregroundColor: AppColors.cyanDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.tune),
                      label: const Text(
                        'Aplicar Filtros',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.width,
    required this.field,
  });

  final double width;
  final DashboardFilterField field;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: field.hint,
              suffixIcon:
                  field.icon == null ? null : Icon(field.icon, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
