import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/access_list_models.dart';
import '../../../../widgets/app_panel.dart';

const double _tableMinWidth = 920;
const double _rowHorizontalPadding = 14;

class AccessRecordsTable extends StatelessWidget {
  const AccessRecordsTable({
    super.key,
    required this.records,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.onPageChanged,
    required this.onViewRecord,
  });

  final List<AccessRecord> records;
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<AccessRecord> onViewRecord;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth : _tableMinWidth;
        final tableWidth = math.max(availableWidth, _tableMinWidth);
        final layout = _TableLayout.fromWidth(tableWidth);

        return AppPanel(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Registro de Accesos',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      '$totalRecords registros',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.panelBorder),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      _TableHeader(layout: layout),
                      for (final record in records)
                        _TableRow(
                          record: record,
                          layout: layout,
                          onViewRecord: onViewRecord,
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.panelBorder),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pagina $currentPage de $totalPages',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (var page = 1; page <= totalPages; page++)
                              _PaginationButton(
                                page: page,
                                selected: page == currentPage,
                                onTap: () => onPageChanged(page),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TableLayout {
  const _TableLayout({
    required this.id,
    required this.person,
    required this.type,
    required this.result,
    required this.residence,
    required this.action,
  });

  final double id;
  final double person;
  final double type;
  final double result;
  final double residence;
  final double action;

  factory _TableLayout.fromWidth(double tableWidth) {
    const id = 90.0;
    const action = 100.0;
    final innerWidth = tableWidth - (_rowHorizontalPadding * 2);
    final remaining = math.max(620, innerWidth - id - action);

    final person = remaining * 0.28;
    final type = remaining * 0.24;
    final result = remaining * 0.20;
    final residence = remaining - person - type - result;

    return _TableLayout(
      id: id,
      person: person,
      type: type,
      result: result,
      residence: residence,
      action: action,
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.layout});

  final _TableLayout layout;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: AppColors.textMuted,
      fontWeight: FontWeight.w700,
      fontSize: 12,
      letterSpacing: 1,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _rowHorizontalPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          SizedBox(width: layout.id, child: const Text('ID', style: style)),
          SizedBox(
            width: layout.person,
            child: const Text('PERSONA', style: style),
          ),
          SizedBox(
            width: layout.type,
            child: const Text('TIPO ACCESO', style: style),
          ),
          SizedBox(
            width: layout.result,
            child: const Text('RESULTADO', style: style),
          ),
          SizedBox(
            width: layout.residence,
            child: const Text('RESIDENCIA', style: style),
          ),
          SizedBox(width: layout.action),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.record,
    required this.layout,
    required this.onViewRecord,
  });

  final AccessRecord record;
  final _TableLayout layout;
  final ValueChanged<AccessRecord> onViewRecord;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.panelBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: _rowHorizontalPadding),
      child: Row(
        children: [
          SizedBox(
            width: layout.id,
            child: Text(
              '#${record.id}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            width: layout.person,
            child: Text(
              record.person,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: layout.type,
            child: _StatusChip(
              label: _typeLabel(record.type),
              textColor: _typeTextColor(record.type),
              backgroundColor: _typeBackgroundColor(record.type),
              borderColor: _typeBorderColor(record.type),
            ),
          ),
          SizedBox(
            width: layout.result,
            child: _StatusChip(
              label: _resultLabel(record.result),
              textColor: _resultTextColor(record.result),
              backgroundColor: _resultBackgroundColor(record.result),
              borderColor: _resultBorderColor(record.result),
            ),
          ),
          SizedBox(
            width: layout.residence,
            child: Text(
              record.residence,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            width: layout.action,
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () => onViewRecord(record),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(84, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Ver ->'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(minWidth: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final int page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? AppColors.cyan : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.cyan : AppColors.panelBorder,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            color: selected ? AppColors.cyanDark : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String _typeLabel(AccessType type) {
  switch (type) {
    case AccessType.manualGuardia:
      return 'Manual Guardia';
    case AccessType.sinQr:
      return 'Sin QR';
  }
}

String _resultLabel(AccessResult result) {
  switch (result) {
    case AccessResult.autorizado:
      return 'Autorizado';
    case AccessResult.rechazado:
      return 'Rechazado';
  }
}

Color _typeTextColor(AccessType type) {
  switch (type) {
    case AccessType.manualGuardia:
      return const Color(0xFF007C94);
    case AccessType.sinQr:
      return const Color(0xFF4B6380);
  }
}

Color _typeBackgroundColor(AccessType type) {
  switch (type) {
    case AccessType.manualGuardia:
      return const Color(0xFFE2F7FB);
    case AccessType.sinQr:
      return const Color(0xFFEFF3F8);
  }
}

Color _typeBorderColor(AccessType type) {
  switch (type) {
    case AccessType.manualGuardia:
      return const Color(0xFFB5EAF3);
    case AccessType.sinQr:
      return const Color(0xFFD7E1ED);
  }
}

Color _resultTextColor(AccessResult result) {
  switch (result) {
    case AccessResult.autorizado:
      return const Color(0xFF0D8D58);
    case AccessResult.rechazado:
      return const Color(0xFFB43C61);
  }
}

Color _resultBackgroundColor(AccessResult result) {
  switch (result) {
    case AccessResult.autorizado:
      return const Color(0xFFE8FAF2);
    case AccessResult.rechazado:
      return const Color(0xFFFBE8EF);
  }
}

Color _resultBorderColor(AccessResult result) {
  switch (result) {
    case AccessResult.autorizado:
      return const Color(0xFFBCEED5);
    case AccessResult.rechazado:
      return const Color(0xFFF3BDD0);
  }
}
