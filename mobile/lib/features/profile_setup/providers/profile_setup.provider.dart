import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

import 'package:hourz/features/profile_setup/index.dart';
import 'package:hourz/features/auth/index.dart';
import 'package:hourz/shared/index.dart';

part 'profile_setup.provider.freezed.dart';

// ============================================================================
// Profile Setup Form State
// ============================================================================

@freezed
class ProfileSetupFormState with _$ProfileSetupFormState {
  const factory ProfileSetupFormState({
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String phoneNumber,
    String? bio,
    String? additionalContact,
    AddressModel? address,
    String? firstNameError,
    String? lastNameError,
    String? phoneNumberError,
    String? addressLineError,
    String? districtError,
    String? provinceError,
  }) = _ProfileSetupFormState;

  const ProfileSetupFormState._();

  bool get isValid => isStep1Valid && isStep2Valid && isStep3Valid;

  bool get isStep1Valid =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      phoneNumber.isNotEmpty &&
      firstNameError == null &&
      lastNameError == null &&
      phoneNumberError == null;

  bool get isStep2Valid {
    if (address == null) return false;
    return address!.addressLine.trim().isNotEmpty &&
        address!.district.isNotEmpty &&
        address!.province.isNotEmpty &&
        addressLineError == null &&
        districtError == null &&
        provinceError == null;
  }

  bool get isStep3Valid => isStep1Valid && isStep2Valid;
}

// ============================================================================
// Profile Setup Form Provider
// ============================================================================

final profileSetupFormProvider =
    StateNotifierProvider<ProfileSetupFormNotifier, ProfileSetupFormState>((
      ref,
    ) {
      return ProfileSetupFormNotifier(ref);
    });

class ProfileSetupFormNotifier extends StateNotifier<ProfileSetupFormState> {
  final Ref _ref;
  final Logger _logger = Logger();

  ProfileSetupFormNotifier(this._ref) : super(const ProfileSetupFormState());

  void setFirstName(String value) {
    state = state.copyWith(
      firstName: value,
      firstNameError: value.trim().isEmpty ? 'กรุณากรอกชื่อ' : null,
    );
  }

  void setLastName(String value) {
    state = state.copyWith(
      lastName: value,
      lastNameError: value.trim().isEmpty ? 'กรุณากรอกนามสกุล' : null,
    );
  }

  void setPhoneNumber(String value) {
    state = state.copyWith(
      phoneNumber: value,
      phoneNumberError: value.trim().isEmpty ? 'กรุณากรอกเบอร์โทร' : null,
    );
  }

  void setBio(String? value) {
    state = state.copyWith(bio: value);
  }

  void setAdditionalContact(String? value) {
    state = state.copyWith(additionalContact: value);
  }

  void setAddress({
    String? addressLine,
    String? district,
    String? province,
    double? latitude,
    double? longitude,
  }) {
    final current =
        state.address ??
        AddressModel(addressLine: '', district: '', province: '');
    final updated = current.copyWith(
      addressLine: addressLine ?? current.addressLine,
      district: district ?? current.district,
      province: province ?? current.province,
      latitude: latitude ?? current.latitude,
      longitude: longitude ?? current.longitude,
    );

    String? addressLineError;
    String? districtError;
    String? provinceError;
    if (updated.addressLine.trim().isEmpty) {
      addressLineError = 'กรุณากรอกที่อยู่';
    }
    if (updated.district.trim().isEmpty) {
      districtError = 'กรุณากรอกเขต/อำเภอ';
    }
    if (updated.province.trim().isEmpty) {
      provinceError = 'กรุณากรอกจังหวัด';
    }

    state = state.copyWith(
      address: updated,
      addressLineError: addressLineError,
      districtError: districtError,
      provinceError: provinceError,
    );
  }

  void phoneNumberError(String? error) {
    state = state.copyWith(phoneNumberError: error);
  }

  void reset() {
    state = const ProfileSetupFormState();
  }

  Future<bool> validateStep1() async {
    try {
      _ref.read(loadingProvider.notifier).startLoading('profile-setup');
      final authService = _ref.read(authServiceProvider);
      final request = CheckIdentifierRequest(phoneNumber: state.phoneNumber);
      final result = await authService.checkIdentifier(request);
      if (result.phoneNumberExists == true) {
        phoneNumberError('เบอร์นี้ถูกใช้งานแล้ว กรุณาใช้เบอร์อื่น');
        _logger.w('⚠️ Phone number already registered');
        return false;
      } else {
        phoneNumberError(null);
      }
    } catch (e) {
      if (e is ErrorResponse && e.statusCode == 400) {
        phoneNumberError('รูปแบบเบอร์ไม่ถูกต้อง');
      } else {
        phoneNumberError('ไม่สามารถตรวจสอบเบอร์ได้');
      }
      _logger.e('❌ Check identifier failed: $e');
      return false;
    } finally {
      _ref.read(loadingProvider.notifier).stopLoading('profile-setup');
    }
    return true;
  }

  Future<bool> submit({
    required String email,
    required String password,
    required String confirmPassword,
    required AuthService authService,
  }) async {
    // final valid1 = validateStep1();
    // final valid2 = validateStep2();
    // if (!valid1 || !valid2) return false;

    // if (state.address == null) return false;
    _ref.read(loadingProvider.notifier).startLoading('profile-setup');

    final req = RegisterRequest(
      email: email,
      phoneNumber: state.phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
      firstName: state.firstName,
      lastName: state.lastName,
      bio: state.bio,
      additionalContact: state.additionalContact,
      address: AddressRequest(
        addressLine: state.address!.addressLine,
        district: state.address!.district,
        province: state.address!.province,
        latitude: state.address!.latitude,
        longitude: state.address!.longitude,
      ),
    );

    try {
      await authService.register(req);
      return true;
    } catch (e) {
      // TODO: handle error, set error state if needed
      return false;
    } finally {
      _ref.read(loadingProvider.notifier).stopLoading('profile-setup');
    }
  }
}

final provinceListProvider = FutureProvider<List<Map<String, String>>>((
  ref,
) async {
  final service = ProfileSetupService();
  return await service.getProvinces();
});

final districtListProvider =
    FutureProvider.family<List<Map<String, String>>, String>((
      ref,
      provinceId,
    ) async {
      final service = ProfileSetupService();
      return await service.getDistricts(provinceId);
    });
