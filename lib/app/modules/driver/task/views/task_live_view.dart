import 'dart:io';

import 'package:digaxy/shared/app_colors.dart';
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

          final markers = <Marker>{};
          if (hasCurrent) {
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
          if (hasTarget) {
            markers.add(
              Marker(
                markerId: MarkerId(onPickupStage ? 'pickup' : 'dropoff'),
                position: LatLng(targetLat, targetLng),
                infoWindow: InfoWindow(
                  title: onPickupStage ? 'Pickup Point' : 'Drop-off Point',
                ),
              ),
            );
          }
          if (hasPickup) {
            markers.add(
              Marker(
                markerId: const MarkerId('pickup_point'),
                position: LatLng(pickupLat, pickupLng),
                infoWindow: const InfoWindow(title: 'Pickup Point'),
              ),
            );
          }
          if (hasDrop) {
            markers.add(
              Marker(
                markerId: const MarkerId('dropoff_point'),
                position: LatLng(dropLat, dropLng),
                infoWindow: const InfoWindow(title: 'Drop-off Point'),
              ),
            );
          }

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
                _addressCard(
                  title: 'Pickup Address',
                  value: controller.pickupAddress.value.isEmpty
                      ? 'Not available'
                      : controller.pickupAddress.value,
                ),
                SizedBox(height: 10.h),
                _addressCard(
                  title: 'Drop-off Address',
                  value: controller.dropoffAddress.value.isEmpty
                      ? 'Not available'
                      : controller.dropoffAddress.value,
                ),
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

        final markers = <Marker>{};
        if (hasCurrent) {
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
        if (hasTarget) {
          markers.add(
            Marker(
              markerId: MarkerId(onPickupStage ? 'pickup' : 'dropoff'),
              position: LatLng(targetLat, targetLng),
              infoWindow: InfoWindow(
                title: onPickupStage ? 'Pickup Point' : 'Drop-off Point',
              ),
            ),
          );
        }
        if (hasPickup) {
          markers.add(
            Marker(
              markerId: const MarkerId('pickup_point'),
              position: LatLng(pickupLat, pickupLng),
              infoWindow: const InfoWindow(title: 'Pickup Point'),
            ),
          );
        }
        if (hasDrop) {
          markers.add(
            Marker(
              markerId: const MarkerId('dropoff_point'),
              position: LatLng(dropLat, dropLng),
              infoWindow: const InfoWindow(title: 'Drop-off Point'),
            ),
          );
        }

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
              myLocationEnabled: hasCurrent,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              markers: markers,
              polylines: polylines,
            ),
          ),
        ),
        // Fullscreen toggle button
        if (showFullscreenButton)
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    controller.isMapFullscreen.value =
                        !controller.isMapFullscreen.value;
                  },
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Icon(
                      controller.isMapFullscreen.value
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                      color: AppColors.textHeadline,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
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

  Widget _addressCard({required String title, required String value}) {
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
            title,
            style: TextStyle(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 12.sp),
          ),
        ],
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
                      : (controller.isSubmittingDropoff.value
                            ? null
                            : controller.confirmDropoff),
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
