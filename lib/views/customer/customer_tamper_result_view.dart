import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../controllers/customer_orders_controller.dart';
import '../../models/warehouse_order.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class CustomerTamperResultView extends GetView<CustomerOrdersController> {
  const CustomerTamperResultView({super.key});

  static const _demoReferenceUrl =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
  static const _demoCapturedUrl =
      'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb';

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
      appBar: AppBar(title: const Text('Tamper Detection Result')),
      body: Obx(() {
        final order = controller.getOrderById(orderId);
        if (order == null) {
          return const Center(
            child: Text('This order is no longer available.'),
          );
        }

        controller.selectOrder(order);
        final referenceUrl =
            (order.modelUrl != null && order.modelUrl!.isNotEmpty)
            ? order.modelUrl!
            : _demoReferenceUrl;
        const capturedUrl = _demoCapturedUrl;
        final findings = _mockFindings();
        final modeLabel = _formatMode(mode);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderSummaryHeader(order: order, modeLabel: modeLabel),
              const SizedBox(height: 22),
              _DualModelPreview(
                referenceUrl: referenceUrl,
                capturedUrl: capturedUrl,
                orderId: order.id,
              ),
              const SizedBox(height: 28),
              const Text(
                'Detection findings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              ...findings.map(
                (finding) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ResultTile(item: finding),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Decision',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Reject order',
                      icon: Icons.close_rounded,
                      isOutlined: true,
                      onTap: () => _showDecisionSnack('reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Accept order',
                      icon: Icons.check_circle_rounded,
                      onTap: () => _showDecisionSnack('accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showDecisionSnack(String decision) {
    final label = decision == 'accept' ? 'accepted' : 'rejected';
    Get.snackbar(
      'Coming soon',
      'Order will be marked as $label after backend integration.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String? _formatMode(String? raw) {
    if (raw == null) return null;
    switch (raw) {
      case 'capture-now':
        return 'Captured now';
      case 'upload-existing':
        return 'Uploaded video';
      default:
        return null;
    }
  }

  List<_TamperResultItem> _mockFindings() {
    return const [
      _TamperResultItem(
        title: 'Seal integrity',
        detail: 'Outer seal shows slight deformation near the top-right edge.',
        flagged: true,
        confidence: 0.82,
      ),
      _TamperResultItem(
        title: 'Label placement',
        detail: 'Shipping label matches warehouse coordinates.',
        flagged: false,
        confidence: 0.95,
      ),
      _TamperResultItem(
        title: 'Package dimensions',
        detail: 'Volume deviation within acceptable thresholds.',
        flagged: false,
        confidence: 0.91,
      ),
    ];
  }
}

class _OrderSummaryHeader extends StatelessWidget {
  const _OrderSummaryHeader({required this.order, this.modeLabel});

  final WarehouseOrder order;
  final String? modeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            order.itemName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(order.address, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _Chip(label: '#${order.id}'),
              if (modeLabel != null) _Chip(label: modeLabel!),
              _Chip(label: order.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _DualModelPreview extends StatelessWidget {
  const _DualModelPreview({
    required this.referenceUrl,
    required this.capturedUrl,
    required this.orderId,
  });

  final String referenceUrl;
  final String capturedUrl;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModelPreviewCard(
            title: 'Warehouse reference',
            subtitle: 'Original 3D blueprint',
            modelUrl: referenceUrl,
            viewerKey: 'reference-$orderId',
            badgeIcon: Icons.inventory_2_outlined,
            badgeLabel: 'Reference',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ModelPreviewCard(
            title: 'Captured evidence',
            subtitle: 'Customer submitted capture',
            modelUrl: capturedUrl,
            viewerKey: 'captured-$orderId',
            badgeIcon: Icons.videocam_outlined,
            badgeLabel: 'Capture',
          ),
        ),
      ],
    );
  }
}

class _ModelPreviewCard extends StatelessWidget {
  const _ModelPreviewCard({
    required this.title,
    required this.subtitle,
    required this.modelUrl,
    required this.viewerKey,
    required this.badgeIcon,
    required this.badgeLabel,
  });

  final String title;
  final String subtitle;
  final String modelUrl;
  final String viewerKey;
  final IconData badgeIcon;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(badgeIcon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                badgeLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 4 / 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF2F6FF), Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ModelViewer(
                      key: ValueKey('customer-$viewerKey'),
                      src: modelUrl,
                      alt: '$title preview',
                      autoRotate: true,
                      cameraControls: true,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.item});

  final _TamperResultItem item;

  @override
  Widget build(BuildContext context) {
    final icon = item.flagged
        ? Icons.warning_rounded
        : Icons.check_circle_rounded;
    final color = item.flagged ? Colors.orange.shade600 : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.flagged
              ? Colors.orange.shade200
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${(item.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.detail,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _TamperResultItem {
  const _TamperResultItem({
    required this.title,
    required this.detail,
    required this.flagged,
    required this.confidence,
  });

  final String title;
  final String detail;
  final bool flagged;
  final double confidence;
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
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
