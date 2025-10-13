class ProfileSetupService {
  // ============================================================================
  // Image Upload Operations
  // ============================================================================
  Future<List<Map<String, String>>> getProvinces() async {
    return [
      {'id': '1', 'name': 'กรุงเทพมหานคร'},
      {'id': '2', 'name': 'สงขลา'},
      {'id': '3', 'name': 'เชียงใหม่'},
      {'id': '4', 'name': 'ภูเก็ต'},
      {'id': '5', 'name': 'ขอนแก่น'},
      {'id': '6', 'name': 'นครราชสีมา'},
    ];
  }

  Future<List<Map<String, String>>> getDistricts(String provinceId) async {
    switch (provinceId) {
      case '1':
        return [
          {'id': '1', 'name': 'บางรัก'},
          {'id': '2', 'name': 'ปทุมวัน'},
          {'id': '3', 'name': 'ห้วยขวาง'},
          {'id': '4', 'name': 'คลองเตย'},
        ];
      case '2':
        return [
          {'id': '1', 'name': 'หาดใหญ่'},
          {'id': '2', 'name': 'เมืองสงขลา'},
          {'id': '3', 'name': 'สะเดา'},
          {'id': '4', 'name': 'นาทวี'},
        ];

      default:
        return [
          {'id': '1', 'name': 'อื่นๆ'},
        ];
    }
  }
}
