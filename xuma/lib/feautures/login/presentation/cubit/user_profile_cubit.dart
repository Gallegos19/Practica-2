import 'package:bloc/bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/save_user_profile_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/delete_user_profile_usecase.dart';
import '../../domain/usecases/update_activity_progress_usecase.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final SaveUserProfileUseCase saveUserProfile;
  final GetUserProfileUseCase getUserProfile;
  final DeleteUserProfileUseCase deleteUserProfile;
  final UpdateActivityProgressUseCase updateActivityProgress;

  UserProfile? _currentProfile;

  UserProfileCubit({
    required this.saveUserProfile,
    required this.getUserProfile,
    required this.deleteUserProfile,
    required this.updateActivityProgress,
  }) : super(UserProfileInitial());

  UserProfile? get currentProfile => _currentProfile;
  bool get hasProfile => _currentProfile != null;

  Future<void> loadProfile() async {
    emit(UserProfileLoading());
    try {
      _currentProfile = await getUserProfile();
      emit(UserProfileLoaded(profile: _currentProfile));
    } catch (e) {
      emit(UserProfileError(message: e.toString()));
    }
  }

  Future<void> saveProfile({
    required String nombre,
    required String correoElectronico,
    required int edad,
    required String nivelEducativo,
    required String ubicacionGeografica,
  }) async {
    print('🚀 DEBUG CUBIT: Iniciando saveProfile...');
    print(
        '🚀 DEBUG CUBIT: Datos recibidos - Nombre: $nombre, Email: $correoElectronico');

    emit(UserProfileLoading());
    try {
      final profile = UserProfile(
        nombre: nombre.trim(),
        correoElectronico: correoElectronico.trim().toLowerCase(),
        edad: edad,
        nivelEducativo: nivelEducativo,
        progresoActividades: _currentProfile?.progresoActividades ?? {},
        ubicacionGeografica: ubicacionGeografica,
      );

      print('🚀 DEBUG CUBIT: Perfil creado en memoria: ${profile.nombre}');
      print('🚀 DEBUG CUBIT: Llamando saveUserProfile...');

      await saveUserProfile(profile);

      print('🚀 DEBUG CUBIT: ✅ saveUserProfile completado');

      _currentProfile = profile;
      print('🚀 DEBUG CUBIT: _currentProfile actualizado');

      emit(UserProfileSaved());
      print('🚀 DEBUG CUBIT: Emitido UserProfileSaved');

      emit(UserProfileLoaded(profile: _currentProfile));
      print('🚀 DEBUG CUBIT: Emitido UserProfileLoaded');
    } catch (e) {
      print('🚀 DEBUG CUBIT: ❌ Error en saveProfile: $e');
      emit(UserProfileError(message: e.toString()));
    }
  }

  Future<void> updateProgress(String actividad, double progreso) async {
    emit(UserProfileLoading());
    try {
      await updateActivityProgress(actividad, progreso);
      await loadProfile(); // Recargar para obtener los datos actualizados
    } catch (e) {
      emit(UserProfileError(message: e.toString()));
    }
  }

  Future<void> removeProfile() async {
    emit(UserProfileLoading());
    try {
      await deleteUserProfile();
      _currentProfile = null;
      emit(UserProfileDeleted());
      emit(const UserProfileLoaded(profile: null));
    } catch (e) {
      emit(UserProfileError(message: e.toString()));
    }
  }
}
