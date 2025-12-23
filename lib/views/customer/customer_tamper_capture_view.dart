import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/customer_orders_controller.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';

class CustomerTamperCaptureView extends GetView<CustomerOrdersController> {
  const CustomerTamperCaptureView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    String? orderId;
    if (arguments is String) {
      orderId = arguments;
    } else if (arguments is Map<String, dynamic>) {
      orderId = arguments['orderId'] as String?;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tamper Detection')),
      body: Obx(() {
        final order = controller.getOrderById(orderId);
        if (order == null) {
          return const Center(
            child: Text('This order is no longer available.'),
          );
        }

        controller.selectOrder(order);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.itemName,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.address,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _TamperCaptureOptionCard(
                icon: Icons.videocam_outlined,
                title: 'Capture now',
                description:
                    'Record a new video to document the current package condition.',
                onTap: () => _openModelView(order.id, 'capture-now'),
              ),
              const SizedBox(height: 16),
              _TamperCaptureOptionCard(
                icon: Icons.upload_file_outlined,
                title: 'Upload existing video',
                description: 'Upload an already recorded inspection video.',
                onTap: () => _openModelView(order.id, 'upload-existing'),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _openModelView(String orderId, String mode) {
    Get.toNamed(
      Routes.customerTamperModel,
      arguments: {'orderId': orderId, 'mode': mode},
    );
  }
}

class _TamperCaptureOptionCard extends StatelessWidget {
  const _TamperCaptureOptionCard({
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
