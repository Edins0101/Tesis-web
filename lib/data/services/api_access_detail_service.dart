import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_config.dart';
import '../models/access_detail_models.dart';
import '../models/access_list_models.dart';
import 'access_detail_service.dart';

class ApiAccessDetailService implements AccessDetailService {
  ApiAccessDetailService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<AccessDetailData> fetchAccessDetail(int accessId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reportes/accesos/$accessId');
    final response = await _client.get(
      uri,
      headers: const {'accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener el detalle del acceso.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (payload['success'] != true) {
      throw Exception(
          payload['message'] ?? 'Error consultando detalle de acceso');
    }

    final data = payload['data'] as Map<String, dynamic>? ?? const {};
    final residence = data['residencia'] as Map<String, dynamic>? ?? const {};
    final authorized =
        data['residenteAutoriza'] as Map<String, dynamic>? ?? const {};
    final guard = data['guardia'] as Map<String, dynamic>? ?? const {};
    final validations =
        data['validaciones'] as Map<String, dynamic>? ?? const {};
    final dates = data['fechas'] as Map<String, dynamic>? ?? const {};
    final imageRaw = data['imagen'];

    final createdRaw = (dates['creado'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdRaw) ?? DateTime.now();

    final imagePayload = _parseImagePayload(imageRaw);

    return AccessDetailData(
      accessId: _asInt(data['accesoPk'], fallback: accessId),
      personName: (data['personaIngreso'] ?? '').toString(),
      accessDateTime: createdAt,
      result: _mapResult((data['resultado'] ?? '').toString()),
      type: _mapType((data['tipoAcceso'] ?? '').toString()),
      plate: (data['placa'] ?? '').toString(),
      reason: (data['motivo'] ?? '').toString(),
      detectedPlate:
          (validations['placaDetectada'] ?? data['placa'] ?? '').toString(),
      residence: AccessResidenceInfo(
        description: (residence['descripcion'] ?? '').toString(),
        block: (residence['manzana'] ?? '').toString(),
        villa: (residence['villa'] ?? '').toString(),
        status: (residence['estado'] ?? '').toString(),
      ),
      authorizedResident: AccessPersonInfo(
        name: (authorized['nombreCompleto'] ?? '').toString(),
        identification: (authorized['identificacion'] ?? '').toString(),
        phone: (authorized['celular'] ?? '').toString(),
      ),
      guard: AccessPersonInfo(
        name: (guard['nombreCompleto'] ?? '').toString(),
        identification: (guard['identificacion'] ?? '').toString(),
        phone: (guard['celular'] ?? '').toString(),
      ),
      capturedImageAvailable: imagePayload.available,
      capturedImagePath: imagePayload.path,
      capturedImageBase64: imagePayload.base64,
    );
  }
}

class _ImagePayload {
  const _ImagePayload({
    required this.available,
    this.path,
    this.base64,
  });

  final bool available;
  final String? path;
  final String? base64;
}

_ImagePayload _parseImagePayload(Object? raw) {
  if (raw is String) {
    final value = raw.trim();
    if (value.isEmpty) {
      return const _ImagePayload(available: false);
    }
    if (value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('storage/') ||
        value.startsWith('/')) {
      return _ImagePayload(available: true, path: value);
    }
    return _ImagePayload(available: true, base64: value);
  }

  if (raw is Map) {
    final payload = raw.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final path = _cleanString(payload['path']);
    final base64 = _cleanString(payload['base64']) ??
        _cleanString(payload['data']) ??
        _cleanString(payload['content']);
    final availableFlag = payload['available'] == true;
    final hasData = (path != null && path.isNotEmpty) ||
        (base64 != null && base64.isNotEmpty);
    return _ImagePayload(
      available: availableFlag || hasData,
      path: path,
      base64: base64,
    );
  }

  return const _ImagePayload(available: false);
}

String? _cleanString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

AccessType _mapType(String raw) {
  switch (raw.toLowerCase()) {
    case 'manual_guardia':
      return AccessType.manualGuardia;
    case 'visita_sin_qr':
      return AccessType.sinQr;
    default:
      return AccessType.sinQr;
  }
}

AccessResult _mapResult(String raw) {
  switch (raw.toLowerCase()) {
    case 'autorizado':
      return AccessResult.autorizado;
    case 'rechazado':
      return AccessResult.rechazado;
    default:
      return AccessResult.rechazado;
  }
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
