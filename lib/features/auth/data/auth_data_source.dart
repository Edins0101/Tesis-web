class AuthDataSource {
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    return email.isNotEmpty && password.isNotEmpty;
  }
}
