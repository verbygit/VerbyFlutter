class LoginState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool isLoading; // Added for loading state
  final bool isSignedIn; // Added for login success
  final String? error; // Added for general errors

  LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.isLoading = false, // Initialize new fields
    this.isSignedIn = false,
    this.error,
  });

  LoginState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool? isLoading,
    bool? isSignedIn,
    String? error,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      isLoading: isLoading ?? this.isLoading,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      error: error ?? this.error,
    );
  }
}
