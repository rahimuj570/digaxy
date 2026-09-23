import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';
import '../../../../services/api/api_service.dart';
import '../../../../models/driver_signup_data.dart';
import '../../../../services/websocket/websocket_bootstrap_service.dart';

class AuthController extends GetxController {
  AuthController({required ApiService api}) : _api = api;

  final ApiService _api;
  final box = GetStorage();

  var loading = false.obs;

  /// Login method that may throw ApiException for 403 pending applications
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool navigate = true,
  }) async {
    try {
      loading.value = true;
      final selectedRole = (box.read('user_role') as String?)?.toLowerCase();
      final response = await _api.login(email: email, password: password);
      final serverRole = _extractNormalizedRoleFromAuthResponse(response);
      _persistAuthSession(response);

      if (serverRole != null) {
        // Server role is the source of truth. Overwrite selected role.
        box.write('user_role', serverRole);
        if (selectedRole != null && selectedRole.isNotEmpty) {
          if (selectedRole != serverRole) {
            Get.snackbar(
              'Role mismatch',
              'Your account is $serverRole. Redirecting…',
              snackPosition: SnackPosition.TOP,
            );
          }
        }
      }
      box.write('is_logged_in', true);

      final wsBootstrap = Get.isRegistered<WebSocketBootstrapService>()
          ? Get.find<WebSocketBootstrapService>()
          : Get.put(WebSocketBootstrapService(), permanent: true);
      await wsBootstrap.connectForAuthenticatedUser();

      if (navigate) {
        _navigateToRoleHome();
      }

      return {'success': true, 'message': null, 'data': response};
    } finally {
      loading.value = false;
    }
  }

  void _navigateToRoleHome() {
    // Navigate to next screen or home based on the authoritative role.
    final role = (box.read('user_role') as String?)?.toLowerCase();
    if (role == 'driver') {
      Get.offAllNamed(Routes.DRIVER_HOME);
    } else if (role == 'mover') {
      Get.offAllNamed(Routes.MOVER_HOME);
    } else if (role == 'helper') {
      Get.offAllNamed(Routes.HELPER_HOME);
    } else {
      // fallback
      Get.offAllNamed(Routes.LANDING_ONBOARDING);
    }
  }

  String? _extractNormalizedRoleFromAuthResponse(
    Map<String, dynamic> response,
  ) {
    final data = response['data'];
    if (data is! Map) return null;

    String? backendRole;
    final user = data['user'];
    if (user is Map) {
      final r = user['role'];
      if (r is String) backendRole = r;
    }

    // Some backends may return role at the data-level.
    backendRole ??= (data['role'] is String) ? (data['role'] as String) : null;
    if (backendRole == null || backendRole.trim().isEmpty) return null;

    final normalized = backendRole.trim().toLowerCase();

    // Map backend roles to app roles.
    if (normalized == 'driver') return 'driver';
    if (normalized == 'helper') return 'helper';

    // Customer role maps to the mover-side UI in this app.
    if (normalized == 'customer' || normalized == 'mover') return 'mover';

    return null;
  }

  void _persistAuthSession(Map<String, dynamic> response) {
    // Store raw response for flexibility while backend schema stabilizes.
    box.write('auth_session', response);

    // Try to extract common token fields from either top-level or `data`.
    final data = (response['data'] is Map<String, dynamic>)
        ? (response['data'] as Map<String, dynamic>)
        : response;

    final access = data['access'] ?? data['access_token'] ?? data['token'];
    final refresh = data['refresh'] ?? data['refresh_token'];

    if (access is String && access.isNotEmpty) {
      box.write('access_token', access);
    }
    if (refresh is String && refresh.isNotEmpty) {
      box.write('refresh_token', refresh);
    }
  }

  Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      loading.value = true;
      final storedRole = (box.read('user_role') as String?)?.toLowerCase();

      // Use different endpoints based on role
      // Use different endpoints based on role
      if (storedRole == 'mover') {
        // Use dedicated customer (mover) signup endpoint
        await _api.customerSignup(
          username: username,
          email: email,
          password: password,
        );
      } else if (storedRole == 'helper') {
        // Use dedicated helper signup endpoint
        await _api.helperSignup(
          username: username,
          email: email,
          password: password,
        );
      } else {
        // Use generic signup endpoint for driver (should use driverSignup instead but keeping fallback)
        final apiRole = storedRole == 'driver' ? 'Driver' : 'Helper';
        await _api.signup(
          username: username,
          email: email,
          password: password,
          role: apiRole,
        );
      }

      // After signup, send OTP to the user's email for verification.
      await _api.sendOtp(email: email);
    } finally {
      loading.value = false;
    }
  }

  Future<void> helperSignup({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      loading.value = true;
      await _api.helperSignup(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      // After signup, send OTP to the user's email for verification.
      await _api.sendOtp(email: email);
    } finally {
      loading.value = false;
    }
  }

  /// Signup for driver with additional information and file uploads
  Future<void> driverSignup({required DriverSignupData data}) async {
    try {
      loading.value = true;

      // Call driver signup endpoint with multipart data
      await _api.driverSignup(
        username: data.username,
        email: data.email,
        password: data.password,
        driverLicenseNumber: data.driverLicenseNumber,
        driverVehicleNumber: data.driverVehicleNumber,
        vehicleType: data.vehicleType,
        files: data.toFiles(),
      );

      // After signup, send OTP to the user's email for verification.
      await _api.sendOtp(email: data.email);
    } finally {
      loading.value = false;
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      loading.value = true;
      final response = await _api.verifyOtp(email: email, otp: otp);

      // Mark user as logged in after OTP verification
      box.write('is_logged_in', true);

      // Try to extract and persist role from the response
      final role = _extractNormalizedRoleFromAuthResponse(response);
      if (role != null) {
        box.write('user_role', role);
      }

      // Persist auth session (tokens, etc)
      _persistAuthSession(response);

      final wsBootstrap = Get.isRegistered<WebSocketBootstrapService>()
          ? Get.find<WebSocketBootstrapService>()
          : Get.put(WebSocketBootstrapService(), permanent: true);
      await wsBootstrap.connectForAuthenticatedUser();
    } finally {
      loading.value = false;
    }
  }

  Future<void> sendOtp({required String email}) async {
    try {
      loading.value = true;
      await _api.sendOtp(email: email);
    } finally {
      loading.value = false;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      loading.value = true;
      await _api.resetPassword(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } finally {
      loading.value = false;
    }
  }
}
