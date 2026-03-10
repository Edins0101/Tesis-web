import '../models/access_detail_models.dart';
import '../models/access_list_models.dart';
import 'access_detail_service.dart';

class MockAccessDetailService implements AccessDetailService {
  @override
  Future<AccessDetailData> fetchAccessDetail(int accessId) async {
    final index = accessId.abs() % 6;
    const people = [
      'Carlos Vigil',
      'Edinson Ramirez',
      'Pierre Orellana',
      'Ana Medina',
      'Sofia Mendez',
      'Marco Ponce',
    ];
    const reasons = [
      'Emergencia',
      'Entrega de paquete',
      'Visita familiar',
      'Soporte tecnico',
      'Taxi autorizado',
      'Retiro de documentos',
    ];

    final person = people[index];
    final type = index.isEven ? AccessType.manualGuardia : AccessType.sinQr;
    final result = index == 1 || index == 4
        ? AccessResult.rechazado
        : AccessResult.autorizado;
    final blockCode = String.fromCharCode(65 + (index % 3));
    final villaNumber = (index + 1).toString().padLeft(3, '0');
    final residence = 'MZ-$blockCode V-$villaNumber';

    return AccessDetailData(
      accessId: accessId,
      personName: person,
      accessDateTime:
          DateTime(2026, 3, 10, 2, 15).subtract(Duration(days: index)),
      result: result,
      type: type,
      plate: 'ABC-${120 + index}',
      reason: reasons[index],
      detectedPlate: 'ABC-${120 + index}',
      residence: AccessResidenceInfo(
        description: residence,
        block: 'MZ-$blockCode',
        villa: 'V-$villaNumber',
        status: 'Activo',
      ),
      authorizedResident: AccessPersonInfo(
        name: person,
        identification: '22232425${20 + index}',
        phone: '09777777${70 + index}',
      ),
      guard: const AccessPersonInfo(
        name: 'Carlos Vigil',
        identification: '2223242526',
        phone: '0977777777',
      ),
      capturedImageAvailable: false,
      capturedImagePath: null,
    );
  }
}
