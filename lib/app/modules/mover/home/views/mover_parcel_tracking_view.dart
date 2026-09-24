import 'package:digaxy/services/api/api_service.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MoverParcelTrackingView extends StatefulWidget {
  const MoverParcelTrackingView({super.key});

  @override
  State<MoverParcelTrackingView> createState() =>
      _MoverParcelTrackingViewState();
}

class _MoverParcelTrackingViewState extends State<MoverParcelTrackingView> {
  bool _isLoading = false;

  String _title = 'Parcel Tracking';
  String _from = 'Pickup Location';
  String _to = 'Delivery Location';
  String _status = 'In Transit';
  dynamic _parcelId;

  String _driverName = 'Driver Assigned';
  String _driverPhone = '';
  String? _driverImage;
  String _driverRating = '5.0';
  String _vehicleType = '';
  String? _pickupProofImage;
  String? _dropoffProofImage;
  String _estimatedDelivery = '';

  String _parcelType = '';
  String _price = '';
  String _paymentStatus = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final Map args = (Get.arguments is Map) ? (Get.arguments as Map) : {};

    _title = (args['title'] ?? 'Parcel Tracking').toString();
    _from = (args['from'] ?? 'Pickup Location').toString();
    _to = (args['to'] ?? 'Delivery Location').toString();
    _status = (args['status'] ?? 'In Transit').toString();
    _parcelId = args['parcelId'] ?? args['parcel_id'];

    if (args['driverName'] != null &&
        args['driverName'].toString().trim().isNotEmpty) {
      _driverName = args['driverName'].toString().trim();
    }
    if (args['driverPhone'] != null &&
        args['driverPhone'].toString().trim().isNotEmpty) {
      _driverPhone = args['driverPhone'].toString().trim();
    }

    if (args['item'] is Map) {
      _parseDetails(Map<String, dynamic>.from(args['item']));
    }

