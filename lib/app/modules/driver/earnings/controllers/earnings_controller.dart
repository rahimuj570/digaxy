import 'package:get/get.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:flutter/foundation.dart';

class EarningsController extends GetxController {
  final isLoading = false.obs;
  final loadError = ''.obs;

  final today = 0.0.obs;
  final week = 0.0.obs;
  final month = 0.0.obs;
  final lifetime = 0.0.obs;
  final payoutsRequested = 0.0.obs;
  final pending = 0.0.obs;
  final lastPayoutDate = ''.obs;
  final paymentMethod = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadEarnings();
  }

  Future<void> loadEarnings() async {
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    try {
      isLoading.value = true;
      loadError.value = '';

      final response = await api.fetchUserEarnings();
      debugPrint('[EARNINGS] /user/earnings response: $response');

      final earningsMap = response['earnings'] is Map
          ? Map<String, dynamic>.from(response['earnings'])
          : <String, dynamic>{};
      final commissionMap = response['commission'] is Map
          ? Map<String, dynamic>.from(response['commission'])
          : <String, dynamic>{};

      today.value = _toAmount(earningsMap['today']) ?? 0.0;
      week.value = _toAmount(earningsMap['this_week']) ?? 0.0;
      month.value = _toAmount(earningsMap['this_month']) ?? 0.0;
      lifetime.value = _toAmount(earningsMap['lifetime']) ?? 0.0;

      payoutsRequested.value =
          _toAmount(commissionMap['total_payouts_requested']) ?? 0.0;
      pending.value = _toAmount(commissionMap['total_pending_payouts']) ?? 0.0;
      lastPayoutDate.value =
          (commissionMap['last_payout_date'] ?? '--').toString().trim().isEmpty
          ? '--'
          : (commissionMap['last_payout_date']).toString();
      paymentMethod.value =
          (commissionMap['payment_method'] ?? '--').toString().trim().isEmpty
          ? '--'
          : (commissionMap['payment_method']).toString();
    } catch (_) {
      loadError.value = 'Failed to load earnings';
    } finally {
      isLoading.value = false;
    }
  }

  double? _toAmount(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    final normalized = text.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  void requestPayout() {
    // navigate to payout page
    Get.toNamed(Routes.DRIVER_PAYOUT);
  }
}
