import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../data/models/access_detail_models.dart';
import '../../../../data/models/access_list_models.dart';
import '../../../../widgets/app_panel.dart';
import '../../logic/access_detail_controller.dart';
import '../widgets/app_screen_layout.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart' show SidebarDestination;

class AccessDetailPage extends StatefulWidget {
  const AccessDetailPage({
    super.key,
    required this.accessId,
  });

  final int accessId;

  @override
  State<AccessDetailPage> createState() => _AccessDetailPageState();
}

class _AccessDetailPageState extends State<AccessDetailPage> {
  late final AccessDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AccessDetailController()..load(widget.accessId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSidebarSelected(SidebarDestination destination) {
    if (destination == SidebarDestination.dashboard) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else if (destination == SidebarDestination.accessList) {
      Navigator.pushReplacementNamed(context, AppRoutes.accessList);
    }
  }

  void _goBackToList() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.accessList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_controller.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_controller.errorMessage!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _controller.load(widget.accessId),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final detail = _controller.detail;
            if (detail == null) {
              return const SizedBox.shrink();
            }

            return AppScreenLayout(
              selectedDestination: SidebarDestination.accessList,
              onSidebarSelected: _onSidebarSelected,
              content: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 1100;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(compact ? 12 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const DashboardHeader(
                          title: 'Detalle',
                          subtitle: 'Informacion de Acceso',
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _goBackToList,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Volver al listado'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _AccessSummaryPanel(detail: detail),
                        const SizedBox(height: 16),
                        _DetailInfoGrid(detail: detail, compact: compact),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AccessSummaryPanel extends StatelessWidget {
  const _AccessSummaryPanel({required this.detail});

  final AccessDetailData detail;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 980;
              return Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF1E9EEA),
                        child: Text(
                          _initials(detail.personName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.personName,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Acceso #${detail.accessId} - ${_formatDateTime(detail.accessDateTime)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!narrow) ...[
                        const SizedBox(width: 10),
                        _TagChip(
                          label: _resultLabel(detail.result),
                          textColor: _resultTextColor(detail.result),
                          backgroundColor:
                              _resultBackgroundColor(detail.result),
                          borderColor: _resultBorderColor(detail.result),
                        ),
                        const SizedBox(width: 8),
                        _TagChip(
                          label: _typeLabel(detail.type),
                          textColor: _typeTextColor(detail.type),
                          backgroundColor: _typeBackgroundColor(detail.type),
                          borderColor: _typeBorderColor(detail.type),
                        ),
                      ],
                    ],
                  ),
                  if (narrow) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _TagChip(
                          label: _resultLabel(detail.result),
                          textColor: _resultTextColor(detail.result),
                          backgroundColor:
                              _resultBackgroundColor(detail.result),
                          borderColor: _resultBorderColor(detail.result),
                        ),
                        const SizedBox(width: 8),
                        _TagChip(
                          label: _typeLabel(detail.type),
                          textColor: _typeTextColor(detail.type),
                          backgroundColor: _typeBackgroundColor(detail.type),
                          borderColor: _typeBorderColor(detail.type),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 900;
              if (compact) {
                return Column(
                  children: [
                    _SummaryDataCard(label: 'Placa', value: detail.plate),
                    const SizedBox(height: 10),
                    _SummaryDataCard(label: 'Motivo', value: detail.reason),
                    const SizedBox(height: 10),
                    _SummaryDataCard(
                      label: 'Placa detectada',
                      value: detail.detectedPlate,
                      accent: true,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child:
                        _SummaryDataCard(label: 'Placa', value: detail.plate),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child:
                        _SummaryDataCard(label: 'Motivo', value: detail.reason),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryDataCard(
                      label: 'Placa detectada',
                      value: detail.detectedPlate,
                      accent: true,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailInfoGrid extends StatelessWidget {
  const _DetailInfoGrid({
    required this.detail,
    required this.compact,
  });

  final AccessDetailData detail;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final panels = [
      _InfoPanel(
        title: 'Residencia',
        children: [
          _InfoRow(label: 'Descripcion', value: detail.residence.description),
          _InfoRow(label: 'Manzana', value: detail.residence.block),
          _InfoRow(label: 'Villa', value: detail.residence.villa),
          _InfoRow(
            label: 'Estado',
            valueWidget: _TagChip(
              label: detail.residence.status,
              textColor: const Color(0xFF0D8D58),
              backgroundColor: const Color(0xFFE8FAF2),
              borderColor: const Color(0xFFBCEED5),
            ),
          ),
        ],
      ),
      _InfoPanel(
        title: 'Residente autoriza',
        children: [
          _InfoRow(label: 'Nombre', value: detail.authorizedResident.name),
          _InfoRow(
            label: 'Identificacion',
            value: detail.authorizedResident.identification,
          ),
          _InfoRow(label: 'Celular', value: detail.authorizedResident.phone),
        ],
      ),
      _InfoPanel(
        title: 'Guardia',
        children: [
          _InfoRow(label: 'Nombre', value: detail.guard.name),
          _InfoRow(label: 'Identificacion', value: detail.guard.identification),
          _InfoRow(label: 'Celular', value: detail.guard.phone),
        ],
      ),
      _InfoPanel(
        title: 'Imagen capturada',
        child: _ImagePlaceholder(
          imagePath: detail.capturedImagePath,
          imageBase64: detail.capturedImageBase64,
          isAvailable: detail.capturedImageAvailable,
        ),
      ),
    ];

    if (compact) {
      return Column(
        children: [
          for (var i = 0; i < panels.length; i++) ...[
            panels[i],
            if (i != panels.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final panelWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final panel in panels)
              SizedBox(width: panelWidth, child: panel),
          ],
        );
      },
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.title,
    this.children,
    this.child,
  });

  final String title;
  final List<Widget>? children;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelTitle(title),
          const SizedBox(height: 10),
          ...?children,
          if (child != null) ...[child!],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
          ),
          valueWidget ??
              Text(
                value ?? '-',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
        ],
      ),
    );
  }
}

class _SummaryDataCard extends StatelessWidget {
  const _SummaryDataCard({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF5FAFF),
        border: Border.all(color: const Color(0xFFD7E8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accent ? const Color(0xFFE9A11A) : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatefulWidget {
  const _ImagePlaceholder({
    required this.imagePath,
    required this.imageBase64,
    required this.isAvailable,
  });

  final String? imagePath;
  final String? imageBase64;
  final bool isAvailable;

  @override
  State<_ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<_ImagePlaceholder> {
  late List<String> _candidateUrls;
  Uint8List? _imageBytes;
  int _currentCandidate = 0;

  bool get _hasBase64Source {
    final value = widget.imageBase64?.trim();
    return value != null && value.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _syncImageSources();
  }

  @override
  void didUpdateWidget(covariant _ImagePlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath ||
        oldWidget.imageBase64 != widget.imageBase64) {
      _syncImageSources();
    }
  }

  void _syncImageSources() {
    _candidateUrls = _buildImageCandidates(widget.imagePath);
    _imageBytes = _decodeBase64Image(widget.imageBase64);
    _currentCandidate = 0;
  }

  bool get _hasImagePath {
    final path = widget.imagePath?.trim();
    return path != null && path.isNotEmpty;
  }

  bool get _hasMoreCandidates => _currentCandidate < _candidateUrls.length - 1;

  void _tryNextCandidate() {
    if (!_hasMoreCandidates) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _currentCandidate += 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _imageBytes;
    final imageUrl = _hasImagePath && _candidateUrls.isNotEmpty
        ? _candidateUrls[_currentCandidate]
        : null;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.panelBorder),
        color: const Color(0xFFFAFCFF),
      ),
      child: imageBytes != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _ImageStatus(
                    title: 'No se pudo decodificar la imagen',
                    subtitle: widget.imagePath,
                  );
                },
              ),
            )
          : imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      if (_hasMoreCandidates) {
                        _tryNextCandidate();
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      return _ImageStatus(
                        title: 'No se pudo cargar la imagen',
                        subtitle: widget.imagePath,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  ),
                )
              : _ImageStatus(
                  title: widget.isAvailable
                      ? _hasBase64Source
                          ? 'Base64 de imagen invalido'
                          : 'Imagen disponible sin datos validos'
                      : 'Imagen no disponible',
                  subtitle: widget.imagePath,
                ),
    );
  }
}

class _ImageStatus extends StatelessWidget {
  const _ImageStatus({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo_camera_outlined, size: 34),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

List<String> _buildImageCandidates(String? rawPath) {
  final path = rawPath?.trim() ?? '';
  if (path.isEmpty) {
    return const [];
  }

  if (path.startsWith('http://') || path.startsWith('https://')) {
    return [path];
  }

  final normalizedBase =
      ApiConfig.baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');
  final candidates = <String>{};

  candidates.add('$normalizedBase/$normalizedPath');

  if (normalizedPath.startsWith('storage/')) {
    final withoutStorage =
        normalizedPath.replaceFirst(RegExp(r'^storage/+'), '');
    candidates.add('$normalizedBase/public/storage/$withoutStorage');
    candidates.add('$normalizedBase/public/$normalizedPath');
  } else {
    candidates.add('$normalizedBase/storage/$normalizedPath');
    candidates.add('$normalizedBase/public/storage/$normalizedPath');
  }

  return candidates.toList(growable: false);
}

Uint8List? _decodeBase64Image(String? raw) {
  final input = raw?.trim() ?? '';
  if (input.isEmpty) {
    return null;
  }

  final data =
      input.contains(',') ? input.substring(input.indexOf(',') + 1) : input;
  final normalized = data.replaceAll(RegExp(r'\s+'), '');
  final standard = normalized.replaceAll('-', '+').replaceAll('_', '/');
  final padded = _padBase64(standard);

  try {
    return base64Decode(normalized);
  } catch (_) {
    try {
      return base64Decode(standard);
    } catch (_) {
      try {
        return base64Decode(padded);
      } catch (_) {
        try {
          return base64Url.decode(normalized);
        } catch (_) {
          return null;
        }
      }
    }
  }
}

String _padBase64(String value) {
  final remainder = value.length % 4;
  if (remainder == 0) {
    return value;
  }
  return '$value${'=' * (4 - remainder)}';
}

class _TagChip extends StatelessWidget {
  const _TagChip({
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
    return Container(
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
    );
  }
}

String _initials(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) {
    return 'NA';
  }
  final parts = trimmed.split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.length == 1) {
    final first = parts.first;
    return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

String _formatDateTime(DateTime dateTime) {
  const monthNames = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour < 12 ? 'a. m.' : 'p. m.';
  return '${dateTime.day} de ${monthNames[dateTime.month - 1]} de ${dateTime.year}, $hour:$minute $period';
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
