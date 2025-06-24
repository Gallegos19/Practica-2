import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:xuma/feautures/auth/domain/entities/auth_session.dart';
import 'package:xuma/feautures/auth/domain/usecases/check_account_exist_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/check_session_validity_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/login_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/logout_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/update_activity_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/create_account_usecase.dart';
import 'package:xuma/feautures/auth/domain/usecases/delete_account_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentSessionUseCase getCurrentSessionUseCase;
  final UpdateActivityUseCase updateActivityUseCase;
  final CheckSessionValidityUseCase checkSessionValidityUseCase;
  final CreateAccountUseCase createAccountUseCase;
  final CheckAccountExistsUseCase checkAccountExistsUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  Timer? _sessionTimer;
  Timer? _warningTimer;
  AuthSession? _currentSession;

  AuthCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentSessionUseCase,
    required this.updateActivityUseCase,
    required this.checkSessionValidityUseCase,
    required this.createAccountUseCase,
    required this.checkAccountExistsUseCase,
    required this.deleteAccountUseCase,
  }) : super(AuthInitial());

  AuthSession? get currentSession => _currentSession;
  bool get isAuthenticated => _currentSession != null && 
      _currentSession!.isActive && 
      !_currentSession!.isExpired;

  // Verificar si existe una cuenta registrada
  Future<bool> checkIfAccountExists() async {
    try {
      return await checkAccountExistsUseCase();
    } catch (e) {
      print('🔐 CUBIT: Error al verificar cuenta existente: $e');
      return false;
    }
  }

  // Inicializar y verificar sesión existente
  Future<void> initializeAuth() async {
    emit(AuthLoading());
    try {
      print('🔐 CUBIT: Inicializando autenticación...');
      
      // Verificar si existe cuenta registrada
      final hasAccount = await checkIfAccountExists();
      if (!hasAccount) {
        print('🔐 CUBIT: No hay cuenta registrada');
        emit(AuthNoAccountRegistered());
        return;
      }
      
      _currentSession = await getCurrentSessionUseCase();
      
      if (_currentSession != null) {
        if (_currentSession!.isActive && !_currentSession!.isExpired) {
          print('🔐 CUBIT: Sesión válida encontrada');
          emit(AuthAuthenticated(session: _currentSession!));
          _startSessionTimer();
        } else {
          print('🔐 CUBIT: Sesión expirada o inactiva');
          await logout();
        }
      } else {
        print('🔐 CUBIT: No hay sesión previa, pero sí cuenta registrada');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('🔐 CUBIT: Error al inicializar: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  // Login
  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      print('🔐 CUBIT: Iniciando login...');
      
      _currentSession = await loginUseCase(username, password);
      
      print('🔐 CUBIT: Login exitoso');
      emit(AuthAuthenticated(session: _currentSession!));
      _startSessionTimer();
      
    } catch (e) {
      print('🔐 CUBIT: Error en login: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  // Crear cuenta
  Future<void> createAccount(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      print('🔐 CUBIT: Creando cuenta...');
      
      _currentSession = await createAccountUseCase(email, password, name);
      
      print('🔐 CUBIT: Cuenta creada exitosamente');
      emit(AuthAccountCreated(session: _currentSession!));
      _startSessionTimer();
      
    } catch (e) {
      print('🔐 CUBIT: Error al crear cuenta: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  // Logout
  Future<void> logout() async {
    print('🔐 CUBIT: Cerrando sesión...');
    
    _stopTimers();
    
    try {
      await logoutUseCase();
      _currentSession = null;
      
      // Verificar si aún existe cuenta registrada
      final hasAccount = await checkIfAccountExists();
      if (hasAccount) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthNoAccountRegistered());
      }
      
      print('🔐 CUBIT: Logout completado');
    } catch (e) {
      print('🔐 CUBIT: Error en logout: $e');
      _currentSession = null;
      emit(AuthUnauthenticated());
    }
  }

  // Actualizar actividad del usuario
  Future<void> updateActivity() async {
    if (_currentSession != null && _currentSession!.isActive) {
      try {
        await updateActivityUseCase();
        
        // Actualizar sesión local
        _currentSession = await getCurrentSessionUseCase();
        
        if (_currentSession != null && !_currentSession!.isExpired) {
          print('🔐 CUBIT: Actividad actualizada');
          _resetSessionTimer();
        } else {
          print('🔐 CUBIT: Sesión expirada durante actualización');
          await _handleSessionExpiry();
        }
      } catch (e) {
        print('🔐 CUBIT: Error al actualizar actividad: $e');
      }
    }
  }

  // Verificar validez de sesión
  Future<void> checkSessionValidity() async {
    if (_currentSession == null) return;
    
    try {
      final isValid = await checkSessionValidityUseCase();
      
      if (!isValid) {
        print('🔐 CUBIT: Sesión no válida detectada');
        await _handleSessionExpiry();
      }
    } catch (e) {
      print('🔐 CUBIT: Error al verificar sesión: $e');
    }
  }

  // Ir a crear cuenta
  void goToCreateAccount() {
    emit(AuthGoToCreateAccount());
  }

  // Volver al login
  void goToLogin() {
    emit(AuthUnauthenticated());
  }

  // Iniciar temporizador de sesión
  void _startSessionTimer() {
    _stopTimers();
    
    if (_currentSession == null) return;
    
    final timeoutDuration = Duration(minutes: _currentSession!.timeoutMinutes);
    final warningDuration = Duration(minutes: _currentSession!.timeoutMinutes - 2);
    
    print('🔐 CUBIT: Iniciando temporizador - Timeout en ${_currentSession!.timeoutMinutes} minutos');
    
    // Timer de advertencia (2 minutos antes de expirar)
    if (_currentSession!.timeoutMinutes > 2) {
      _warningTimer = Timer(warningDuration, () {
        if (_currentSession != null && !_currentSession!.isExpired) {
          print('🔐 CUBIT: Advertencia de expiración próxima');
          emit(AuthSessionWarning(
            session: _currentSession!,
            minutesRemaining: 2,
          ));
        }
      });
    }
    
    // Timer principal de expiración
    _sessionTimer = Timer(timeoutDuration, () {
      print('🔐 CUBIT: Timer de sesión expirado');
      _handleSessionExpiry();
    });
  }

  // Reiniciar temporizador de sesión
  void _resetSessionTimer() {
    if (_currentSession != null && _currentSession!.isActive) {
      _startSessionTimer();
    }
  }

  // Manejar expiración de sesión
  Future<void> _handleSessionExpiry() async {
    print('🔐 CUBIT: Manejando expiración de sesión');
    
    _stopTimers();
    
    try {
      await logoutUseCase();
    } catch (e) {
      print('🔐 CUBIT: Error durante limpieza de expiración: $e');
    }
    
    _currentSession = null;
    emit(const AuthSessionExpired());
    
    // Después de mostrar el mensaje, cambiar a no autenticado
    await Future.delayed(const Duration(seconds: 2));
    if (state is AuthSessionExpired) {
      emit(AuthUnauthenticated());
    }
  }

  // Detener todos los timers
  void _stopTimers() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _warningTimer?.cancel();
    _warningTimer = null;
    print('🔐 CUBIT: Timers detenidos');
  }

  // Extender sesión (cuando el usuario responde a la advertencia)
  Future<void> extendSession() async {
    if (_currentSession != null && !_currentSession!.isExpired) {
      await updateActivity();
      if (_currentSession != null) {
        emit(AuthAuthenticated(session: _currentSession!));
      }
    } else {
      await _handleSessionExpiry();
    }
  }

  @override
  Future<void> close() {
    _stopTimers();
    return super.close();
  }
}