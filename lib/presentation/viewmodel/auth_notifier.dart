import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../data/repository/auth_repository.dart';
import '../state/auth_state.dart';

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  FutureOr<AuthState> build() {
    return const AuthState();
  }

  void toggleAuthMode() {
    final current = state.valueOrNull ?? const AuthState();
    state = AsyncData(
      current.copyWith(
        isSignUpMode: !current.isSignUpMode,
        errorMessage: null,
      ),
    );
  }

  Future<void> submitAuth({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final current = state.valueOrNull ?? const AuthState();

    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);

      if (current.isSignUpMode) {
        await repository.signUp(
          email: email,
          password: password,
          displayName: displayName!,
        );
      } else {
        await repository.signIn(email: email, password: password);
      }

      // A clean AsyncData with no errorMessage signals success to the
      // UI listener, which then navigates to HomeScreen.
      state = AsyncData(AuthState(isSignUpMode: current.isSignUpMode));
    } on AuthException catch (error) {
      state = AsyncData(current.copyWith(errorMessage: error.message));
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          errorMessage: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  void clearError() {
    final current = state.valueOrNull ?? const AuthState();
    state = AsyncData(current.clearError());
  }
}