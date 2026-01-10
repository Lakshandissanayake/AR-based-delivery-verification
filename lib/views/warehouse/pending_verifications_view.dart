import 'package:delivery_verification_system/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/warehouse_controller.dart';
import '../../models/warehouse_order.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_card.dart';

class PendingVerificationsView extends GetView<WarehouseController> {
  const PendingVerificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final lanes = _VerificationLane.values;

    return DefaultTabController(
      length: lanes.length,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                tabs: lanes.map((lane) => Tab(text: lane.label)).toList(),
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey.shade600,
                indicator: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                splashBorderRadius: BorderRadius.circular(12),
                dividerColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: lanes.map((lane) {
                  return Obx(() {
                    final orders = controller.pendingVerifications
                        .where(lane.matches)
                        .toList(growable: false);

                    if (orders.isEmpty) {
                      return _EmptyState(
                        icon: lane.icon,
                        title: lane.emptyTitle,
                        subtitle: lane.emptySubtitle,
                      );
                    }

                    return _buildOrdersList(orders);
                  });
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildOrdersList(List<WarehouseOrder> orders) {
  //   return ListView.separated(
  //     padding: const EdgeInsets.only(bottom: 96),
  //     itemBuilder: (_, index) {
  //       final order = orders[index];
  //       return OrderCard(order: order, onTap: () => _handleOrderTap(order));
  //     },
  //     separatorBuilder: (_, __) => const SizedBox(height: 18),
  //     itemCount: orders.length,
  //   );
  // }

    Widget _buildOrdersList(List<WarehouseOrder> orders) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemBuilder: (_, index) {
        final order = orders[index];
        return OrderCard(order: order, onTap: () => _handleOrderTap(order));
      },
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemCount: orders.length,
    );
  }

  void _handleOrderTap(WarehouseOrder order) {
    controller.selectOrder(order);
    Get.toNamed(Routes.orderDetails, arguments: order.id);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    this.icon = Icons.verified_user_outlined,
    this.title = 'No pending verifications',
    this.subtitle =
        'Once you submit 3D verification evidence, the order will sit here until quality review clears it.',
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

enum _VerificationLane {
  pending(
    label: 'Pending',
    icon: Icons.verified_user_outlined,
    emptyTitle: 'No pending verifications',
    emptySubtitle:
        'Once you submit 3D verification evidence, the order will sit here until quality review clears it.',
  ),
  accepted(
    label: 'Accepted',
    icon: Icons.task_alt_rounded,
    emptyTitle: 'No accepted verifications',
    emptySubtitle:
        'When QA approves your submissions they will land here for quick reference.',
  ),
  declined(
    label: 'Declined',
    icon: Icons.report_gmailerrorred_outlined,
    emptyTitle: 'No declined verifications',
    emptySubtitle:
        'If QA flags an issue you will find the declined submissions in this tab.',
  );

  const _VerificationLane({
    required this.label,
    required this.icon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final String label;
  final IconData icon;
  final String emptyTitle;
  final String emptySubtitle;

  bool matches(WarehouseOrder order) {
    final status = order.status.trim().toLowerCase();
    switch (this) {
      case _VerificationLane.pending:
        return status == 'pendingverification';
      case _VerificationLane.accepted:
        return status == 'accepted';
      case _VerificationLane.declined:
        return status == 'declined';
    }
  }
}
