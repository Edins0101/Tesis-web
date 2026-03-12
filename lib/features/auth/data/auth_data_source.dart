class AuthDataSource {
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final username = email.trim();
    return username == 'admin' && password == 'Admin0101*';
  }
}
