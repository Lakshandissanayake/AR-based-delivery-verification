import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/warehouse_controller.dart';
import '../../models/warehouse_order.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class OrderDetailsView extends GetView<WarehouseController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final String? orderId = Get.arguments as String?;

    return Obx(() {
      final order = controller.getOrderById(orderId);
      if (order == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Order no longer available.')),
        );
      }

      final normalizedStatus = order.status.trim().toLowerCase();
      final statusColor = _statusColor(normalizedStatus);
      final isAccepted = normalizedStatus == 'accepted';

      return Scaffold(
        appBar: AppBar(title: Text('#${order.id}')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderImageCard(order: order),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(label: 'Item', value: order.itemName),
                    _DetailRow(label: 'Customer', value: order.customerName),
                    _DetailRow(
                      label: 'Status',
                      value: order.status.isEmpty ? '—' : order.status,
                      valueColor: statusColor,
                    ),
                    _DetailRow(label: 'Delivery address', value: order.address),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 32),
              PrimaryButton(
                label: isAccepted
                    ? 'Suggest Packaging'
                    : 'Start Verification Process',
                icon: isAccepted
                    ? Icons.auto_awesome_rounded
                    : Icons.play_circle_filled_rounded,
                onTap: () {
                  controller.selectOrder(order);
                  if (isAccepted) {
                    Get.toNamed(Routes.packageSuggestion, arguments: order.id);
                  } else {
                    Get.toNamed(Routes.verificationCapture);
                  }
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderImageCard extends StatelessWidget {
  const _OrderImageCard({required this.order});

  final WarehouseOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _OrderImageBackground(imageUrl: order.imageUrl),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.02),
                      Colors.black.withOpacity(0.12),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '#${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderImageBackground extends StatelessWidget {
  const _OrderImageBackground({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const _OrderImagePlaceholder();
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const _OrderImagePlaceholder(showLoader: true);
      },
      errorBuilder: (_, __, ___) => const _OrderImagePlaceholder(),
    );
  }
}

class _OrderImagePlaceholder extends StatelessWidget {
  const _OrderImagePlaceholder({this.showLoader = false});

  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFEDBD5), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: showLoader
            ? const CircularProgressIndicator()
            : const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 84,
              ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'accepted':
      return const Color(0xFF1B9A5C);
    case 'declined':
      return const Color(0xFFD64545);
    case 'pendingverification':
      return const Color(0xFF2B6AFF);
    default:
      return AppColors.text;
  }
}
