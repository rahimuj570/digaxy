import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/app_snackbar.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../models/parcel_data.dart';

class MoverScheduleView extends StatefulWidget {
  const MoverScheduleView({super.key});

  @override
  State<MoverScheduleView> createState() => _MoverScheduleViewState();
}

class _MoverScheduleViewState extends State<MoverScheduleView> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _submitting = false;

  // extras & payment state
  bool _extraHelper = false;
  final double _estimatedPrice = 75.0;

  // extras pricing
  final double _priceHelper = 20.0;

  void _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  void _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  double _extrasTotal() {
    var total = 0.0;
    if (_extraHelper) total += _priceHelper;
    return total;
  }

  double _totalPrice() {
    return _estimatedPrice + _extrasTotal();
  }

  Future<void> _onConfirm() async {
    if (_selectedDate == null || _selectedTime == null) {
      AppSnackbar.show(
        'Schedule required',
        'Please select date and time for your move',
      );
      return;
    }

    final rawArgs = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    final Map<String, dynamic> args = Map<String, dynamic>.from(rawArgs);

    // Build parcel data from accumulated draft
    final vehicleType = () {
      // Prefer explicit value if present, else derive from selection/service
      if (args['vehicle_type'] != null) return args['vehicle_type'].toString();
      if (args['vehicleType'] != null) return args['vehicleType'].toString();
      // Map vehicle index to backend values: Pickup, Van, Minibox, Bigbox
      const backendNames = ['Pickup', 'Van', 'Minibox', 'Bigbox'];
      final idx = args['selectedVehicleIndex'];
      if (idx is int && idx >= 0 && idx < backendNames.length) {
        return backendNames[idx];
      }
      return 'Pickup'; // Default fallback
    }();

    // Map load size to backend parcel_type (Small, Medium, Large)
    final loadSize = args['loadSize']?.toString() ?? 'Medium';

    final dateStr =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    // Convert to 24-hour format (HH:mm)
    final timeStr =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    final pickupLat = _toFixedCoord(args['pickupLat']);
    final pickupLng = _toFixedCoord(args['pickupLng']);
    final dropLat = _toFixedCoord(args['dropLat']);
    final dropLng = _toFixedCoord(args['dropLng']);

    final parcel = ParcelData(
      vehicleType: vehicleType,
      pickupDate: dateStr,
      pickupTime: timeStr,
      pickupUserName: (args['senderName'] ?? '').toString(),
      pickupPhoneNumber: (args['senderPhone'] ?? '').toString(),
      pickupAddress: (args['pickupAddress'] ?? '').toString(),
      dropUserName: (args['receiverName'] ?? '').toString(),
      dropPhoneNumber: (args['receiverPhone'] ?? '').toString(),
      dropAddress: (args['dropAddress'] ?? '').toString(),
      price: _totalPrice().toStringAsFixed(2),
      notes: (args['notes'] ?? '').toString(),
      specialInstructions: (args['specialInstructions'] ?? '').toString(),
      parcelType: loadSize, // Use load size as parcel type
      pickupLatitude: pickupLat,
      pickupLongitude: pickupLng,
      dropoffLatitude: dropLat,
      dropoffLongitude: dropLng,
      estimatedDistanceKm: (args['estimatedDistanceKm'] ?? '').toString(),
      estimatedTimeMinutes: (args['estimatedTimeMinutes'] ?? '').toString(),
      takeHelper: _extraHelper,
    );

    setState(() => _submitting = true);
    try {
      final api = Get.isRegistered<ApiService>()
          ? Get.find<ApiService>()
          : ApiService();
      final resp = await api.createParcel(parcelData: parcel.toJson());
      debugPrint('Create parcel response: $resp');

      // Extract parcel_id from response
      final parcelId = resp['parcel_id'] ?? resp['id'] ?? '';
      debugPrint('Extracted parcel_id: $parcelId');

      // Prepare booking args
      final bookingArgs = {
        ...args,
        'scheduledDate': dateStr,
        'scheduledTime': timeStr,
        'estimatedPrice': _estimatedPrice,
        'totalPrice': _totalPrice(),
        'paymentStatus': 'pending',
        'apiResponse': resp,
        'parcelId': parcelId,
      };

      // Payment will be collected after delivery; confirm booking directly.
      Get.offAllNamed(Routes.MOVER_BOOKING_CONFIRMED, arguments: bookingArgs);
    } catch (e) {
      AppSnackbar.error('Failed to create booking', e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _toFixedCoord(dynamic value) {
    final parsed = double.tryParse((value ?? '').toString());
    if (parsed == null) return null;
    return parsed.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    final Map args = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    final service = args['service'] ?? 'Pickup Truck';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Schedule Movers',
          style: TextStyle(color: AppColors.textHeadline),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Image.asset(
                      'assets/images/1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Select a convenient date and time for your move',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // date picker
            Text(
              'Choose Date',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.toLocal()}'.split(' ')[0]
                          : 'Select date',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    const Icon(
                      Icons.calendar_month,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // time picker
            Text(
              'Choose Time',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Select time',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    const Icon(Icons.access_time, color: AppColors.textPrimary),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // summary
            Text(
              'Summary',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: const Color(0xFFC08A10),
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Delivery Details',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Service
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Service',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Text(
                          service ?? '',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  Divider(color: Colors.grey.shade800, height: 1),
                  SizedBox(height: 12.h),

                  // Sender Details
                  Text(
                    'Sender Information',
                    style: TextStyle(
                      color: const Color(0xFFC08A10),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Name',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Text(
                          '${args['senderName'] ?? '-'}',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Phone',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Text(
                          '${args['senderPhone'] ?? '-'}',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Pickup Address',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        flex: 2,
                        child: Text(
                          '${args['pickupAddress'] ?? '-'}',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  Divider(color: Colors.grey.shade800, height: 1),
                  SizedBox(height: 12.h),

                  // Receiver Details
                  Text(
                    'Receiver Information',
                    style: TextStyle(
                      color: const Color(0xFFC08A10),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Name',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Text(
                          '${args['receiverName'] ?? '-'}',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Phone',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Text(
                          '${args['receiverPhone'] ?? '-'}',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Dropoff Address',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        flex: 2,
                        child: Text(
                          '${args['dropAddress'] ?? '-'}',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),
            Text(
              'Moving Details',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items: ${args['items'] ?? ''}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Load Size: ${args['loadSize'] ?? ''}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Notes: ${args['notes'] ?? ''}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),
            Text(
              'Extra Services',
              style: TextStyle(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _extraHelper,
                    onChanged: (v) => setState(() => _extraHelper = v),
                    title: Text(
                      'Helper',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    // subtitle: Text(
                    //   '\$${_priceHelper.toStringAsFixed(0)}',
                    //   style: TextStyle(color: AppColors.textSecondary),
                    // ),
                    activeThumbColor: const Color(0xFFC08A10),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),
            SizedBox(height: 24.h),
            PrimaryButton(
              label: 'Review & Confirm Booking',
              onPressed: _submitting ? null : _onConfirm,
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
