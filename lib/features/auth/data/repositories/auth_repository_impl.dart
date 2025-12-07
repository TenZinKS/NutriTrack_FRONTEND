
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;

  AuthRepositoryImpl({required this.remote});

  @override
  Future<UserEntity?> login(String email, String password) async {
    final user = await remote.login(email, password);
    if (user == null) return null;

    return UserEntity(uid: user.uid, email: user.email ?? '');
  }
}
