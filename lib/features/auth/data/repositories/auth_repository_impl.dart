import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;

  AuthRepositoryImpl({required this.remote});

  @override
  Future<void> register(String name, String email, String password) {
    return remote.register(name, email, password);
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return remote.sendPasswordResetEmail(email);
  }

  @override
  Future login(String email, String password) {
    return remote.login(email, password);
  }

  @override
  Future<AuthUser?> currentUser() async {
    final user = await remote.currentUser();
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<void> logout() {
    return remote.logout();
  }

  @override
  Future<void> deleteAccount() {
    return remote.deleteAccount();
  }
}
