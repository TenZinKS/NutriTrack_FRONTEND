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
}
