import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<CheckAuthRequested>(_onCheckAuthRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthRequested(CheckAuthRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        emit(const AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); 
    try {
      await authRepository.login(event.email, event.password);
      emit(const AuthAuthenticated()); 
    } catch (e) {
      emit(const AuthError('Usuario o contraseña incorrectos.')); 
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthUnauthenticated()); 
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // 1. Creamos el usuario en NestJS
      await authRepository.register(event.email, event.password, event.name);
      
      // 2. Si el registro fue exitoso, hacemos el login automático para obtener el token
      await authRepository.login(event.email, event.password);
      
      // 3. ¡Navegamos al menú!
      emit(const AuthAuthenticated());
    } catch (e) {
      emit(const AuthError('Error al registrar: Es posible que el correo ya esté en uso.'));
    }
  }
}