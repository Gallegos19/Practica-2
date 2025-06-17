import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xuma/feautures/login/data/datasource/secure_storage_datasource.dart';
import 'package:xuma/feautures/login/data/repositories/user_profile_repository_impl.dart';
import 'package:xuma/feautures/login/domain/repositories/user_profile_repository.dart';
import 'package:xuma/feautures/login/domain/usecases/delete_user_profile_usecase.dart';
import 'package:xuma/feautures/login/domain/usecases/get_user_profile_usecase.dart';
import 'package:xuma/feautures/login/domain/usecases/save_user_profile_usecase.dart';
import 'package:xuma/feautures/login/domain/usecases/update_activity_progress_usecase.dart';
import 'package:xuma/feautures/login/presentation/cubit/user_profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
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

  // Data sources
  sl.registerLazySingleton<SecureStorageDataSource>(
    () => SecureStorageDataSourceImpl(secureStorage: sl()),
  );

  // Repositories
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(dataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SaveUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateActivityProgressUseCase(sl()));

  // Cubit
  sl.registerFactory(() => UserProfileCubit(
    saveUserProfile: sl(),
    getUserProfile: sl(),
    deleteUserProfile: sl(),
    updateActivityProgress: sl(),
  ));
}

