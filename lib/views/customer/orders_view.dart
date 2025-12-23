import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/customer_orders_controller.dart';
import '../../models/warehouse_order.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_card.dart';

class CustomerOrdersView extends GetView<CustomerOrdersController> {
  const CustomerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sections = controller.sections;
      final isLoading = controller.isLoading.value;
      final errorMessage = controller.errorMessage.value;
      final hasOrders = controller.orders.isNotEmpty;

      if (isLoading && !hasOrders) {
        return const _StatusPlaceholder(
          icon: Icons.hourglass_top_rounded,
          title: 'Loading your orders',
          message: 'Fetching the latest deliveries for you.',
        );
      }

      if (errorMessage != null && !hasOrders) {
        return _StatusPlaceholder(
          icon: Icons.cloud_off_rounded,
          title: 'Unable to load orders',
          message: errorMessage,
          buttonLabel: 'Retry',
          onButtonTap: controller.refreshOrders,
        );
      }

      if (sections.isEmpty) {
        return const _StatusPlaceholder(
          icon: Icons.inventory_rounded,
          title: 'No deliveries yet',
          message: 'Orders assigned to you will appear here once available.',
        );
      }

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refreshOrders,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemBuilder: (context, index) {
            final section = sections[index];
            return _OrderSection(
              section: section,
              onOrderTap: (order) {
                controller.selectOrder(order);
                Get.toNamed(Routes.customerOrderDetails, arguments: order.id);
              },
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 24),
          itemCount: sections.length,
        ),
      );
    });
  }
}

class _OrderSection extends StatelessWidget {
  const _OrderSection({required this.section, required this.onOrderTap});

  final CustomerOrderSection section;
  final ValueChanged<WarehouseOrder> onOrderTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...List.generate(section.orders.length, (index) {
          final order = section.orders[index];
          final hasDivider = index != section.orders.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: hasDivider ? 12 : 0),
            child: OrderCard(
              order: order,
              onTap: () => onOrderTap(order),
              trailing: _OrderTrailing(status: order.status, eta: order.eta),
            ),
          );
        }),
      ],
    );
  }
}

class _OrderTrailing extends StatelessWidget {
  const _OrderTrailing({required this.status, required this.eta});

  final String status;
  final String eta;

  @override
  Widget build(BuildContext context) {
    final normalizedEta = eta.isEmpty ? 'ETA pending' : eta;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Text(
        //   normalizedEta,
        //   style: TextStyle(
        //     fontSize: 12,
        //     color: Colors.grey.shade600,
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
      ],
    );
  }
}

class _StatusPlaceholder extends StatelessWidget {
  const _StatusPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outline),
              ),
              child: Icon(icon, size: 42, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (buttonLabel != null && onButtonTap != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(onPressed: onButtonTap, child: Text(buttonLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
