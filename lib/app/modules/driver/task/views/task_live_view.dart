import 'dart:io';

import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/task_live_controller.dart';

class TaskLiveView extends GetView<TaskLiveController> {
  const TaskLiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !controller.isMapFullscreen.value,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && controller.isMapFullscreen.value) {
          controller.isMapFullscreen.value = false;
        }
      },
      child: Obx(
        () => controller.isMapFullscreen.value
            ? _buildFullscreenMapView()
            : _buildNormalView(),
      ),
    );
  }

  Set<Marker> _buildMarkers({
    required bool hasCurrent,
    required double? currentLat,
    required double? currentLng,
    required bool hasPickup,
    required double? pickupLat,
    required double? pickupLng,
    required bool hasDrop,
    required double? dropLat,
    required double? dropLng,
    required bool onPickupStage,
  }) {
    final markers = <Marker>{};

    if (hasCurrent && currentLat != null && currentLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver_current'),
          position: LatLng(currentLat, currentLng),
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          zIndexInt: 10,
        ),
      );
    }

    if (hasPickup && pickupLat != null && pickupLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup_point'),
          position: LatLng(pickupLat, pickupLng),
          infoWindow: const InfoWindow(title: 'Pickup Point'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            onPickupStage ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    if (hasDrop && dropLat != null && dropLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff_point'),
          position: LatLng(dropLat, dropLng),
          infoWindow: const InfoWindow(title: 'Drop-off Point'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            !onPickupStage
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueViolet,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final polylines = <Polyline>{};
    if (controller.routePoints.length > 1) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('active_route'),
          color: AppColors.accent,
          width: 5,
          points: controller.routePoints.toList(),
        ),
      );
    }
    return polylines;
  }

  Widget _buildNormalView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.textHeadline),
        title: Obx(
          () => Text(
            controller.title.value,
            style: TextStyle(color: AppColors.textHeadline),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final currentLat = controller.currentLat.value;
          final currentLng = controller.currentLng.value;
          final onPickupStage = !controller.isPickedUp.value;
          final targetLat = onPickupStage
              ? controller.pickupLat.value
              : controller.dropLat.value;
          final targetLng = onPickupStage
              ? controller.pickupLng.value
              : controller.dropLng.value;
          final pickupLat = controller.pickupLat.value;
          final pickupLng = controller.pickupLng.value;
          final dropLat = controller.dropLat.value;
          final dropLng = controller.dropLng.value;

          final hasCurrent = currentLat != null && currentLng != null;
          final hasTarget = targetLat != null && targetLng != null;
          final hasPickup = pickupLat != null && pickupLng != null;
          final hasDrop = dropLat != null && dropLng != null;

          final markers = _buildMarkers(
            hasCurrent: hasCurrent,
            currentLat: currentLat,
            currentLng: currentLng,
            hasPickup: hasPickup,
            pickupLat: pickupLat,
            pickupLng: pickupLng,
            hasDrop: hasDrop,
            dropLat: dropLat,
            dropLng: dropLng,
            onPickupStage: onPickupStage,
          );

          final polylines = _buildPolylines();

          final mapCameraTarget = hasCurrent
              ? LatLng(currentLat, currentLng)
              : (hasTarget
                    ? LatLng(targetLat, targetLng)
                    : const LatLng(23.8103, 90.4125));

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMapContainer(
                  mapCameraTarget: mapCameraTarget,
                  markers: markers,
                  polylines: polylines,
                  hasCurrent: hasCurrent,
                  showFullscreenButton: true,
                ),
                SizedBox(height: 10.h),
                Text(
                  controller.navigationHint.value,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  controller.currentLocationLabel.value,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  controller.trackingLocationLabel.value,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.openDirections,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                    ),
                    icon: const Icon(Icons.directions_outlined),
                    label: Text(
                      controller.isPickedUp.value
                          ? 'Direction to Drop-off'
                          : 'Direction to Pickup',
                    ),
                  ),
                ),
                if (controller.isLoadingRoute.value) ...[
                  SizedBox(height: 6.h),
                  Text(
                    'Loading route...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
                SizedBox(height: 14.h),
                _metaRow(),
                SizedBox(height: 14.h),
                _locationContactCard(
                  title: 'Pickup Details',
                  icon: Icons.location_on,
                  iconColor: AppColors.accent,
                  address: controller.pickupAddress.value.isEmpty
                      ? 'Not available'
                      : controller.pickupAddress.value,
                  contactName: controller.pickupContactName.value,
                  contactPhone: controller.pickupContactPhone.value,
                ),
                SizedBox(height: 10.h),
                _locationContactCard(
                  title: 'Drop-off Details',
                  icon: Icons.location_on_outlined,
                  iconColor: Colors.orangeAccent,
                  address: controller.dropoffAddress.value.isEmpty
                      ? 'Not available'
                      : controller.dropoffAddress.value,
                  contactName: controller.dropContactName.value,
                  contactPhone: controller.dropContactPhone.value,
                ),
                if (controller.parcelType.value.isNotEmpty ||
                    controller.vehicleType.value.isNotEmpty ||
                    controller.price.value.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _parcelSummaryCard(),
                ],
                SizedBox(height: 14.h),
                _stageCard(onPickupStage),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFullscreenMapView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final currentLat = controller.currentLat.value;
        final currentLng = controller.currentLng.value;
        final onPickupStage = !controller.isPickedUp.value;
        final targetLat = onPickupStage
            ? controller.pickupLat.value
            : controller.dropLat.value;
        final targetLng = onPickupStage
            ? controller.pickupLng.value
            : controller.dropLng.value;
        final pickupLat = controller.pickupLat.value;
        final pickupLng = controller.pickupLng.value;
        final dropLat = controller.dropLat.value;
        final dropLng = controller.dropLng.value;

        final hasCurrent = currentLat != null && currentLng != null;
        final hasTarget = targetLat != null && targetLng != null;
        final hasPickup = pickupLat != null && pickupLng != null;
        final hasDrop = dropLat != null && dropLng != null;

        final markers = _buildMarkers(
          hasCurrent: hasCurrent,
          currentLat: currentLat,
          currentLng: currentLng,
          hasPickup: hasPickup,
          pickupLat: pickupLat,
          pickupLng: pickupLng,
          hasDrop: hasDrop,
          dropLat: dropLat,
          dropLng: dropLng,
          onPickupStage: onPickupStage,
        );

        final polylines = _buildPolylines();

        final mapCameraTarget = hasCurrent
            ? LatLng(currentLat, currentLng)
            : (hasTarget
                  ? LatLng(targetLat, targetLng)
                  : const LatLng(23.8103, 90.4125));

        return SizedBox.expand(
          child: _buildMapContainer(
            mapCameraTarget: mapCameraTarget,
            markers: markers,
            polylines: polylines,
            hasCurrent: hasCurrent,
            showFullscreenButton: true,
            isFullscreen: true,
          ),
        );
      }),
    );
  }

  Widget _buildMapContainer({
    required LatLng mapCameraTarget,
    required Set<Marker> markers,
    required Set<Polyline> polylines,
    required bool hasCurrent,
    required bool showFullscreenButton,
    bool isFullscreen = false,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: isFullscreen
              ? BorderRadius.zero
              : BorderRadius.circular(12.r),
          child: SizedBox(
            width: double.infinity,
            height: isFullscreen ? double.infinity : 220.h,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: mapCameraTarget,
                zoom: 14,
              ),
              onMapCreated: controller.onMapCreated,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              myLocationEnabled: hasCurrent,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              markers: markers,
              polylines: polylines,
            ),
          ),
        ),
        // Map action buttons (Fullscreen & Re-center/Fit Route)
        Positioned(
          top: 10.h,
          right: 10.w,
          child: Column(
            children: [
              if (showFullscreenButton)
                _mapActionButton(
                  icon: controller.isMapFullscreen.value
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  onTap: () {
                    controller.isMapFullscreen.value =
                        !controller.isMapFullscreen.value;
                    Future.delayed(const Duration(milliseconds: 250), () {
                      controller.fitRouteBounds();
                    });
                  },
                ),
              SizedBox(height: 8.h),
              _mapActionButton(
                icon: Icons.center_focus_strong,
                onTap: () => controller.fitRouteBounds(),
              ),
            ],
          ),
        ),
        if (isFullscreen)
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 20.h,
            child: SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.isMapFullscreen.value = false;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                icon: const Icon(Icons.fullscreen_exit),
                label: const Text('Exit Full Map'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _mapActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Icon(icon, color: AppColors.textHeadline, size: 20.sp),
          ),
        ),
      ),
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        Expanded(child: _metaItem('Remaining', controller.distance.value)),
        SizedBox(width: 8.w),
        Expanded(child: _metaItem('ETA', controller.eta.value)),
        SizedBox(width: 8.w),
        Expanded(
          child: _metaItem(
            'Stage',
            controller.isPickedUp.value ? 'Drop-off' : 'Pickup',
          ),
        ),
      ],
    );
  }

  Widget _metaItem(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationContactCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String address,
    required String contactName,
    required String contactPhone,
  }) {
    final hasPhone = contactPhone.trim().isNotEmpty;
    final hasContact = contactName.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textHeadline,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              if (hasPhone)
                InkWell(
                  onTap: () => controller.makePhoneCall(contactPhone),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone,
                          color: AppColors.accent,
                          size: 13.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Call',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            address,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp),
          ),
          if (hasContact || hasPhone) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.textSecondary,
                  size: 14.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    hasContact && hasPhone
                        ? '$contactName  •  $contactPhone'
                        : (hasContact ? contactName : contactPhone),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _parcelSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parcel Information',
            style: TextStyle(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              if (controller.parcelType.value.isNotEmpty)
                _chipItem('Type: ${controller.parcelType.value}'),
              if (controller.vehicleType.value.isNotEmpty)
                _chipItem('Vehicle: ${controller.vehicleType.value}'),
              if (controller.price.value.isNotEmpty)
                _chipItem('Fare: \$${controller.price.value}'),
              if (controller.pickupDate.value.isNotEmpty)
                _chipItem('Date: ${controller.pickupDate.value}'),
              if (controller.pickupTime.value.isNotEmpty)
                _chipItem('Time: ${controller.pickupTime.value}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipItem(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 11.sp),
      ),
    );
  }

  void _showDropoffOtpDialog() {
    final otpController = TextEditingController();
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.vpn_key_outlined,
                      color: AppColors.accent,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Enter Delivery OTP',
                      style: TextStyle(
                        color: AppColors.textHeadline,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Please ask the mover for the 4-digit OTP PIN to complete and verify the delivery.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 18.h),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                autofocus: true,
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontSize: 22.sp,
                  letterSpacing: 14.w,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: TextStyle(
                    color: Colors.white24,
                    letterSpacing: 14.w,
                    fontSize: 22.sp,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: Colors.white24),
                        padding: EdgeInsets.symmetric(vertical: 11.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isSubmittingDropoff.value
                            ? null
                            : () {
                                final pin = otpController.text.trim();
                                if (pin.length < 4) {
                                  Get.snackbar(
                                    'Required',
                                    'Please enter a 4-digit PIN',
                                  );
                                  return;
                                }
                                controller.confirmDropoffWithOtp(pin);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: controller.isSubmittingDropoff.value
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Verify & Finish'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stageCard(bool onPickupStage) {
    final photoPath = onPickupStage
        ? controller.pickupPhotoPath.value
        : controller.dropoffPhotoPath.value;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            onPickupStage ? 'Pickup Confirmation' : 'Drop-off Confirmation',
            style: TextStyle(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            photoPath.isEmpty
                ? (onPickupStage
                      ? 'Take pickup photo before confirming pickup.'
                      : 'Take drop-off photo before confirming delivery.')
                : 'Photo captured',
            style: TextStyle(
              color: photoPath.isEmpty
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontSize: 12.sp,
            ),
          ),
          if (photoPath.isNotEmpty) ...[
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: double.infinity,
                height: 140.h,
                child: Image.file(File(photoPath), fit: BoxFit.cover),
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickupStage
                      ? controller.capturePickupPhoto
                      : controller.captureDropoffPhoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.textHeadline),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  label: Text(
                    onPickupStage ? 'Pickup Photo' : 'Drop-off Photo',
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPickupStage
                      ? (controller.isSubmittingPickup.value
                            ? null
                            : controller.confirmPickup)
                      : () async {
                          if (controller.dropoffPhotoPath.value.isEmpty) {
                            Get.snackbar(
                              'Required',
                              'Take drop-off photo first',
                            );
                            return;
                          }
                          final sent = await controller.confirmDropoff();
                          if (sent) {
                            _showDropoffOtpDialog();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                  ),
                  child: Text(
                    onPickupStage
                        ? (controller.isSubmittingPickup.value
                              ? 'Confirming...'
                              : 'Confirm Pickup')
                        : (controller.isSubmittingDropoff.value
                              ? 'Completing...'
                              : 'Confirm Drop-off'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
