import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

enum AuthStatus { authenticated, unauthenticated, loading, error }

class AppAuthState {
  final AuthStatus status;
  final sb.User? user;
  final String? errorMessage;

  AppAuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AppAuthState.initial() => AppAuthState(status: AuthStatus.loading);

  AppAuthState copyWith({
    AuthStatus? status,
    sb.User? user,
    String? errorMessage,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AppAuthState.initial()) {
    _init();
  }

  void _init() {
    final user = _repository.currentUser;
    if (user != null) {
      state = AppAuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = AppAuthState(status: AuthStatus.unauthenticated);
    }

    _repository.authStateChanges.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == sb.AuthChangeEvent.signedIn || event == sb.AuthChangeEvent.tokenRefreshed) {
        state = AppAuthState(status: AuthStatus.authenticated, user: session?.user);
      } else if (event == sb.AuthChangeEvent.signedOut) {
        state = AppAuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.signIn(email: email, password: password);
    } on sb.AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: 'Error: ${e.toString()}');
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
    } on sb.AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: 'Error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
