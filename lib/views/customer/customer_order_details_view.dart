import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../controllers/customer_orders_controller.dart';
import '../../models/warehouse_order.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class CustomerOrderDetailsView extends GetView<CustomerOrdersController> {
  const CustomerOrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = Get.arguments as String?;

    return Obx(() {
      final order = controller.getOrderById(orderId);

      if (order == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('This order is no longer available.')),
        );
      }

      final isUpdating = controller.isUpdatingStatus(order.id);
      final isTamperDetectionPhase = _isTamperDetectionStatus(order.status);

      return Scaffold(
        appBar: AppBar(title: Text('#${order.id}')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(order: order),
              const SizedBox(height: 20),
              _DetailTile(
                icon: Icons.inventory_2_outlined,
                label: 'Item',
                value: order.itemName,
              ),
              _DetailTile(
                icon: Icons.location_on_outlined,
                label: 'Delivery address',
                value: order.address,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'View 3D preview',
                icon: Icons.threed_rotation_rounded,
                onTap: () => _handlePreviewTap(context, order),
              ),
              const SizedBox(height: 18),
              if (isTamperDetectionPhase) ...[
                PrimaryButton(
                  label: 'Start Tamper Detection',
                  icon: Icons.shield_outlined,
                  onTap: () => _startTamperDetection(order),
                ),
                const SizedBox(height: 18),
              ],
              order.status == 'pendingVerification'
                  ? Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Decline order',
                            icon: Icons.close_rounded,
                            isOutlined: true,
                            isLoading: isUpdating,
                            onTap: isUpdating
                                ? null
                                : () => _updateStatus(order, 'declined'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Accept order',
                            icon: Icons.check_circle_rounded,
                            isLoading: isUpdating,
                            onTap: isUpdating
                                ? null
                                : () => _updateStatus(order, 'accepted'),
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              const SizedBox(height: 32),
              _TrackingTimeline(order: order),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _updateStatus(WarehouseOrder order, String status) async {
    try {
      await controller.updateStatus(order, status);
      Get.snackbar(
        'Status updated',
        '#${order.id} marked as ${status.toUpperCase()}.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Update failed',
        'We couldn\'t change the status. Try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handlePreviewTap(BuildContext context, WarehouseOrder order) {
    final modelUrl = order.modelUrl;
    if (modelUrl == null || modelUrl.isEmpty) {
      Get.snackbar(
        '3D preview unavailable',
        'This order doesn\'t include a model yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModelPreviewSheet(order: order, modelUrl: modelUrl),
    );
  }

  void _startTamperDetection(WarehouseOrder order) {
    controller.selectOrder(order);
    Get.toNamed(Routes.customerTamperCapture, arguments: order.id);
  }

  bool _isTamperDetectionStatus(String status) {
    final normalized = status.trim().toLowerCase();
    final sanitized = normalized.replaceAll(RegExp(r'[\s_-]+'), '');
    return sanitized == 'tamperdetection' || sanitized == 'tampercheck';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.order});

  final WarehouseOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.itemName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatusBadge(label: order.status),
              const SizedBox(width: 8),
              // Text(
              //   order.eta.isEmpty ? 'ETA pending' : order.eta,
              //   style: TextStyle(
              //     color: Colors.grey.shade600,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelPreviewSheet extends StatelessWidget {
  const _ModelPreviewSheet({required this.order, required this.modelUrl});

  final WarehouseOrder order;
  final String modelUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Text(
            '${order.itemName} 3D preview',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: ModelViewer(
                key: ValueKey('customer-model-${order.id}'),
                src: modelUrl,
                alt: '${order.itemName} model',
                autoRotate: true,
                cameraControls: true,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  const _TrackingTimeline({required this.order});

  final WarehouseOrder order;

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(order.status);
    final activeIndex = _statusIndex(order.status, steps.length);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery tracking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isComplete = index < activeIndex;
            final isCurrent = index == activeIndex;

            return _TrackingStepTile(
              step: step,
              isComplete: isComplete,
              isCurrent: isCurrent,
              showDivider: index != steps.length - 1,
            );
          }),
        ],
      ),
    );
  }

  List<_TrackingStep> _buildSteps(String status) {
    return const [
      _TrackingStep(
        title: 'Order confirmed',
        description: 'We\'ve received the order from the warehouse.',
      ),
      _TrackingStep(
        title: 'Verification in progress',
        description: 'Warehouse is capturing 3D verification assets.',
      ),
      _TrackingStep(
        title: 'Sent for packaging',
        description: 'Warehouse is preparing the order for delivery.',
      ),
      _TrackingStep(
        title: 'Out for delivery',
        description: 'Delivery partner is en route to you.',
      ),
      _TrackingStep(
        title: 'Tamper Detection',
        description: 'Customer is checking for tampering of the order.',
      ),
      _TrackingStep(
        title: 'Completed',
        description: 'Order accepted or declined after inspection.',
      ),
    ];
  }

  int _statusIndex(String status, int totalSteps) {
    if (totalSteps <= 0) return 0;

    final normalized = status.trim().toLowerCase();
    final sanitized = normalized.replaceAll(RegExp(r'[\s_-]+'), '');

    const statusToIndex = <String, int>{
      'verification': 1,
      'pendingverification': 1,
      'sentforpackaging': 2,
      'packaging': 2,
      'intransit': 3,
      'outfordelivery': 3,
      'enroute': 3,
      'tamperdetection': 4,
      'tampercheck': 4,
      'accepted': 5,
      'declined': 5,
      'completed': 5,
      'delivered': 5,
    };

    final mappedIndex = statusToIndex[sanitized] ?? 0;
    if (mappedIndex < 0) return 0;
    if (mappedIndex >= totalSteps) {
      return totalSteps - 1;
    }
    return mappedIndex;
  }
}

class _TrackingStepTile extends StatelessWidget {
  const _TrackingStepTile({
    required this.step,
    required this.isComplete,
    required this.isCurrent,
    required this.showDivider,
  });

  final _TrackingStep step;
  final bool isComplete;
  final bool isCurrent;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final color = isComplete || isCurrent
        ? AppColors.primary
        : Colors.grey.shade400;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: isComplete ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isComplete
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                if (showDivider)
                  Container(
                    width: 2,
                    height: 48,
                    color: color.withValues(alpha: 0.4),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isCurrent ? AppColors.primary : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrackingStep {
  const _TrackingStep({required this.title, required this.description});

  final String title;
  final String description;
}
