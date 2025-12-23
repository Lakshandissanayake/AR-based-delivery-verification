import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../controllers/navigation_controller.dart';
import '../../controllers/warehouse_controller.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class VerificationModelView extends GetView<WarehouseController> {
  const VerificationModelView({super.key});

  static const _demoModelUrl =
      'https://firebasestorage.googleapis.com/v0/b/delivery-verification-system.firebasestorage.app/o/shoe_salomon_x_ultra.glb?alt=media&token=acf51dc5-b4b5-4f59-a40f-de32462633dd';

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();

    return Scaffold(
      appBar: AppBar(title: const Text('3D Model Preview')),
      body: Obx(() {
        final order = controller.selectedOrder.value;
        if (order == null) {
          return const Center(child: Text('No order selected.'));
        }
        const modelUrl = _demoModelUrl;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFE2D8), Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ModelViewer(
                            key: ValueKey('model-${order.id}'),
                            src: modelUrl,
                            alt: '${order.itemName} 3D model',
                            autoRotate: true,
                            cameraControls: true,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        Positioned(
                          top: 24,
                          right: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.threed_rotation_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '3D Preview',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              order.itemName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // const Text(
              //   'Verification checklist',
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              // ),
              // const SizedBox(height: 12),
              // ..._instructions.map(
              //   (item) => Padding(
              //     padding: const EdgeInsets.only(bottom: 10),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Container(
              //           height: 24,
              //           width: 24,
              //           decoration: BoxDecoration(
              //             color: AppColors.primary.withValues(alpha: 0.12),
              //             borderRadius: BorderRadius.circular(8),
              //           ),
              //           child: const Icon(
              //             Icons.check_rounded,
              //             color: AppColors.primary,
              //             size: 18,
              //           ),
              //         ),
              //         const SizedBox(width: 12),
              //         Expanded(
              //           child: Text(item, style: const TextStyle(height: 1.4)),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              PrimaryButton(
                label: 'Send for Verification',
                icon: Icons.send_rounded,
                isLoading: controller.isSendingVerification.value,
                onTap: () async {
                  try {
                    await controller.sendOrderForVerification();
                  } catch (_) {
                    Get.snackbar(
                      'Submission failed',
                      'We could not submit the verification. Please try again.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  navigationController.changeTab(1);
                  Get.offAllNamed(Routes.warehouseHome);
                  Get.snackbar(
                    'Verification submitted',
                    '${order.id} moved to Pending.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
