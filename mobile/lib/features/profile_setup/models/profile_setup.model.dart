import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_setup.model.freezed.dart';
part 'profile_setup.model.g.dart';

@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    required String addressLine,
    required String district,
    required String province,
    double? latitude,
    double? longitude,
  }) = _AddressModel;

  const AddressModel._();

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toCreateJson() => {
    'address_line': addressLine,
    'district': district,
    'province': province,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };

  Map<String, dynamic> toUpdateJson() => toCreateJson();
}

@freezed
class ProfileSetupModel with _$ProfileSetupModel {
  const factory ProfileSetupModel({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? bio,
    String? additionalContact,
    required AddressModel address,
  }) = _ProfileSetupModel;

  const ProfileSetupModel._();

  factory ProfileSetupModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileSetupModelFromJson(json);

  Map<String, dynamic> toCreateJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    if (bio != null) 'bio': bio,
    if (additionalContact != null) 'additional_contact': additionalContact,
    'address': address.toCreateJson(),
  };

  Map<String, dynamic> toUpdateJson() => toCreateJson();
}
