import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HelperHistoryContent extends StatefulWidget {
  const HelperHistoryContent({super.key});

  @override
  State<HelperHistoryContent> createState() => _HelperHistoryContentState();
}

class _HelperHistoryContentState extends State<HelperHistoryContent> {
  late Future<List<Map<String, dynamic>>> _ongoingFuture;
  late Future<List<Map<String, dynamic>>> _acceptedFuture;
  late Future<List<Map<String, dynamic>>> _completedFuture;

  @override
  void initState() {
    super.initState();
    _ongoingFuture = _fetchOngoingParcels();
    _acceptedFuture = _fetchAcceptedParcels();
    _completedFuture = _fetchCompletedParcels();
  }

  Future<List<Map<String, dynamic>>> _fetchOngoingParcels() async {
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    final response = await api.fetchOnwayParcels(page: 1, pageSize: 50);
    final results = response['results'];
    if (results is List) {
      return results
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> _fetchAcceptedParcels() async {
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    final response = await api.fetchAcceptedParcels(page: 1, pageSize: 50);
    final results = response['results'];
    if (results is List) {
      return results
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> _fetchCompletedParcels() async {
    final api = Get.isRegistered<ApiService>()
        ? Get.find<ApiService>()
        : ApiService();

    final response = await api.fetchDeliveredParcels(page: 1, pageSize: 50);
    final results = response['results'];
    if (results is List) {
      return results
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  void _openHelperParcel(Map<String, dynamic> item, String sectionTitle) {
    final pickup = (item['pickup_address'] ?? '').toString();
    final dropoff = (item['drop_address'] ?? '').toString();
    final routeSummary = (pickup.isNotEmpty || dropoff.isNotEmpty)
        ? '$pickup → $dropoff'
        : '';

    final deliveryStatus = (item['delivery_status'] ?? '').toString();
    final normalizedSection = sectionTitle.toLowerCase();
    final status = deliveryStatus.isNotEmpty
        ? deliveryStatus
        : (normalizedSection == 'completed'
              ? 'Completed'
              : normalizedSection == 'accepted'
              ? 'Accepted'
              : 'Ongoing');

    final eta =
        'Est. ${(item['estimated_time_minutes'] ?? 'N/A').toString()} mins';
    final deliveryId =
        (item['parcel_id'] ?? item['id'] ?? item['tracking_number'] ?? '')
            .toString();

    Get.toNamed(
      Routes.HELPER_DELIVERY_DETAIL,
      arguments: {
        'routeSummary': routeSummary,
        'deliveryId': deliveryId,
        'distance': '${(item['distance'] ?? 'N/A').toString()} miles',
        'eta': eta,
        'status': status,
        'pickupAddress': pickup,
        'dropoffAddress': dropoff,
        'pickupContact': (item['pickup_user_name'] ?? '').toString(),
        'pickupTime': (item['pickup_time'] ?? '').toString(),
        'dropoffTime': (item['dropoff_time'] ?? '').toString(),
        'orderSummary': const <String>[],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget section(String title, List<Map<String, dynamic>> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Column(
            children: items.map((item) {
              final from = (item['pickup_address'] ?? '').toString();
              final to = (item['drop_address'] ?? '').toString();
              final deliveryStatus = (item['delivery_status'] ?? title)
                  .toString();
              final eta =
                  'Est. ${(item['estimated_time_minutes'] ?? 'N/A').toString()} mins';

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: InkWell(
                  onTap: () => _openHelperParcel(item, title),
                  child: Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.local_shipping_outlined,
                                color: AppColors.accent,
                                size: 22.w,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Pickup',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                        color: const Color(0xFF333333),
                                      ),
                                      child: Text(
                                        deliveryStatus,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  from,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.south,
                                      color: Colors.white24,
                                      size: 14.w,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Drop-off',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white24,
                                      size: 20.w,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  to,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  eta,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: FutureBuilder<List<List<Map<String, dynamic>>>>(
          future: Future.wait([
            _ongoingFuture,
            _acceptedFuture,
            _completedFuture,
          ]),
          builder: (context, snapshot) {
            final ongoing = snapshot.data != null
                ? snapshot.data![0]
                : <Map<String, dynamic>>[];
            final accepted = snapshot.data != null
                ? snapshot.data![1]
                : <Map<String, dynamic>>[];
            final completed = snapshot.data != null
                ? snapshot.data![2]
                : <Map<String, dynamic>>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ongoing Deliveries',
                  style: TextStyle(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                if (snapshot.connectionState == ConnectionState.waiting)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24.h),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (snapshot.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'Failed to load deliveries',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  )
                else if (ongoing.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'No ongoing deliveries found.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  section('Ongoing', ongoing),
                SizedBox(height: 18.h),
                Text(
                  'Accepted Deliveries',
                  style: TextStyle(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                if (snapshot.connectionState == ConnectionState.waiting)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24.h),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (snapshot.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'Failed to load deliveries',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  )
                else if (accepted.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'No accepted deliveries found.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  section('Accepted', accepted),
                SizedBox(height: 18.h),
                Text(
                  'Completed Deliveries',
                  style: TextStyle(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                if (snapshot.connectionState == ConnectionState.waiting)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24.h),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (snapshot.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'Failed to load deliveries',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  )
                else if (completed.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'No completed deliveries found.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  section('Completed', completed),
                SizedBox(height: 36.h),
              ],
            );
          },
        ),
      ),
    );
  }
}
