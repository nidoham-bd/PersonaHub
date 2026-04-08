// A private class with a const constructor serves as a sentinel value,
// allowing copyWith to distinguish "argument not provided" from
// "argument explicitly set to null".
class _Undefined {
  const _Undefined();
}

const _undefined = _Undefined();

class AuthState {
  final bool isSignUpMode;
  final String? errorMessage;

  const AuthState({
    this.isSignUpMode = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isSignUpMode,
    Object? errorMessage = _undefined,
  }) {
    return AuthState(
      isSignUpMode: isSignUpMode ?? this.isSignUpMode,
      errorMessage: identical(errorMessage, _undefined)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  /// Convenience method to clear the error without a sentinel call site.
  AuthState clearError() => copyWith(errorMessage: null);
}