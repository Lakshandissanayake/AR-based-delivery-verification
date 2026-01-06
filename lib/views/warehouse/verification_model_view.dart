import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../controllers/navigation_controller.dart';
import '../../controllers/warehouse_controller.dart';
import '../../models/photo_data.dart';
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

        final photos = controller.verificationPhotos;
        final hasPhotos = photos.isNotEmpty;

        // Calculate 3D dimensions from photos
        final dimensions = _calculateDimensions(photos);

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
                        if (hasPhotos)
                          _Photo3DViewer(photos: photos)
                        else
                          Positioned.fill(
                            child: ModelViewer(
                              key: ValueKey('model-${order.id}'),
                              src: _demoModelUrl,
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
                              children: [
                                Icon(
                                  hasPhotos
                                      ? Icons.photo_library
                                      : Icons.threed_rotation_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  hasPhotos ? 'Photo Model' : '3D Preview',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (hasPhotos && dimensions != null)
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    order.itemName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Dimensions: ${dimensions['width']} × ${dimensions['height']} × ${dimensions['depth']}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
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

                  controller.clearVerificationPhotos();
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

  Map<String, String>? _calculateDimensions(List<PhotoData> photos) {
    if (photos.isEmpty) return null;

    // Calculate average dimensions and estimate depth
    int totalWidth = 0;
    int totalHeight = 0;
    int maxWidth = 0;
    int maxHeight = 0;

    for (final photo in photos) {
      totalWidth += photo.width;
      totalHeight += photo.height;
      if (photo.width > maxWidth) maxWidth = photo.width;
      if (photo.height > maxHeight) maxHeight = photo.height;
    }

    final avgWidth = (totalWidth / photos.length).round();
    final avgHeight = (totalHeight / photos.length).round();
    
    // Estimate depth as a percentage of average dimensions
    final estimatedDepth = (avgWidth * 0.6).round();

    return {
      'width': '${avgWidth}px',
      'height': '${avgHeight}px',
      'depth': '${estimatedDepth}px',
    };
  }
}

class _Photo3DViewer extends StatefulWidget {
  const _Photo3DViewer({required this.photos});

  final List<PhotoData> photos;

  @override
  State<_Photo3DViewer> createState() => _Photo3DViewerState();
}

class _Photo3DViewerState extends State<_Photo3DViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPhotoIndex = (_currentPhotoIndex + 1) % widget.photos.length;
        });
      },
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return PageView.builder(
            itemCount: widget.photos.length,
            controller: PageController(
              initialPage: _currentPhotoIndex,
            ),
            onPageChanged: (index) {
              setState(() {
                _currentPhotoIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              final file = File(photo.path);
              
              if (!file.existsSync()) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 64),
                );
              }

              return Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        file,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.photos.length,
                              (i) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
