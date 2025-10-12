import 'package:hourz/shared/constants/api_endpoint.dart';
import 'package:hourz/shared/models/index.dart';
import 'package:hourz/shared/services/api.service.dart';

/// Profile Setup Service
/// Handles profile image upload, citizen ID upload, and location data
class ProfileSetupService {
  final ApiService _apiService;

  ProfileSetupService(this._apiService);

  // ============================================================================
  // Image Upload Operations
  // ============================================================================

  /// Upload profile image
  Future<CreateResponse> uploadProfileImage(String filePath) async {
    return await _apiService.createFormData(
      ApiEndpoints.uploadProfileImage,
      {},
      fileFields: {'file': filePath},
      fromJson: CreateResponse.fromJson,
    );
  }

  /// Upload citizen ID image for verification
  Future<CreateResponse> uploadCitizenIdImage(String filePath) async {
    return await _apiService.createFormData(
      ApiEndpoints.uploadCitizenIdImage,
      {},
      fileFields: {'file': filePath},
      fromJson: CreateResponse.fromJson,
    );
  }

  // ============================================================================
  // Location Data Operations (Mock Data - Replace with real API)
  // ============================================================================

  /// Get list of provinces
  /// TODO: Replace with real API endpoint
  Future<List<Map<String, String>>> getProvinces() async {
    // Mock data - should be replaced with API call
    return [
      {'id': '1', 'name': 'กรุงเทพมหานคร'},
      {'id': '2', 'name': 'สงขลา'},
      {'id': '3', 'name': 'เชียงใหม่'},
      {'id': '4', 'name': 'ภูเก็ต'},
      {'id': '5', 'name': 'ขอนแก่น'},
      {'id': '6', 'name': 'นครราชสีมา'},
    ];
  }

  /// Get list of districts by province ID
  /// TODO: Replace with real API endpoint
  Future<List<Map<String, String>>> getDistricts(String provinceId) async {
    // Mock data - should be replaced with API call
    if (provinceId == '2') {
      return [
        {'id': '1', 'name': 'หาดใหญ่'},
        {'id': '2', 'name': 'เมืองสงขลา'},
        {'id': '3', 'name': 'สะเดา'},
        {'id': '4', 'name': 'นาทวี'},
      ];
    } else if (provinceId == '1') {
      return [
        {'id': '1', 'name': 'บางรัก'},
        {'id': '2', 'name': 'ปทุมวัน'},
        {'id': '3', 'name': 'ห้วยขวาง'},
        {'id': '4', 'name': 'คลองเตย'},
      ];
    }
    return [
      {'id': '1', 'name': 'อื่นๆ'},
    ];
  }
}
