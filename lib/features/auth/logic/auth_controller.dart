import 'package:flutter/foundation.dart';

import '../data/auth_data_source.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthDataSource? dataSource})
      : _dataSource = dataSource ?? AuthDataSource();

  final AuthDataSource _dataSource;

  bool isLoading = false;
  bool isAuthenticated = false;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    isAuthenticated = await _dataSource.signIn(
      email: email,
      password: password,
    );

    isLoading = false;
    notifyListeners();
  }
}
