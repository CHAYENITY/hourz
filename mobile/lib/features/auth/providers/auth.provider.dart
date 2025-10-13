import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:hourz/features/auth/models/auth.model.dart';
import 'package:hourz/features/auth/services/auth.service.dart';
import 'package:hourz/shared/index.dart';

part 'auth.provider.freezed.dart';

// ============================================================================
// Auth Service Provider
// ============================================================================

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiProvider));
});

// ============================================================================
// Login Form State
// ============================================================================

@freezed
class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String email,
    @Default('') String password,
    @Default(true) bool obscurePassword,
  }) = _LoginFormState;

  const LoginFormState._();

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

@freezed
class RegisterFormState with _$RegisterFormState {
  const factory RegisterFormState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default(true) bool obscurePassword,
    @Default(true) bool obscureConfirmPassword,
    @Default(false) bool agreeToTerms,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
  }) = _RegisterFormState;

  const RegisterFormState._();

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
        _ref.read(loadingProvider.notifier).startLoading('auth-register');
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
        if (e is ErrorResponse && e.statusCode == 400) {
          setEmailError('รูปแบบอีเมลไม่ถูกต้อง');
        } else {
          setEmailError('ไม่สามารถตรวจสอบอีเมลได้');
        }
        _logger.e('❌ Check identifier failed: $e');
        return false;
      } finally {
        _ref.read(loadingProvider.notifier).stopLoading('auth-register');
      }
    }
    if (!state.isValid) {
      _logger.w('⚠️ Register form is invalid');
      return false;
    }
    _logger.d('✅ Register form is valid');
    return true;
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

  Future<void> loginWithGoogle() async {}

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
