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
    final image = data['imagen'] as Map<String, dynamic>? ?? const {};

    final createdRaw = (dates['creado'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdRaw) ?? DateTime.now();

    final imagePath = (image['path'] ?? '').toString().trim();
    final imageAvailable = image['available'] == true;

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
      capturedImageAvailable: imageAvailable,
      capturedImagePath: imagePath.isEmpty ? null : imagePath,
    );
  }
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
