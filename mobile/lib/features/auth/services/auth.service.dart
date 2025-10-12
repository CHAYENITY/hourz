import 'package:hourz/shared/models/api.model.dart';

import 'package:hourz/shared/index.dart';

import '../models/auth.model.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<CheckIdentifierResponse> checkIdentifier(
    CheckIdentifierRequest request,
  ) async {
    return await _apiService.get(
      ApiEndpoints.checkIdentifier,
      CheckIdentifierResponse.fromJson,
      queryParams: request.toQueryParams(),
    );
  }

  Future<CreateResponse> register(RegisterRequest request) async {
    return await _apiService.create(
      ApiEndpoints.register,
      request.toJson(),
      CreateResponse.fromJson,
    );
  }

  Future<TokenModel> login(LoginRequest request) async {
    final response = await _apiService.postFormUrlEncoded(
      ApiEndpoints.login,
      request.toFormData(),
      LoginResponse.fromJson,
    );

    return TokenModel.fromLoginResponse(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      tokenType: response.tokenType,
    );
  }

  Future<String> refreshToken(String refreshToken) async {
    final response = await _apiService.postFormUrlEncoded(
      ApiEndpoints.refreshToken,
      {},
      RefreshTokenResponse.fromJson,
    );
    return response.accessToken;
  }

  Future<void> logout() async {
    await _apiService.delete(ApiEndpoints.logout, '');
  }
}
