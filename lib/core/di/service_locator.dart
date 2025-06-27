import 'package:frontendpatient/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontendpatient/features/auth/domain/usecases/update_patient_profile_usecase.dart';
import 'package:frontendpatient/features/nutrition_plan/data/datasources/nutrition_plan_local_datasource.dart';
import 'package:frontendpatient/features/nutrition_plan/data/datasources/nutrition_plan_remote_datasource.dart';
import 'package:frontendpatient/features/nutrition_plan/data/repositories/nutrition_plan_repository_impl.dart';
import 'package:frontendpatient/features/nutrition_plan/domain/repositories/nutrition_plan_repository.dart';
import 'package:frontendpatient/features/nutrition_plan/domain/usecases/get_pending_plans_usecase.dart';
import 'package:frontendpatient/features/nutrition_plan/domain/usecases/get_plan_history_usecase.dart';
import 'package:frontendpatient/features/nutrition_plan/domain/usecases/get_today_plan_usecase.dart';
import 'package:frontendpatient/features/nutrition_plan/domain/usecases/get_weekly_plan_usecase.dart';
import 'package:frontendpatient/features/nutrition_plan/domain/usecases/respond_to_plan_usecase.dart';
import 'package:frontendpatient/shared/constants/api_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:frontendpatient/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:frontendpatient/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:frontendpatient/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontendpatient/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontendpatient/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontendpatient/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:frontendpatient/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontendpatient/features/auth/presentation/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterPatientUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePatientProfileUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Providers
  sl.registerFactory(
        () => AuthProvider(
      loginUseCase: sl(),
      registerPatientUseCase: sl(),
      getCurrentUserUseCase: sl(),
      updatePatientProfileUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Nutrition Plan
  sl.registerLazySingleton<http.Client>(() => http.Client());

  sl.registerLazySingleton<NutritionPlanLocalDataSource>(
        () => NutritionPlanLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<NutritionPlanRemoteDataSource>(
        () => NutritionPlanRemoteDataSourceImpl(
      client: sl(),
      baseUrl: ApiConstants.nutrition,
    ),
  );

  sl.registerLazySingleton<NutritionPlanRepository>(
        () => NutritionPlanRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

// Use Cases
  sl.registerLazySingleton(() => GetTodayPlanUseCase(sl()));
  sl.registerLazySingleton(() => GetWeeklyPlanUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingPlansUseCase(sl()));
  sl.registerLazySingleton(() => RespondToPlanUseCase(sl()));
  sl.registerLazySingleton(() => GetPlanHistoryUseCase(sl()));

}