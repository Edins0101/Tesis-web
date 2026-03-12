class AuthDataSource {
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final username = email.trim();
    return username == 'admin' && password == 'Admin0101*';
  }
}
