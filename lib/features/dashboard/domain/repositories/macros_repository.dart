import '../entities/user_macros.dart';

abstract class MacrosRepository {
  Stream<UserMacros> listenToMacros();
  Future<void> updateMacros(UserMacros macros);
  Future<UserMacros> fetchCurrentMacros();
  Future<void> markOnboardingCompleted();
  Future<bool> isOnboardingCompleted();
  Stream<bool> watchOnboardingStatus();
}
