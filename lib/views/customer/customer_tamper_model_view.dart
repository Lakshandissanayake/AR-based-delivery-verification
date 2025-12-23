import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../controllers/customer_orders_controller.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class CustomerTamperModelView extends GetView<CustomerOrdersController> {
  const CustomerTamperModelView({super.key});

  static const _demoModelUrl =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    String? orderId;
    String? mode;

    if (arguments is Map<String, dynamic>) {
      orderId = arguments['orderId'] as String?;
      mode = arguments['mode'] as String?;
    } else if (arguments is String) {
      orderId = arguments;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tamper 3D Preview')),
      body: Obx(() {
        final order = controller.getOrderById(orderId);
        if (order == null) {
          return const Center(
            child: Text('This order is no longer available.'),
          );
        }

        controller.selectOrder(order);
        final modeLabel = _formatMode(mode);
        const modelUrl = _demoModelUrl;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Showing ${order.itemName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (modeLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Mode: $modeLabel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFF2F6FF), Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ModelViewer(
                            key: ValueKey('customer-tamper-model-${order.id}'),
                            src: modelUrl,
                            alt: '${order.itemName} tamper model',
                            autoRotate: true,
                            cameraControls: true,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        // Positioned(
                        //   top: 20,
                        //   right: 20,
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 12,
                        //       vertical: 6,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(999),
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: Colors.black.withValues(alpha: 0.05),
                        //           blurRadius: 8,
                        //           offset: const Offset(0, 4),
                        //         ),
                        //       ],
                        //     ),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: const [
                        //         Icon(
                        //           Icons.shield_outlined,
                        //           size: 16,
                        //           color: AppColors.primary,
                        //         ),
                        //         SizedBox(width: 6),
                        //         Text(
                        //           'Tamper view',
                        //           style: TextStyle(
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 12,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Detect Tamper',
                icon: Icons.shield,
                onTap: () => _handleDetectTamper(order.id, mode),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _handleDetectTamper(String orderId, String? mode) {
    Get.toNamed(
      Routes.customerTamperResult,
      arguments: {'orderId': orderId, 'mode': mode},
    );
  }

  String? _formatMode(String? mode) {
    if (mode == null) return null;
    switch (mode) {
      case 'capture-now':
        return 'Capture now';
      case 'upload-existing':
        return 'Upload existing video';
      default:
        return null;
    }
  }
}
