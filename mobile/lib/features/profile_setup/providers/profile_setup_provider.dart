import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hourz/shared/index.dart';
import 'package:hourz/features/auth/models/auth.model.dart';
import 'package:hourz/features/auth/providers/auth.provider.dart';
import '../models/profile_setup_model.dart';
import '../services/profile_setup_service.dart';

// ============================================================================
// Service Provider
// ============================================================================
final profileSetupServiceProvider = Provider<ProfileSetupService>((ref) {
  return ProfileSetupService(ref.read(apiProvider));
});

// ============================================================================
// Form State Provider - Using ProfileSetupModel as form state
// ============================================================================
final profileSetupProvider =
    StateNotifierProvider<ProfileSetupNotifier, ProfileSetupModel>((ref) {
      return ProfileSetupNotifier(ref);
    });

class ProfileSetupNotifier extends StateNotifier<ProfileSetupModel> {
  ProfileSetupNotifier(this._ref) : super(const ProfileSetupModel());
  final Ref _ref;

  // Store registration data from auth form
  String? _registrationEmail;
  String? _registrationPassword;

  void setRegistrationData(String email, String password) {
    _registrationEmail = email;
    _registrationPassword = password;
  }

  // ============================================================================
  // Step 1: Basic Information
  // ============================================================================
  void updateBasicInfo({
    String? firstName,
    String? lastName,
    String? bio,
    String? phoneNumber,
    String? additionalContact,
  }) {
    state = state.copyWith(
      firstName: firstName ?? state.firstName,
      lastName: lastName ?? state.lastName,
      bio: bio ?? state.bio,
      phoneNumber: phoneNumber ?? state.phoneNumber,
      additionalContact: additionalContact ?? state.additionalContact,
    );
  }

  void updateProfileImage(String? imagePath) {
    state = state.copyWith(profileImagePath: imagePath);
  }

  void completeStep1() {
    if (state.canProceedToStep2) {
      state = state.copyWith(isStep1Complete: true, currentStep: 2);
    }
  }

  // ============================================================================
  // Step 2: Location
  // ============================================================================
  void updateAddress({
    String? addressLine,
    String? district,
    String? province,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) {
    final currentAddress = state.address ?? const AddressModel();
    final updatedAddress = currentAddress.copyWith(
      addressLine: addressLine ?? currentAddress.addressLine,
      district: district ?? currentAddress.district,
      province: province ?? currentAddress.province,
      country: country ?? currentAddress.country,
      postalCode: postalCode ?? currentAddress.postalCode,
      latitude: latitude ?? currentAddress.latitude,
      longitude: longitude ?? currentAddress.longitude,
    );
    state = state.copyWith(address: updatedAddress);
  }

  void confirmCurrentLocation(double latitude, double longitude) {
    final currentAddress = state.address ?? const AddressModel();
    state = state.copyWith(
      address: currentAddress.copyWith(
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  void completeStep2() {
    if (state.canProceedToStep3) {
      state = state.copyWith(isStep2Complete: true, currentStep: 3);
    }
  }

  // ============================================================================
  // Step 3: Citizen ID Verification
  // ============================================================================
  void updateCitizenIdImage(String? imagePath) {
    state = state.copyWith(citizenIdImagePath: imagePath);
  }

  void completeStep3() {
    if (state.canComplete) {
      state = state.copyWith(isStep3Complete: true, isVerified: true);
    }
  }

  // ============================================================================
  // Navigation
  // ============================================================================
  void goToStep(int step) {
    if (step >= 1 && step <= 3) {
      state = state.copyWith(currentStep: step);
    }
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  // ============================================================================
  // Submit Profile
  // ============================================================================
  Future<bool> submitProfile() async {
    // Validate registration data
    if (_registrationEmail == null || _registrationPassword == null) {
      _ref
          .read(errorProvider.notifier)
          .handleError(
            'ข้อมูลการลงทะเบียนไม่ครบถ้วน กรุณาเริ่มต้นใหม่',
            context: 'submitProfile',
          );
      return false;
    }

    try {
      _ref.read(loadingProvider.notifier).startLoading('submit-profile');

      final authService = _ref.read(authServiceProvider);
      final service = _ref.read(profileSetupServiceProvider);

      // Upload profile image if exists
      if (state.profileImagePath != null) {
        await service.uploadProfileImage(state.profileImagePath!);
      }

      // Upload citizen ID image if exists
      if (state.citizenIdImagePath != null) {
        await service.uploadCitizenIdImage(state.citizenIdImagePath!);
      }

      // Create complete registration request
      final registerRequest = RegisterRequest(
        email: _registrationEmail!,
        password: _registrationPassword!,
        confirmPassword: _registrationPassword!,
        phoneNumber: state.phoneNumber,
        firstName: state.firstName,
        lastName: state.lastName,
        bio: state.bio.isEmpty ? null : state.bio,
        additionalContact: state.additionalContact.isEmpty
            ? null
            : state.additionalContact,
        address: AddressRequest(
          addressLine: state.address?.addressLine ?? '',
          district: state.address?.district ?? '',
          province: state.address?.province ?? '',
          country: state.address?.country ?? 'Thailand',
          postalCode: state.address?.postalCode,
          latitude: state.address?.latitude,
          longitude: state.address?.longitude,
        ),
      );

      // Submit final registration with all data
      await authService.register(registerRequest);

      return true;
    } catch (e) {
      _ref
          .read(errorProvider.notifier)
          .handleError('ลงทะเบียนไม่สำเร็จ: $e', context: 'submitProfile');
      return false;
    } finally {
      _ref.read(loadingProvider.notifier).stopLoading('submit-profile');
    }
  }

  // ============================================================================
  // Reset state
  // ============================================================================
  void reset() {
    state = const ProfileSetupModel();
    _registrationEmail = null;
    _registrationPassword = null;
  }
}

// ============================================================================
// Helper Providers - For provinces and districts
// ============================================================================
final provincesProvider = FutureProvider<List<Map<String, String>>>((
  ref,
) async {
  final service = ref.read(profileSetupServiceProvider);
  return await service.getProvinces();
});

final districtsProvider =
    FutureProvider.family<List<Map<String, String>>, String>((
      ref,
      provinceId,
    ) async {
      final service = ref.read(profileSetupServiceProvider);
      return await service.getDistricts(provinceId);
    });
