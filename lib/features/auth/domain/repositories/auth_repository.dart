import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<void> register(String name, String email, String password);
  Future<void> sendPasswordReset(String email);

  Future login(String email, String password);
  Future<AuthUser?> currentUser();
  Future<void> logout();
  Future<void> deleteAccount();
}
