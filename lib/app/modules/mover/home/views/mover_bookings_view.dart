import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'mover_payment_dialog.dart';

class MoverBookingsView extends StatefulWidget {
  const MoverBookingsView({super.key});

  @override
  State<MoverBookingsView> createState() => _MoverBookingsViewState();
}

class _MoverBookingsViewState extends State<MoverBookingsView> {
  int _bookingFilter = 0; // 0: Created, 1: Active, 2: Completed, 3: Cancelled
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchParcelsForFilter(_bookingFilter);
  }

  Future<List<Map<String, dynamic>>> _fetchParcelsForFilter(int filter) async {
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    Map<String, dynamic> resp;
    if (filter == 0) {
      resp = await api.fetchPendingParcels(page: 1, pageSize: 20);
    } else if (filter == 1) {
      resp = await api.fetchOnwayParcels(page: 1, pageSize: 20);
    } else if (filter == 2) {
      resp = await api.fetchDeliveredParcels(page: 1, pageSize: 20);
    } else {
      resp = await api.fetchCancelledParcels(page: 1, pageSize: 20);
    }

    final results = resp['results'];
    if (results is List) {
      return results.cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  void _setFilter(int idx) {
    if (_bookingFilter == idx) return;
    setState(() {
      _bookingFilter = idx;
      _future = _fetchParcelsForFilter(idx);
    });
  }

  Widget pill(String label, int idx) {
    final selected = _bookingFilter == idx;
    return GestureDetector(
      onTap: () => _setFilter(idx),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.white10,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget bookingCard({
    required String title,
    required String when,
    required String from,
    required String to,
    required String price,
    required String status,
    required String paymentStatus,
    int? parcelId,
    VoidCallback? onCancel,
    VoidCallback? onTrack,
    VoidCallback? onPay,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: AppColors.accent,
                  size: 18.w,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12.w,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          when,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                price,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14.w,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  from,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.flag, size: 14.w, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  to,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.black12, height: 1),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: $status',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
              // Use Wrap to avoid overflow when buttons are wide on small screens
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  // Active tab: track only
                  if (onTrack != null && _bookingFilter == 1)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: onTrack,
                      child: Text('Track', style: TextStyle(fontSize: 14.sp)),
                    ),
                  // Created tab: cancel only
                  if (_bookingFilter == 0)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        side: BorderSide(
                          color: Colors.redAccent.withOpacity(0.6),
                        ),
                      ),
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Cancel booking'),
                            content: const Text(
                              'Are you sure you want to cancel this booking?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Get.back();
                                  if (onCancel != null) {
                                    onCancel();
                                  }
                                },
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  if (onPay != null &&
                      _bookingFilter == 2 &&
                      !_isPaymentComplete(paymentStatus))
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: onPay,
                      child: Text('Pay', style: TextStyle(fontSize: 14.sp)),
                    ),
                  if (_bookingFilter == 2)
                    OutlinedButton(
                      onPressed: () => Get.snackbar(
                        'Receipt',
                        'Open receipt (not implemented)',
                        backgroundColor: AppColors.accent,
                        colorText: Colors.white,
                      ),
                      child: Text(
                        'View Receipt',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Bookings',
            style: TextStyle(
              color: AppColors.textHeadline,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                pill('Created', 0),
                SizedBox(width: 8.w),
                pill('Active', 1),
                SizedBox(width: 8.w),
                pill('Completed', 2),
                SizedBox(width: 8.w),
                pill('Cancelled', 3),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Failed to load bookings',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          snapshot.error.toString(),
                          style: const TextStyle(color: Colors.white38),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        OutlinedButton(
                          onPressed: () => setState(() {
                            _future = _fetchParcelsForFilter(_bookingFilter);
                          }),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      'No bookings found',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final title =
                        'Booking ${item['parcel_id'] ?? '#'} - ${item['vehicle_type'] ?? ''}';
                    final when = _formatWhen(
                      dateStr: item['pickup_date']?.toString(),
                      timeStr: item['pickup_time']?.toString(),
                    );
                    final from = item['pickup_address']?.toString() ?? '';
                    final to = item['drop_address']?.toString() ?? '';
                    final price = _formatPrice(item['price']);
                    final status = item['delivery_status']?.toString() ?? '';
                    final parcelId = item['id'];
                    final paymentStatus =
                        item['payment_status']?.toString().toLowerCase() ?? '';
                    final isComplete = _isPaymentComplete(paymentStatus);

                    return bookingCard(
                      title: title,
                      when: when,
                      from: from,
                      to: to,
                      price: price,
                      status: status,
                      paymentStatus: paymentStatus,
                      parcelId: parcelId,
                      onTrack: () {
                        Get.toNamed(
                          Routes.MOVER_PARCEL_TRACKING,
                          arguments: {
                            'title': title,
                            'from': from,
                            'to': to,
                            'status': status,
                            'parcelId': parcelId,
                            'driverPhone': '(555) 123-4567',
                          },
                        );
                      },
                      onPay: isComplete
                          ? null
                          : () {
                              Get.dialog(
                                MoverPaymentDialog(
                                  parcelId:
                                      item['parcel_id']?.toString() ??
                                      parcelId?.toString() ??
                                      '',
                                  price: item['price']?.toString() ?? '0',
                                  bookingArgs: {
                                    'scheduledDate': item['pickup_date'],
                                    'scheduledTime': item['pickup_time'],
                                    'from': from,
                                    'to': to,
                                  },
                                ),
                                barrierDismissible: false,
                              );
                            },
                      onCancel: () async {
                        try {
                          final parsedId = int.tryParse(
                            parcelId?.toString() ?? '',
                          );
                          if (parsedId == null) {
                            Get.snackbar(
                              'Error',
                              'Invalid booking ID',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          final api = Get.isRegistered<ApiService>()
                              ? Get.find<ApiService>()
                              : ApiService();
                          await api.cancelParcel(id: parsedId);
                          Get.snackbar(
                            'Success',
                            'Booking cancelled successfully',
                            backgroundColor: AppColors.accent,
                            colorText: Colors.black,
                          );
                          // Refresh the list
                          setState(() {
                            _future = _fetchParcelsForFilter(_bookingFilter);
                          });
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            e.toString(),
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatWhen({String? dateStr, String? timeStr}) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.tryParse(dateStr);
      String dateOut;
      if (date != null) {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        dateOut = '${months[date.month - 1]} ${date.day}, ${date.year}';
      } else {
        dateOut = dateStr;
      }

      if (timeStr != null && timeStr.isNotEmpty) {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          final h = parts[0].padLeft(2, '0');
          final m = parts[1].padLeft(2, '0');
          return '$dateOut · $h:$m';
        }
        return '$dateOut · $timeStr';
      }
      return dateOut;
    } catch (_) {
      return [
        dateStr,
        timeStr,
      ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    }
  }

  String _formatPrice(Object? raw) {
    if (raw == null) return '';
    final str = raw.toString();
    return '\$$str';
  }

  bool _isPaymentComplete(String paymentStatus) {
    final normalized = paymentStatus.toLowerCase();
    return normalized == 'complete' ||
        normalized == 'completed' ||
        normalized == 'paid' ||
        normalized == 'succeeded' ||
        normalized == 'success';
  }
}
