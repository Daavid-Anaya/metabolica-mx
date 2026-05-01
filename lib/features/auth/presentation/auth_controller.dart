import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

enum AuthStatus { authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.loading);

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState.initial()) {
    _init();
  }

  void _init() {
    final user = _repository.currentUser;
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = AuthState(status: AuthStatus.unauthenticated);
    }

    _repository.authStateChanges.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        state = AuthState(status: AuthStatus.authenticated, user: session?.user);
      } else if (event == AuthChangeEvent.signedOut) {
        state = AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.signIn(email: email, password: password);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: 'Ocurrió un error inesperado');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String municipality,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.signUp(
        email: email,
        password: password,
        name: name,
        municipality: municipality,
      );
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: 'Ocurrió un error inesperado');
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
