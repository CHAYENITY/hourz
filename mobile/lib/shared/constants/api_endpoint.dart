import 'package:hourz/shared/constants/env_config.dart';

class ApiEndpoints {
  static final String apiUrl = '${EnvConfig.serverUrl}/api';

  // Example endpoints
  static const String tasks = '/tasks';

  // 🔐 Auth endpoints
  static const String checkIdentifier = '/auth/check-identifier';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // 👤 User endpoints
  static const String currentUser = '/users/me';

  // Upload file endpoints
  static const String uploadProfileImage = '/uploads/profile-image';
  static const String uploadCitizenIdImage = '/uploads/citizen-id-image';
}
