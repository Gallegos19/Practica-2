import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xuma/feautures/auth/domain/usecases/check_account_exist_usecase.dart';

// Imports existentes
import 'package:xuma/feautures/login/data/datasource/secure_storage_datasource.dart';
import 'package:xuma/feautures/login/data/repositories/user_profile_repository_impl.dart';
import 'package:xuma/feautures/login/domain/repositories/user_profile_repository.dart';
import 'package:xuma/feautures/login/domain/usecases/delete_user_profile_usecase.dart';
import 'package:xuma/feautures/login/domain/usecases/get_user_profile_usecase.dart';
import 'package:xuma/feautures/login/domain/usecases/save_user_profile_usecase.dart';
import 'package:xuma/feautures/login/domain/usecases/update_activity_progress_usecase.dart';
import 'package:xuma/feautures/login/presentation/cubit/user_profile_cubit.dart';

// Imports de autenticación
import 'package:xuma/feautures/auth/data/repositories/auth_repository_impl.dart';
import 'package:xuma/feautures/auth/domain/repositories/auth_repository.dart';
import 'package:xuma/feautures/auth/domain/usecases/login_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/logout_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/update_activity_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/check_session_validity_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/create_account_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/delete_account_usecase.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  print('🚀 INJECTION: Inicializando dependencias...');

  // External - Flutter Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );

  // Data sources - Registrar la implementación correctamente
  sl.registerLazySingleton<SecureStorageDataSource>(
    () => SecureStorageDataSourceImpl(secureStorage: sl<FlutterSecureStorage>()),
  );

  // User Profile - Repositories
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(dataSource: sl<SecureStorageDataSource>()),
  );

  // User Profile - Use cases
  sl.registerLazySingleton<SaveUserProfileUseCase>(() => SaveUserProfileUseCase(sl<UserProfileRepository>()));
  sl.registerLazySingleton<GetUserProfileUseCase>(() => GetUserProfileUseCase(sl<UserProfileRepository>()));
  sl.registerLazySingleton<DeleteUserProfileUseCase>(() => DeleteUserProfileUseCase(sl<UserProfileRepository>()));
  sl.registerLazySingleton<UpdateActivityProgressUseCase>(() => UpdateActivityProgressUseCase(sl<UserProfileRepository>()));

  // User Profile - Cubit
  sl.registerFactory<UserProfileCubit>(() => UserProfileCubit(
    saveUserProfile: sl<SaveUserProfileUseCase>(),
    getUserProfile: sl<GetUserProfileUseCase>(),
    deleteUserProfile: sl<DeleteUserProfileUseCase>(),
    updateActivityProgress: sl<UpdateActivityProgressUseCase>(),
  ));

  // Authentication - Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl<SecureStorageDataSource>()),
  );
  
  // Authentication - Use cases
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<GetCurrentSessionUseCase>(() => GetCurrentSessionUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<UpdateActivityUseCase>(() => UpdateActivityUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<CheckSessionValidityUseCase>(() => CheckSessionValidityUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<CreateAccountUseCase>(() => CreateAccountUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<CheckAccountExistsUseCase>(() => CheckAccountExistsUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<DeleteAccountUseCase>(() => DeleteAccountUseCase(sl<AuthRepository>()));

  // Authentication - Cubit
  sl.registerFactory<AuthCubit>(() => AuthCubit(
    loginUseCase: sl<LoginUseCase>(),
    logoutUseCase: sl<LogoutUseCase>(),
    getCurrentSessionUseCase: sl<GetCurrentSessionUseCase>(),
    updateActivityUseCase: sl<UpdateActivityUseCase>(),
    checkSessionValidityUseCase: sl<CheckSessionValidityUseCase>(),
    createAccountUseCase: sl<CreateAccountUseCase>(),
    checkAccountExistsUseCase: sl<CheckAccountExistsUseCase>(),
    deleteAccountUseCase: sl<DeleteAccountUseCase>(),
  ));

  print('🚀 INJECTION: Dependencias inicializadas exitosamente');
}