import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/delivery_detail_controller.dart';

class DeliveryDetailView extends GetView<DeliveryDetailController> {
  const DeliveryDetailView({super.key});

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.title.value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              controller.distance.value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Text(
              controller.eta.value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent),
                color: Colors.transparent,
              ),
              child: Text(
                controller.status.value,
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressCard(
    String title,
    String address,
    String contact,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textHeadline,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contact,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.access_time,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Delivery Details',
          style: TextStyle(color: AppColors.textHeadline),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Obx(() {
            final isCompleted =
                controller.status.value.toLowerCase() == 'completed';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                Text(
                  'Delivery ID: ${controller.deliveryId.value}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                if (isCompleted) ...[
                  _buildAddressCard(
                    'Pickup Location',
                    controller.pickupAddress.value,
                    controller.pickupContact.value,
                    controller.pickupTime.value,
                  ),
                  _buildAddressCard(
                    'Drop-off Location',
                    controller.dropoffAddress.value,
                    controller.pickupContact.value,
                    controller.dropoffTime.value,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      color: AppColors.textHeadline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...controller.orderSummary.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        e,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ] else ...[
                  // Minimal view for non-completed deliveries
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup: ${controller.pickupAddress.value}',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Dropoff: ${controller.dropoffAddress.value}',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                // Row(
                //   children: [
                //     Expanded(
                //       child: PrimaryButton(
                //         label: isCompleted ? 'Re-Route' : 'Navigate',
                //         onPressed: controller.navigateToDropoff,
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     if (isCompleted)
                //       Expanded(
                //         child: PrimaryButton(
                //           label: 'Mark Delivered',
                //           onPressed: () =>
                //               Get.snackbar('Done', 'Marked as delivered'),
                //         ),
                //       ),
                //   ],
                // ),
                // const SizedBox(height: 28),
              ],
            );
          }),
        ),
      ),
    );
  }
}
