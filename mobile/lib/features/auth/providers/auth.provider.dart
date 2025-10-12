import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hourz/features/auth/models/auth.model.dart';
import 'package:hourz/features/auth/services/auth.service.dart';
import 'package:hourz/shared/index.dart';
import 'package:hourz/shared/models/api.model.dart';
import 'package:logger/logger.dart';

// ============================================================================
// Auth Service Provider
// ============================================================================

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiProvider));
});

// ============================================================================
// Login Form State
// ============================================================================

@immutable
class LoginFormState {
  final String email;
  final String password;
  final bool obscurePassword;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  bool get isValid =>
      email.isNotEmpty &&
      email.contains('@') &&
      password.isNotEmpty &&
      password.length >= 8;
}

// ============================================================================
// Login Form Provider
// ============================================================================

final loginFormProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormState>((ref) {
      return LoginFormNotifier(ref);
    });

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Ref _ref;
  final Logger _logger = Logger();

  LoginFormNotifier(this._ref) : super(const LoginFormState());

  void setEmail(String email) {
    state = state.copyWith(email: email.trim().toLowerCase());
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> submit() async {
    if (!state.isValid) {
      _logger.w('⚠️ Login form is invalid');
      return false;
    }

    try {
      _ref.read(loadingProvider.notifier).startLoading('auth-login');

      final request = LoginRequest(
        email: state.email,
        password: state.password,
      );

      final authService = _ref.read(authServiceProvider);
      final token = await authService.login(request);

      // Save token to secure storage
      await _ref.read(tokenProvider.notifier).saveToken(token);

      _logger.d('✅ Login successful');
      return true;
    } catch (e) {
      _logger.e('❌ Login failed: $e');
      _ref
          .read(errorProvider.notifier)
          .handleError(
            'เข้าสู่ระบบไม่สำเร็จ กรุณาตรวจสอบอีเมลและรหัสผ่าน',
            context: 'login',
          );
      rethrow;
    } finally {
      _ref.read(loadingProvider.notifier).stopLoading('auth-login');
    }
  }

  void reset() {
    state = const LoginFormState();
  }
}

// ============================================================================
// Register Form State
// ============================================================================

@immutable
class RegisterFormState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool agreeToTerms;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  const RegisterFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.agreeToTerms = false,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
  });

  RegisterFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? agreeToTerms,
    String? emailError = 'KEEP_CURRENT',
    String? passwordError = 'KEEP_CURRENT',
    String? confirmPasswordError = 'KEEP_CURRENT',
  }) {
    return RegisterFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      emailError: emailError == 'KEEP_CURRENT' ? this.emailError : emailError,
      passwordError: passwordError == 'KEEP_CURRENT'
          ? this.passwordError
          : passwordError,
      confirmPasswordError: confirmPasswordError == 'KEEP_CURRENT'
          ? this.confirmPasswordError
          : confirmPasswordError,
    );
  }

  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      emailError == null &&
      passwordError == null &&
      confirmPasswordError == null &&
      agreeToTerms;
}

// ============================================================================
// Register Form Provider
// ============================================================================

final registerFormProvider =
    StateNotifierProvider<RegisterFormNotifier, RegisterFormState>((ref) {
      return RegisterFormNotifier(ref);
    });

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final Ref _ref;
  final Logger _logger = Logger();

  RegisterFormNotifier(this._ref) : super(const RegisterFormState());

  void setEmail(String email) {
    final trimmedEmail = email.trim().toLowerCase();
    setEmailError(null);
    state = state.copyWith(email: trimmedEmail);
  }

  void setPassword(String password) {
    if (password.length < 6) {
      setPasswordError('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร');
    } else if (state.confirmPassword.isNotEmpty &&
        state.confirmPassword != password) {
      setPasswordError('รหัสผ่านไม่ตรงกัน');
    } else {
      setPasswordError(null);
    }
    state = state.copyWith(password: password);
  }

  void setConfirmPassword(String confirmPassword) {
    if (confirmPassword != state.password) {
      setConfirmPasswordError('รหัสผ่านไม่ตรงกัน');
    } else {
      setConfirmPasswordError(null);
    }
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  void setAgreeToTerms(bool agree) {
    state = state.copyWith(agreeToTerms: agree);
  }

  void setEmailError(String? error) {
    state = state.copyWith(emailError: error);
  }

  void setPasswordError(String? error) {
    state = state.copyWith(passwordError: error);
  }

  void setConfirmPasswordError(String? error) {
    state = state.copyWith(confirmPasswordError: error);
  }

  Future<bool> submit() async {
    // Check email duplicate before allow submit
    final trimmedEmail = state.email.trim().toLowerCase();
    if (trimmedEmail.isNotEmpty && trimmedEmail.contains('@')) {
      try {
        final authService = _ref.read(authServiceProvider);
        final request = CheckIdentifierRequest(email: trimmedEmail);
        final result = await authService.checkIdentifier(request);
        if (result.emailExists == true) {
          setEmailError('อีเมลนี้ถูกใช้งานแล้ว กรุณาใช้อีเมลอื่น');
          _logger.w('⚠️ Email already registered');
          return false;
        } else {
          setEmailError(null);
        }
      } catch (e) {
        // Check for error code 400 (bad request)
        if (e is ApiException && e.statusCode == 400) {
          setEmailError('รูปแบบอีเมลไม่ถูกต้อง');
        } else {
          setEmailError('ไม่สามารถตรวจสอบอีเมลได้');
        }
        _logger.e('❌ Check identifier failed: $e');
        return false;
      }
    }
    if (!state.isValid) {
      _logger.w('⚠️ Register form is invalid');
      return false;
    }
    _logger.d('✅ Register form is valid');
    return true;
  }

  /// Get registration data to pass to profile setup
  Map<String, String> getRegistrationData() {
    return {'email': state.email, 'password': state.password};
  }
}

// ============================================================================
// Auth State Provider (For Google Sign In & General Auth)
// ============================================================================

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final Logger _logger = Logger();

  AuthNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> loginWithGoogle() async {
    try {
      _ref.read(loadingProvider.notifier).startLoading('auth-google');
      state = const AsyncValue.loading();

      // TODO: Implement Google Sign In
      _logger.w('⚠️ Google Sign In not implemented yet');

      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      _ref
          .read(errorProvider.notifier)
          .handleError(
            'Google Sign In ยังไม่พร้อมใช้งาน',
            context: 'google-signin',
          );

      state = const AsyncValue.data(null);
    } catch (e) {
      _logger.e('❌ Google Sign In failed: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    } finally {
      _ref.read(loadingProvider.notifier).stopLoading('auth-google');
    }
  }

  Future<void> logout() async {
    try {
      final authService = _ref.read(authServiceProvider);
      await authService.logout();
    } catch (e) {
      _logger.e('❌ Logout API failed: $e');
    } finally {
      await _ref.read(tokenProvider.notifier).clearToken();
      _logger.d('✅ User logged out');
    }
  }

  Future<String> checkAuthStatus() async {
    try {
      await _ref.read(tokenProvider.notifier).loadToken();

      final isAuthenticated = _ref.read(isAuthenticatedProvider);

      if (isAuthenticated) {
        _logger.d('✅ User is authenticated');
        return '/dashboard';
      } else {
        _logger.d('❌ User is not authenticated');
        return '/login';
      }
    } catch (e) {
      _logger.e('❌ Check auth status failed: $e');
      return '/login';
    }
  }
}
