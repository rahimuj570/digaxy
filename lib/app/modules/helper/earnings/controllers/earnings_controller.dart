import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class HelperEarningsController extends GetxController {
  final isLoading = false.obs;
  final loadError = ''.obs;

  final today = 0.0.obs;
  final week = 0.0.obs;
  final month = 0.0.obs;
  final year = 0.0.obs;
  final lifetime = 0.0.obs;
  final pending = 0.0.obs;
  final totalDeliveriesAssisted = 0.obs;
  final lastPayoutDate = ''.obs;
  final paymentMethod = ''.obs;

  final earnings = <Map<String, String>>[].obs;

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

      final response = await api.fetchHelperEarnings();
      debugPrint('[HELPER_EARNINGS] response: $response');

      final totalEarnings = _toAmount(response['total_earnings']);
      if (totalEarnings != null) {
        lifetime.value = totalEarnings;
        today.value = totalEarnings;
        week.value = totalEarnings;
        month.value = totalEarnings;
        year.value = totalEarnings;
      }

      final totalAssisted = int.tryParse((response['total_deliveries_assisted'] ?? '').toString());
      if (totalAssisted != null) {
        totalDeliveriesAssisted.value = totalAssisted;
      }

      // Also parse traditional earnings map if returned as fallback
      final earningsMap = response['earnings'] is Map
          ? Map<String, dynamic>.from(response['earnings'])
          : <String, dynamic>{};
      final commissionMap = response['commission'] is Map
          ? Map<String, dynamic>.from(response['commission'])
          : <String, dynamic>{};

      if (earningsMap.isNotEmpty) {
        today.value = _toAmount(earningsMap['today']) ?? today.value;
        week.value = _toAmount(earningsMap['this_week']) ?? week.value;
        month.value = _toAmount(earningsMap['this_month']) ?? month.value;
        year.value = _toAmount(earningsMap['this_year']) ?? year.value;
        lifetime.value = _toAmount(earningsMap['lifetime']) ?? lifetime.value;
      }

      pending.value =
          _toAmount(commissionMap['total_pending_payouts']) ?? 0.0;
      lastPayoutDate.value =
          (commissionMap['last_payout_date'] ?? '').toString();
      paymentMethod.value =
          (commissionMap['payment_method'] ?? 'Bank Transfer').toString();

      // Parse recent_deliveries from /api/helper/earnings/
      final recentList = response['recent_deliveries'];
      if (recentList is List && recentList.isNotEmpty) {
        final parsed = <Map<String, String>>[];
        for (final item in recentList.whereType<Map>()) {
          final pId = (item['parcel_id'] ?? item['id'] ?? '').toString();
          final earned = (item['helper_earned'] ?? item['price'] ?? '').toString();
          final pickup = (item['pickup_address'] ?? '').toString();
          final drop = (item['drop_address'] ?? '').toString();
          final date = (item['date'] ?? item['created_at'] ?? '').toString();

          parsed.add({
            'jobId': pId.isNotEmpty ? '#$pId' : '#--',
            'date': _formatDate(date),
            'route': pickup.isNotEmpty && drop.isNotEmpty
                ? '$pickup → $drop'
                : 'Assisted Delivery',
            'amount': earned.isNotEmpty ? '\$$earned' : '',
          });
        }
        earnings.assignAll(parsed);
      }

      // Also try fetching wallet info for available balance
      try {
        final walletRes = await api.fetchWalletInfo();
        if (walletRes['data'] is Map) {
          final walletData = Map<String, dynamic>.from(walletRes['data']);
          final walletEarn = _toAmount(walletData['earn_money']);
          if (walletEarn != null) {
            lifetime.value = walletEarn;
          }
        }
      } catch (_) {}

    } catch (e) {
      debugPrint('[HELPER_EARNINGS] error: $e');
      loadError.value = 'Failed to load earnings';
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return 'Recent';
    try {
      final parsed = DateTime.parse(raw).toLocal();
      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      final hour24 = parsed.hour;
      final minute = parsed.minute.toString().padLeft(2, '0');
      final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
      final suffix = hour24 >= 12 ? 'PM' : 'AM';
      return '$day/$month $hour12:$minute $suffix';
    } catch (_) {
      return raw;
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
    Get.toNamed(Routes.HELPER_PAYOUT);
  }
}
