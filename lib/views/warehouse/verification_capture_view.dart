import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/warehouse_controller.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';

class VerificationCaptureView extends GetView<WarehouseController> {
  const VerificationCaptureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        final order = controller.selectedOrder.value;
        if (order == null) {
          return const Center(child: Text('No order selected.'));
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.itemName,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    //const SizedBox(height: 12),
                    // Row(
                    //   children: [
                    //     Icon(
                    //       Icons.route_outlined,
                    //       color: Colors.grey.shade600,
                    //       size: 16,
                    //     ),
                    //     const SizedBox(width: 6),
                    //     Expanded(
                    //       child: Text(
                    //         order.address,
                    //         style: const TextStyle(fontSize: 13),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _CaptureOptionCard(
                icon: Icons.videocam_rounded,
                title: 'Capture now',
                description: 'Capture product now',
                onTap: () => Get.toNamed(Routes.verificationModel),
              ),
              const SizedBox(height: 16),
              _CaptureOptionCard(
                icon: Icons.upload_file_rounded,
                title: 'Upload existing video',
                description: 'Upload existing video from device',
                onTap: () => Get.toNamed(Routes.verificationModel),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CaptureOptionCard extends StatelessWidget {
  const _CaptureOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
