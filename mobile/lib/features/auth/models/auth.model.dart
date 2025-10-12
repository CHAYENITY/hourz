import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.model.freezed.dart';
part 'auth.model.g.dart';

@freezed
class CheckIdentifierRequest with _$CheckIdentifierRequest {
  const factory CheckIdentifierRequest({String? email, String? phoneNumber}) =
      _CheckIdentifierRequest;

  const CheckIdentifierRequest._();
  factory CheckIdentifierRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckIdentifierRequestFromJson(json);

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (email != null) params['email'] = email!;
    if (phoneNumber != null) params['phone_number'] = phoneNumber!;
    return params;
  }
}

@freezed
class AddressRequest with _$AddressRequest {
  const factory AddressRequest({
    required String addressLine,
    required String district,
    required String province,
    @Default('Thailand') String country,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) = _AddressRequest;

  factory AddressRequest.fromJson(Map<String, dynamic> json) =>
      _$AddressRequestFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? bio,
    String? additionalContact,
    required AddressRequest address,
  }) = _RegisterRequest;

  const RegisterRequest._();
  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    'email': email,
    'phone_number': phoneNumber,
    'password': password,
    'first_name': firstName,
    'last_name': lastName,
    if (bio != null) 'bio': bio,
    if (additionalContact != null) 'additional_contact': additionalContact,
    'address': address.toJson(),
  };

  bool get isPasswordMatch => password == confirmPassword;
}

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  const LoginRequest._();
  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  // OAuth2 Password Flow format
  Map<String, dynamic> toFormData() => {
    'grant_type': 'password',
    'username': email,
    'password': password,
    'scope': '',
    'client_id': '',
    'client_secret': '',
  };
}

@freezed
class CheckIdentifierResponse with _$CheckIdentifierResponse {
  const factory CheckIdentifierResponse({
    bool? emailExists,
    bool? phoneNumberExists,
  }) = _CheckIdentifierResponse;

  factory CheckIdentifierResponse.fromJson(Map<String, dynamic> json) =>
      CheckIdentifierResponse(
        emailExists: json['email_exists'] as bool?,
        phoneNumberExists: json['phone_number_exists'] as bool?,
      );
}

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String accessToken,
    required String refreshToken,
    @Default('bearer') String tokenType,
  }) = _LoginResponse;

  const LoginResponse._();
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
class RefreshTokenResponse with _$RefreshTokenResponse {
  const factory RefreshTokenResponse({
    required String accessToken,
    @Default('bearer') String tokenType,
  }) = _RefreshTokenResponse;

  const RefreshTokenResponse._();
  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
}
