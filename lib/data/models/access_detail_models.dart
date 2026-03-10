import 'access_list_models.dart';

class AccessPersonInfo {
  const AccessPersonInfo({
    required this.name,
    required this.identification,
    required this.phone,
  });

  final String name;
  final String identification;
  final String phone;
}

class AccessResidenceInfo {
  const AccessResidenceInfo({
    required this.description,
    required this.block,
    required this.villa,
    required this.status,
  });

  final String description;
  final String block;
  final String villa;
  final String status;
}

class AccessDetailData {
  const AccessDetailData({
    required this.accessId,
    required this.personName,
    required this.accessDateTime,
    required this.result,
    required this.type,
    required this.plate,
    required this.reason,
    required this.detectedPlate,
    required this.residence,
    required this.authorizedResident,
    required this.guard,
    required this.capturedImageAvailable,
    this.capturedImagePath,
  });

  final int accessId;
  final String personName;
  final DateTime accessDateTime;
  final AccessResult result;
  final AccessType type;
  final String plate;
  final String reason;
  final String detectedPlate;
  final AccessResidenceInfo residence;
  final AccessPersonInfo authorizedResident;
  final AccessPersonInfo guard;
  final bool capturedImageAvailable;
  final String? capturedImagePath;
}
