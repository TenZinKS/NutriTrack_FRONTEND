import '../../domain/entities/user_macros.dart';
import '../../domain/repositories/macros_repository.dart';
import '../datasources/macros_remote_datasource.dart';
import '../models/user_macros_model.dart';

class MacrosRepositoryImpl implements MacrosRepository {
  final MacrosRemoteDatasource remoteDatasource;

  MacrosRepositoryImpl({required this.remoteDatasource});

  @override
  Stream<UserMacros> listenToMacros() {
    return remoteDatasource.listenToMacros();
  }

  @override
  Future<void> updateMacros(UserMacros macros) {
    final model = UserMacrosModel(
      uid: macros.uid,
      name: macros.name,
      caloriesGoal: macros.caloriesGoal,
      caloriesConsumed: macros.caloriesConsumed,
      carbsGoal: macros.carbsGoal,
      carbsConsumed: macros.carbsConsumed,
      proteinGoal: macros.proteinGoal,
      proteinConsumed: macros.proteinConsumed,
      fatGoal: macros.fatGoal,
      fatConsumed: macros.fatConsumed,
      waterGoal: macros.waterGoal,
      waterConsumed: macros.waterConsumed,
    );

    return remoteDatasource.updateMacros(model);
  }

  @override
  Future<UserMacros> fetchCurrentMacros() {
    return remoteDatasource.fetchCurrentMacros();
  }

  @override
  Future<void> markOnboardingCompleted() {
    return remoteDatasource.markOnboardingCompleted();
  }

  @override
  Future<bool> isOnboardingCompleted() {
    return remoteDatasource.isOnboardingCompleted();
  }

  @override
  Stream<bool> watchOnboardingStatus() {
    return remoteDatasource.watchOnboardingStatus();
  }
}
