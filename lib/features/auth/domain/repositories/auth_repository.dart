abstract class AuthRepository {
  Future<void> register(String name, String email, String password);
  Future<void> sendPasswordReset(String email);

  Future login(String email, String password);
}
