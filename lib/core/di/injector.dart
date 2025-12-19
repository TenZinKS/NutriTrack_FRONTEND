import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:nutri_track/features/analysis/data/datasources/analysis_remote_datasource.dart';
import 'package:nutri_track/features/analysis/data/repositories/analysis_repository_impl.dart';
import 'package:nutri_track/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:nutri_track/features/analysis/domain/usecases/get_analysis_range_usecase.dart';
import 'package:nutri_track/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutri_track/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:nutri_track/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:nutri_track/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:nutri_track/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nutri_track/features/auth/domain/usecases/register_usecase.dart';
import 'package:nutri_track/features/meal_planner/data/datasources/meal_planner_remote_datasource.dart';
import 'package:nutri_track/features/meal_planner/data/repositories/meal_planner_repository_impl.dart';
import 'package:nutri_track/features/meal_planner/domain/repositories/meal_planner_repository.dart';
import 'package:nutri_track/features/meal_planner/domain/usecases/generate_meal_plan_usecase.dart';
import 'package:nutri_track/features/meal_planner/domain/usecases/save_meal_usecase.dart';
import 'package:nutri_track/features/my_foods/data/datasources/my_foods_remote_datasource.dart';
import 'package:nutri_track/features/my_foods/data/repositories/my_foods_repository_impl.dart';
import 'package:nutri_track/features/my_foods/domain/repositories/my_foods_repository.dart';
import 'package:nutri_track/features/my_foods/domain/usecases/delete_custom_food_usecase.dart';
import 'package:nutri_track/features/my_foods/domain/usecases/listen_custom_foods_usecase.dart';
import 'package:nutri_track/features/my_foods/domain/usecases/save_custom_food_usecase.dart';
import 'package:nutri_track/features/my_foods/domain/usecases/toggle_favorite_food_usecase.dart';
import 'package:nutri_track/features/my_foods/domain/usecases/update_custom_food_usecase.dart';
import 'package:nutri_track/features/food_entries/data/datasources/food_entries_remote_datasource.dart';
import 'package:nutri_track/features/food_entries/data/repositories/food_entries_repository_impl.dart';
import 'package:nutri_track/features/food_entries/domain/repositories/food_entries_repository.dart';
import 'package:nutri_track/features/food_entries/domain/usecases/delete_food_entry_usecase.dart';
import 'package:nutri_track/features/food_entries/domain/usecases/listen_today_entries_usecase.dart';
import 'package:nutri_track/features/food_entries/domain/usecases/update_food_entry_usecase.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/dashboard/data/datasources/macros_remote_datasource.dart';
import '../../features/dashboard/data/repositories/macros_repository_impl.dart';
import '../../features/dashboard/domain/repositories/macros_repository.dart';
import '../../features/dashboard/domain/usecases/add_food_to_diet_usecase.dart';
import '../../features/dashboard/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/dashboard/domain/usecases/get_current_user_macros_usecase.dart';
import '../../features/dashboard/domain/usecases/listen_user_macros_usecase.dart';
import '../../features/dashboard/domain/usecases/update_user_macros_usecase.dart';
import '../../features/dashboard/domain/usecases/watch_onboarding_status_usecase.dart';
import '../../features/dashboard/domain/usecases/generate_reminders_usecase.dart';
import '../notifications/notification_service.dart';
import '../../features/onboarding/domain/usecases/calculate_nutrition_targets_usecase.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<http.Client>(() => http.Client());

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

  sl.registerLazySingleton<MealPlannerRemoteDatasource>(
    () => MealPlannerRemoteDatasourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      httpClient: sl(),
    ),
  );
  sl.registerLazySingleton<MyFoodsRemoteDatasource>(
    () => MyFoodsRemoteDatasourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<FoodEntriesRemoteDatasource>(
    () => FoodEntriesRemoteDatasourceImpl(
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

  sl.registerLazySingleton<MealPlannerRepository>(
    () => MealPlannerRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton<MyFoodsRepository>(
    () => MyFoodsRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton<FoodEntriesRepository>(
    () => FoodEntriesRepositoryImpl(remote: sl()),
  );

  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUsecase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUsecase(sl()));
  sl.registerLazySingleton(() => ListenUserMacrosUsecase(sl()));
  sl.registerLazySingleton(() => UpdateUserMacrosUsecase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserMacrosUsecase(sl()));
  sl.registerLazySingleton(() => CompleteOnboardingUsecase(sl()));
  sl.registerLazySingleton(() => WatchOnboardingStatusUsecase(sl()));
  sl.registerLazySingleton(() => GenerateRemindersUsecase());
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => AddFoodToDietUsecase(sl(), sl(), sl()));
  sl.registerLazySingleton(() => GetAnalysisRangeUsecase(sl()));
  sl.registerLazySingleton(() => GenerateMealPlanUsecase(sl()));
  sl.registerLazySingleton(() => SaveMealUsecase(sl()));
  sl.registerLazySingleton(() => SaveCustomFoodUsecase(sl()));
  sl.registerLazySingleton(() => ListenCustomFoodsUsecase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteFoodUsecase(sl()));
  sl.registerLazySingleton(() => DeleteCustomFoodUsecase(sl()));
  sl.registerLazySingleton(() => UpdateCustomFoodUsecase(sl()));
  sl.registerLazySingleton(() => ListenTodayEntriesUsecase(sl()));
  sl.registerLazySingleton(
    () => UpdateFoodEntryUsecase(
      repository: sl(),
      macrosRepository: sl(),
      analysisRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => DeleteFoodEntryUsecase(
      repository: sl(),
      macrosRepository: sl(),
      analysisRepository: sl(),
    ),
  );
  sl.registerLazySingleton(() => CalculateNutritionTargetsUsecase());
}
