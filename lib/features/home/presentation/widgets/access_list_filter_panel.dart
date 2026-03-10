import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/access_list_models.dart';
import '../../../../widgets/app_panel.dart';

class AccessListFilterPanel extends StatefulWidget {
  const AccessListFilterPanel({
    super.key,
    required this.initialFilters,
    required this.compact,
    required this.onSearch,
    required this.onClear,
  });

  final AccessListFilters initialFilters;
  final bool compact;
  final ValueChanged<AccessListFilters> onSearch;
  final VoidCallback onClear;

  @override
  State<AccessListFilterPanel> createState() => _AccessListFilterPanelState();
}

class _AccessListFilterPanelState extends State<AccessListFilterPanel> {
  late AccessListFilters _filters;
  late final TextEditingController _visitorController;
  late final TextEditingController _residenceController;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _visitorController = TextEditingController(text: _filters.visitor);
    _residenceController = TextEditingController(text: _filters.residence);
  }

  @override
  void didUpdateWidget(covariant AccessListFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilters != widget.initialFilters) {
      _filters = widget.initialFilters;
      _visitorController.text = _filters.visitor;
      _residenceController.text = _filters.residence;
    }
  }

  @override
  void dispose() {
    _visitorController.dispose();
    _residenceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final selectedDate = isFrom ? _filters.dateFrom : _filters.dateTo;
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) {
      return;
    }
    setState(() {
      _filters = isFrom
          ? _filters.copyWith(dateFrom: date)
          : _filters.copyWith(dateTo: date);
    });
  }

  void _search() {
    final next = _filters.copyWith(
      visitor: _visitorController.text,
      residence: _residenceController.text,
    );
    widget.onSearch(next);
  }

  void _clear() {
    setState(() {
      _filters = AccessListFilters.empty;
      _visitorController.clear();
      _residenceController.clear();
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppPanel(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.hasBoundedWidth ? constraints.maxWidth : 250.0;
            final baseWidth = widget.compact ? maxWidth : 250.0;
            final fieldWidth = baseWidth > maxWidth ? maxWidth : baseWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PanelTitle('Filtros de Lista'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _DateField(
                      width: fieldWidth,
                      label: 'Fecha desde',
                      value: _filters.dateFrom,
                      onTap: () => _pickDate(isFrom: true),
                    ),
                    _DateField(
                      width: fieldWidth,
                      label: 'Fecha hasta',
                      value: _filters.dateTo,
                      onTap: () => _pickDate(isFrom: false),
                    ),
                    _DropdownField<AccessResult>(
                      width: fieldWidth,
                      label: 'Resultado',
                      value: _filters.result,
                      hint: 'Todos',
                      items: const [
                        DropdownMenuItem(
                            value: AccessResult.autorizado,
                            child: Text('Autorizado')),
                        DropdownMenuItem(
                            value: AccessResult.rechazado,
                            child: Text('Rechazado')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(
                            result: value,
                            clearResult: value == null,
                          );
                        });
                      },
                    ),
                    _DropdownField<AccessType>(
                      width: fieldWidth,
                      label: 'Tipo',
                      value: _filters.type,
                      hint: 'Todos',
                      items: const [
                        DropdownMenuItem(
                            value: AccessType.manualGuardia,
                            child: Text('Manual guardia')),
                        DropdownMenuItem(
                            value: AccessType.sinQr, child: Text('Sin QR')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(
                            type: value,
                            clearType: value == null,
                          );
                        });
                      },
                    ),
                    _TextFilterField(
                      width: fieldWidth,
                      label: 'Visitante',
                      hint: 'Nombre...',
                      controller: _visitorController,
                    ),
                    _TextFilterField(
                      width: fieldWidth,
                      label: 'Residencia',
                      hint: 'MZ-A V-001',
                      controller: _residenceController,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _search,
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
                      icon: const Icon(Icons.search),
                      label: const Text(
                        'Buscar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _clear,
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

class _TextFilterField extends StatelessWidget {
  const _TextFilterField({
    required this.width,
    required this.label,
    required this.hint,
    required this.controller,
  });

  final double width;
  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.width,
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final double width;
  final String label;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            initialValue: value,
            isExpanded: true,
            decoration: const InputDecoration(),
            hint: Text(hint),
            items: items,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.width,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final double width;
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: InputDecorator(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
              ),
              child: Text(value == null ? 'dd/mm/aaaa' : _formatDate(value!)),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().padLeft(4, '0')}';
}
