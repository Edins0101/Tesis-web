import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  const ApiConfig._();

  static const _defaultBaseUrl = 'http://10.242.31.113:8000';

  static String get baseUrl {
    final fromDotEnv = dotenv.env['API_BASE_URL']?.trim();
    if (fromDotEnv != null && fromDotEnv.isNotEmpty) {
      return fromDotEnv;
    }

    const fromDartDefine = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    if (fromDartDefine.isNotEmpty) {
      return fromDartDefine;
    }

    return _defaultBaseUrl;
  }
}