    final numericId = int.tryParse(_parcelId?.toString() ?? '');
    if (numericId != null) {
      _fetchParcelDetails(numericId);
    }
  }

  Future<void> _fetchParcelDetails(int id) async {
    setState(() => _isLoading = true);
    try {
      final api = Get.isRegistered<ApiService>()
          ? Get.find<ApiService>()
          : ApiService();
      final data = await api.fetchParcelDetails(id: id);
      if (mounted) {
        setState(() {
          _parseDetails(data);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _normalizeImageUrl(dynamic rawUrl) {
    if (rawUrl == null) return '';
    final str = rawUrl.toString().trim();
    if (str.isEmpty || str == 'null') return '';
    if (str.startsWith('http://') || str.startsWith('https://')) return str;
    const baseOrigin = 'http://10.10.29.119:8300';
    if (str.startsWith('/')) return '$baseOrigin$str';
    return '$baseOrigin/$str';
  }

  void _parseDetails(Map<String, dynamic> data) {
    if ((data['pickup_address'] ?? '').toString().trim().isNotEmpty) {
      _from = data['pickup_address'].toString().trim();
    }
    if ((data['drop_address'] ?? '').toString().trim().isNotEmpty) {
      _to = data['drop_address'].toString().trim();
    }
    if ((data['delivery_status'] ?? '').toString().trim().isNotEmpty) {
      _status = data['delivery_status'].toString().trim();
    }
    if ((data['vehicle_type'] ?? '').toString().trim().isNotEmpty) {
      _vehicleType = data['vehicle_type'].toString().trim();
    }
    if ((data['percel_type'] ?? data['parcel_type'] ?? '')
        .toString()
        .trim()
        .isNotEmpty) {
      _parcelType = (data['percel_type'] ?? data['parcel_type'])
          .toString()
          .trim();
    }
    if ((data['payment_status'] ?? '').toString().trim().isNotEmpty) {
      _paymentStatus = data['payment_status'].toString().trim();
    }
    if (data['price'] != null) {
      _price = data['price'].toString().trim();
    }

    // Driver info resolution (from driver_info object or direct fields)
    if (data['driver_info'] is Map) {
      final dInfo = data['driver_info'] as Map;
      final fullName = (dInfo['full_name'] ?? dInfo['name'] ?? '').toString().trim();
      final username = (dInfo['username'] ?? '').toString().trim();
      final email = (dInfo['email'] ?? '').toString().trim();

      if (fullName.isNotEmpty && fullName != 'null') {
        _driverName = fullName;
      } else if (username.isNotEmpty && username != 'null') {
        _driverName = username;
      } else if (email.isNotEmpty && email != 'null') {
        _driverName = email;
      } else if (dInfo['id'] != null && dInfo['id'].toString() != 'null') {
        _driverName = 'Driver #${dInfo['id']}';
      }

      final phone = (dInfo['phone_number'] ?? dInfo['phone'] ?? '')
          .toString()
          .trim();
      if (phone.isNotEmpty && phone != 'null') {
        _driverPhone = phone;
      }

      if ((dInfo['vehicle_type'] ?? '').toString().trim().isNotEmpty &&
          dInfo['vehicle_type'].toString() != 'null') {
        _vehicleType = dInfo['vehicle_type'].toString().trim();
      }

      // Driver Image inside driver_info
      final img =
          dInfo['image'] ??
          dInfo['profile_image'] ??
          dInfo['avatar'] ??
          dInfo['photo'] ??
          dInfo['picture'] ??
          dInfo['profile_picture'] ??
          dInfo['driver_image'];
      if (img != null &&
          img.toString().trim().isNotEmpty &&
          img.toString() != 'null') {
        _driverImage = _normalizeImageUrl(img);
      }
    } else if (data['driver'] is Map) {
      final dMap = data['driver'] as Map;
      final fullName = (dMap['full_name'] ?? dMap['name'] ?? '').toString().trim();
      final username = (dMap['username'] ?? '').toString().trim();
      final email = (dMap['email'] ?? '').toString().trim();

      if (fullName.isNotEmpty && fullName != 'null') {
        _driverName = fullName;
      } else if (username.isNotEmpty && username != 'null') {
        _driverName = username;
      } else if (email.isNotEmpty && email != 'null') {
        _driverName = email;
      }
    } else if ((data['driver_name'] ?? '').toString().trim().isNotEmpty) {
      _driverName = data['driver_name'].toString().trim();
    } else if ((data['driver_user_name'] ?? '').toString().trim().isNotEmpty) {
      _driverName = data['driver_user_name'].toString().trim();
    } else if ((data['driver_email'] ?? '').toString().trim().isNotEmpty) {
      _driverName = data['driver_email'].toString().trim();
    }

    // Direct phone fallback
    if (_driverPhone.isEmpty) {
      if ((data['driver_phone'] ?? '').toString().trim().isNotEmpty) {
        _driverPhone = data['driver_phone'].toString().trim();
      } else if ((data['driver_phone_number'] ?? '')
          .toString()
          .trim()
          .isNotEmpty) {
        _driverPhone = data['driver_phone_number'].toString().trim();
      } else if (data['driver'] is Map &&
          (data['driver']['phone_number'] ?? '').toString().trim().isNotEmpty) {
        _driverPhone = data['driver']['phone_number'].toString().trim();
      } else if (data['driver'] is Map &&
          (data['driver']['phone'] ?? '').toString().trim().isNotEmpty) {
        _driverPhone = data['driver']['phone'].toString().trim();
      }
    }

    // Direct driver image fallback if not found in driver_info
    if (_driverImage == null || _driverImage!.isEmpty) {
      final img =
          data['driver_image'] ??
          data['driver_profile_image'] ??
          data['driver_avatar'] ??
          (data['driver'] is Map
              ? data['driver']['image'] ?? data['driver']['profile_image']
              : null);
      if (img != null &&
          img.toString().trim().isNotEmpty &&
          img.toString() != 'null') {
        _driverImage = _normalizeImageUrl(img);
      }
    }

    // Rating resolution (from driver_rating object or direct)
    if (data['driver_rating'] is Map) {
      final rMap = data['driver_rating'] as Map;
      final avg = rMap['average'];
      final count = int.tryParse(rMap['count']?.toString() ?? '') ?? 0;

      if (avg != null &&
          avg.toString().trim().isNotEmpty &&
          avg.toString() != 'null') {
        final avgNum = double.tryParse(avg.toString()) ?? 0.0;
        final avgStr = avgNum.toStringAsFixed(1);
        _driverRating = count > 0 ? '$avgStr ($count)' : avgStr;
      } else if (count > 0) {
        _driverRating = '0.0 ($count)';
      } else {
        _driverRating = '0.0';
      }
    } else if (data['driver_rating'] != null &&
        data['driver_rating'].toString().trim().isNotEmpty &&
        data['driver_rating'].toString() != 'null') {
      final avgNum = double.tryParse(data['driver_rating'].toString()) ?? 0.0;
      _driverRating = avgNum.toStringAsFixed(1);
    } else if (data['driver'] is Map &&
        data['driver']['rating'] != null &&
        data['driver']['rating'].toString().trim().isNotEmpty &&
        data['driver']['rating'].toString() != 'null') {
      final avgNum =
          double.tryParse(data['driver']['rating'].toString()) ?? 0.0;
      _driverRating = avgNum.toStringAsFixed(1);
    } else {
      _driverRating = '0.0';
    }

    // Proof Images
    if (data['pickup_images'] is List &&
        (data['pickup_images'] as List).isNotEmpty) {
      final firstImg = (data['pickup_images'] as List).first;
      if (firstImg is Map && firstImg['image'] != null) {
        _pickupProofImage = _normalizeImageUrl(firstImg['image']);
      }
    }

    if (data['dropoff_images'] is List &&
        (data['dropoff_images'] as List).isNotEmpty) {
      final firstImg = (data['dropoff_images'] as List).first;
      if (firstImg is Map && firstImg['image'] != null) {
        _dropoffProofImage = _normalizeImageUrl(firstImg['image']);
      }
    }

    // Estimated Delivery Time
    final pickupDate = (data['pickup_date'] ?? '').toString().trim();
    final pickupTime = (data['pickup_time'] ?? '').toString().trim();
    final estMinutes =
        (data['estimated_time_minutes'] ?? data['estimated_time'] ?? '')
            .toString()
            .trim();

    if (pickupDate.isNotEmpty || pickupTime.isNotEmpty) {
      _estimatedDelivery = [
        pickupDate,
        if (pickupTime.isNotEmpty) pickupTime,
      ].join(' · ');
    } else if (estMinutes.isNotEmpty && estMinutes != '--') {
      final mins = int.tryParse(estMinutes);
      if (mins != null) {
        _estimatedDelivery = mins >= 60
            ? '${mins ~/ 60} hr ${mins % 60} mins'
            : '$mins mins';
      } else {
        _estimatedDelivery = estMinutes;
      }
    } else {
      _estimatedDelivery = 'In Transit';
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').capitalizeFirst ?? status;
  }

  @override
  Widget build(BuildContext context) {
    final statusNorm = _status.toLowerCase();
    final isPickedUp =
        statusNorm.contains('onway') ||
        statusNorm.contains('on_the_way') ||
        statusNorm.contains('pickup') ||
        statusNorm.contains('picked') ||
        statusNorm.contains('transit') ||
        statusNorm.contains('delivered');
    final isInTransit =
        statusNorm.contains('onway') ||
        statusNorm.contains('on_the_way') ||
        statusNorm.contains('transit') ||
        statusNorm.contains('delivered');
    final isDelivered = statusNorm.contains('delivered');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Track Parcel',
          style: TextStyle(color: AppColors.textHeadline),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parcel Details Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _title,
                            style: TextStyle(
                              color: AppColors.textHeadline,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_price.isNotEmpty)
                          Text(
                            '\$$_price',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    if (_parcelId != null) ...[
                      Text(
                        'Parcel ID: $_parcelId',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            _formatStatus(_status),
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_parcelType.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Type: $_parcelType',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (_paymentStatus.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _paymentStatus.toLowerCase().contains(
                                        'comp',
                                      ) ||
                                      _paymentStatus.toLowerCase().contains(
                                        'paid',
                                      )
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Payment: $_paymentStatus',
                              style: TextStyle(
                                color:
                                    _paymentStatus.toLowerCase().contains(
                                          'comp',
                                        ) ||
                                        _paymentStatus.toLowerCase().contains(
                                          'paid',
                                        )
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Journey Timeline
              Text(
                'Journey',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),

              // Timeline Steps
              _buildTimelineStep(
                number: 1,
                title: 'Pickup Location',
                address: _from,
                status: isPickedUp ? 'Completed' : 'Pending',
                isCompleted: isPickedUp,
                isActive: !isPickedUp,
                proofImageUrl: _pickupProofImage,
                proofTitle: 'Pickup Proof',
              ),
              SizedBox(height: 8.h),

              _buildTimelineStep(
                number: 2,
                title: 'In Transit',
                address: 'On the way to destination',
                status: isDelivered
                    ? 'Completed'
                    : (isInTransit ? 'In Progress' : 'Pending'),
                isCompleted: isDelivered,
                isActive: isInTransit && !isDelivered,
              ),
              SizedBox(height: 8.h),

              _buildTimelineStep(
                number: 3,
                title: 'Delivery Location',
                address: _to,
                status: isDelivered ? 'Completed' : 'Pending',
                isCompleted: isDelivered,
                isActive: isDelivered,
                proofImageUrl: _dropoffProofImage,
                proofTitle: 'Delivery Proof',
              ),
              SizedBox(height: 32.h),

              // Driver Info Card (Dynamic with API data)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Driver Information',
                          style: TextStyle(
                            color: AppColors.textHeadline,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_vehicleType.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 13.sp,
                                  color: AppColors.accent,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  _vehicleType,
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Container(
                          width: 56.r,
                          height: 56.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withValues(alpha: 0.2),
                          ),
                          child: ClipOval(
                            child:
                                (_driverImage != null &&
                                    _driverImage!.isNotEmpty)
                                ? Image.network(
                                    _driverImage!,
                                    width: 56.r,
                                    height: 56.r,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.person,
                                          size: 32.sp,
                                          color: AppColors.accent,
                                        ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 32.sp,
                                    color: AppColors.accent,
                                  ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _driverName.isEmpty
                                    ? 'Driver Assigned'
                                    : _driverName,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _driverPhone.isEmpty
                                    ? 'Phone not available'
                                    : _driverPhone,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.star,
                              color: const Color(0xFFFFC107),
                              size: 18.sp,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _driverRating,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onPressed: () async {
                              if (_driverPhone.isEmpty) {
                                Get.snackbar(
                                  'Contact',
                                  'Driver phone number is not available',
                                  backgroundColor: Colors.grey[900],
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              try {
                                final cleanPhone = _driverPhone.replaceAll(
                                  RegExp(r'[^\d+\-]'),
                                  '',
                                );
                                final uri = Uri(
                                  scheme: 'tel',
                                  path: cleanPhone,
                                );
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  if (context.mounted) {
                                    _showPhoneErrorDialog(context, cleanPhone);
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  _showPhoneErrorDialog(context, _driverPhone);
                                }
                              }
                            },
                            icon: Icon(Icons.call, size: 18.sp),
                            label: const Text('Call'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              side: BorderSide(
                                color: AppColors.accent.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onPressed: () async {
                              if (_driverPhone.isEmpty) {
                                Get.snackbar(
                                  'Contact',
                                  'Driver phone number is not available',
                                  backgroundColor: Colors.grey[900],
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              try {
                                final cleanPhone = _driverPhone.replaceAll(
                                  RegExp(r'[^\d+\-]'),
                                  '',
                                );
                                final uri = Uri(
                                  scheme: 'sms',
                                  path: cleanPhone,
                                );
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  if (context.mounted) {
                                    _showSmsErrorDialog(context, cleanPhone);
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  _showSmsErrorDialog(context, _driverPhone);
                                }
                              }
                            },
                            icon: Icon(
                              Icons.message,
                              size: 18.sp,
                              color: AppColors.accent,
                            ),
                            label: Text(
                              'Chat',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Estimated Delivery
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Delivery',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _estimatedDelivery.isEmpty
                          ? 'In Transit'
                          : _estimatedDelivery,
                      style: TextStyle(
                        color: AppColors.textHeadline,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required int number,
    required String title,
    required String address,
    required String status,
    required bool isCompleted,
    required bool isActive,
    String? proofImageUrl,
    String? proofTitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.accent
                    : isActive
                    ? AppColors.accent
                    : Colors.white10,
                border: Border.all(
                  color: isActive ? AppColors.accent : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.black, size: 20.sp)
                    : Text(
                        '$number',
                        style: TextStyle(
                          color: isActive ? Colors.black : Colors.white38,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (number < 3)
              Container(
                width: 2.w,
                height: proofImageUrl != null && proofImageUrl.isNotEmpty
                    ? 64.h
                    : 28.h,
                color: isCompleted ? AppColors.accent : Colors.white10,
              ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                address,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.2)
                          : isActive
                          ? AppColors.accent.withValues(alpha: 0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.green
                            : isActive
                            ? AppColors.accent
                            : Colors.white38,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (proofImageUrl != null && proofImageUrl.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showImagePreviewDialog(
                        context,
                        proofImageUrl,
                        proofTitle ?? 'Proof Image',
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 13.sp,
                              color: AppColors.accent,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              proofTitle ?? 'View Proof',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImagePreviewDialog(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 200.h,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150.h,
                    color: Colors.white10,
                    child: const Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhoneErrorDialog(BuildContext context, String phoneNumber) {
    Get.dialog(
      AlertDialog(
        title: const Text('Call Driver'),
        content: Text(
          'Phone number: $phoneNumber\n\nNo phone app found. You can copy this number and call manually.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showSmsErrorDialog(BuildContext context, String phoneNumber) {
    Get.dialog(
      AlertDialog(
        title: const Text('Message Driver'),
        content: Text(
          'Phone number: $phoneNumber\n\nNo messaging app found. You can copy this number and message manually.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }
}
