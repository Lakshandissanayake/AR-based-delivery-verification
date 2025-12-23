import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/warehouse_controller.dart';
import '../../routes/app_pages.dart';
import '../../widgets/order_card.dart';

class OrdersView extends GetView<WarehouseController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() {
        final orders = controller.orders;
        final isLoading = controller.isOrdersLoading.value;
        final errorMessage = controller.ordersError.value;
        final verificationOrders = orders
            .where(
              (order) => order.status.trim().toLowerCase() == 'verification',
            )
            .toList(growable: false);

        if (isLoading && orders.isEmpty) {
          return const _LoadingState();
        }

        if (errorMessage != null && orders.isEmpty) {
          return _ErrorState(
            message: errorMessage,
            onRetry: controller.retryOrders,
          );
        }

        if (verificationOrders.isEmpty) {
          return const _EmptyState(
            icon: Icons.inventory_rounded,
            title: 'No open orders',
            subtitle:
                'Once delivery agents sync, new orders awaiting verification will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 96),
          itemBuilder: (_, index) {
            final order = verificationOrders[index];
            return OrderCard(
              order: order,
              onTap: () {
                controller.selectOrder(order);
                Get.toNamed(Routes.orderDetails, arguments: order.id);
              },
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemCount: verificationOrders.length,
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: Colors.grey.shade400, size: 48),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: Colors.grey.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to load orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
