import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/helper_task_live_controller.dart';

class HelperTaskLiveView extends GetView<HelperTaskLiveController> {
  const HelperTaskLiveView({super.key});

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
            : _buildNormalView(context),
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
          infoWindow: const InfoWindow(title: 'Driver Location'),
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

  Widget _buildNormalView(BuildContext context) {
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
                SizedBox(height: 10.h),
                _helperRoleInfoCard(context),
                SizedBox(height: 16.h),
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
            controller.isPickedUp.value ? 'On The Way' : 'Assigned',
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

  Widget _helperRoleInfoCard(BuildContext context) {
    final isOnWay = controller.isPickedUp.value;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volunteer_activism_outlined,
                color: AppColors.accent,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Helper Assistance Mode',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            isOnWay
                ? 'The driver is transporting the parcel to destination. Please assist with unloading upon arrival.'
                : 'You are assigned as helper. Driver will handle vehicle driving and pickup/dropoff OTP confirmation.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.accent,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Your 30% earnings share is automatically credited once the driver finishes delivery with the customer OTP.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isOnWay) ...[
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.isCancelling.value
                      ? null
                      : () => _confirmWithdrawDialog(context),
                  icon: controller.isCancelling.value
                      ? SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.redAccent,
                            ),
                          ),
                        )
                      : const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  label: const Text(
                    'Withdraw / Cancel Assignment',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmWithdrawDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Withdraw from Assignment',
          style: TextStyle(color: AppColors.textHeadline),
        ),
        content: const Text(
          'Are you sure you want to release this helper assignment? Another helper will be alerted.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.withdrawDeal();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Withdraw', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
