import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:nutri_track/features/analysis/data/datasources/analysis_remote_datasource.dart';
import 'package:nutri_track/features/analysis/data/repositories/analysis_repository_impl.dart';
import 'package:nutri_track/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:nutri_track/features/analysis/domain/usecases/get_analysis_range_usecase.dart';
import 'package:nutri_track/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutri_track/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:nutri_track/features/auth/domain/usecases/register_usecase.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/dashboard/data/datasources/macros_remote_datasource.dart';
import '../../features/dashboard/data/repositories/macros_repository_impl.dart';
import '../../features/dashboard/domain/repositories/macros_repository.dart';
import '../../features/dashboard/domain/usecases/listen_user_macros_usecase.dart';
import '../../features/dashboard/domain/usecases/update_user_macros_usecase.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<AnalysisRemoteDatasource>(
    () => AnalysisRemoteDatasourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );

  sl.registerLazySingleton<MacrosRemoteDatasource>(
    () => MacrosRemoteDatasourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl()),
  );

  sl.registerLazySingleton<MacrosRepository>(
    () => MacrosRepositoryImpl(remoteDatasource: sl()),
  );

  sl.registerLazySingleton<AnalysisRepository>(
    () => AnalysisRepositoryImpl(remoteDatasource: sl()),
  );

  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUsecase(sl()));
  sl.registerLazySingleton(() => ListenUserMacrosUsecase(sl()));
  sl.registerLazySingleton(() => UpdateUserMacrosUsecase(sl()));
  sl.registerLazySingleton(() => GetAnalysisRangeUsecase(sl()));
}
