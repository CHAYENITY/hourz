import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_setup_model.freezed.dart';
part 'profile_setup_model.g.dart';

@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    @Default('') String addressLine,
    @Default('') String district,
    @Default('') String province,
    @Default('Thailand') String country,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) = _AddressModel;

  const AddressModel._();

  // ✅ Use code generation for fromJson
  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  // ✅ For API requests (create/update)
  Map<String, dynamic> toCreateJson() => {
    'address_line': addressLine,
    'district': district,
    'province': province,
    'country': country,
    if (postalCode != null) 'postal_code': postalCode,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };

  Map<String, dynamic> toUpdateJson() => toCreateJson();
}

@freezed
class ProfileSetupModel with _$ProfileSetupModel {
  const factory ProfileSetupModel({
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String bio,
    @Default('') String phoneNumber,
    @Default('') String additionalContact,
    AddressModel? address,
    // Local-only fields for UI (not sent to API)
    String? profileImagePath,
    String? citizenIdImagePath,
    @Default(false) bool isVerified,
    // Step tracking (local only)
    @Default(1)
    int currentStep,
    @Default(false)
    bool isStep1Complete,
    @Default(false)
    bool isStep2Complete,
    @Default(false)
    bool isStep3Complete,
  }) = _ProfileSetupModel;

  const ProfileSetupModel._();

  // ✅ Use code generation for fromJson
  factory ProfileSetupModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileSetupModelFromJson(json);

  // ✅ For POST requests (create profile)
  Map<String, dynamic> toCreateJson() {
    assert(address != null, 'address is required and cannot be null');
    return {
      'first_name': firstName,
      'last_name': lastName,
      'bio': bio,
      'phone_number': phoneNumber,
      'additional_contact': additionalContact,
      'address': address!.toCreateJson(),
    };
  }

  // ✅ For PUT/PATCH requests (update profile)
  Map<String, dynamic> toUpdateJson() => toCreateJson();

  // ✅ Computed properties for validation
  bool get canProceedToStep2 =>
      firstName.isNotEmpty && lastName.isNotEmpty && phoneNumber.isNotEmpty;

  bool get canProceedToStep3 =>
      canProceedToStep2 &&
      address != null &&
      address!.addressLine.isNotEmpty &&
      address!.district.isNotEmpty &&
      address!.province.isNotEmpty;

  bool get canComplete => canProceedToStep3 && citizenIdImagePath != null;
}
