import '../entities/user_macros.dart';

abstract class MacrosRepository {
  Stream<UserMacros> listenToMacros();
  Future<void> updateMacros(UserMacros macros);
}
