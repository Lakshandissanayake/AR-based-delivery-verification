import 'package:delivery_verification_system/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/warehouse_controller.dart';
import '../../models/warehouse_order.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class PackageSuggestionView extends GetView<WarehouseController> {
  const PackageSuggestionView({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    final String? orderId =
        args is Map<String, dynamic> ? args['orderId'] as String? : args as String?;
    final _PackageInputs? packageInputs =
        args is Map<String, dynamic> ? _PackageInputs.fromMap(args) : null;

    return Obx(() {
      final order = controller.getOrderById(orderId);
      if (order == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Order not available anymore.')),
        );
      }

      final suggestions = _buildMockSuggestions(order);
      final isSendingForDelivery = controller.isMarkingOutForDelivery.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Suggest Packaging'),
          actions: [
            IconButton(
              tooltip: 'AI roadmap',
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () {
                Get.snackbar(
                  'Coming soon',
                  'AI-powered packaging blueprints will appear here.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderSummaryCard(order: order),
              const SizedBox(height: 28),
              if (packageInputs != null) ...[
                _InputsSummaryCard(inputs: packageInputs),
                const SizedBox(height: 22),
              ],
              const Text(
                'Recommended packaging flows',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ...suggestions
                  .map((suggestion) => _SuggestionCard(suggestion: suggestion))
                  .toList(),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Send for delivery',
                icon: Icons.task_alt_rounded,
                isLoading: isSendingForDelivery,
                onTap: isSendingForDelivery
                    ? null
                    : () async {
                        try {
                          await controller.markOrderOutForDelivery(order);
                          Get.snackbar(
                            'Sent for delivery',
                            'Order #${order.id} is now on the way.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          Get.offAllNamed(Routes.warehouseHome);
                        } catch (_) {
                          Get.snackbar(
                            'Update failed',
                            'Could not update the order. Please try again.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      );
    });
  }

  List<_PackagingSuggestion> _buildMockSuggestions(WarehouseOrder order) {
    final itemName = order.itemName.isEmpty ? 'this item' : order.itemName;

    return [
      _PackagingSuggestion(
        title: 'Eco compact kit',
        icon: Icons.eco_rounded,
        boxSize: '32 × 22 × 14 cm double-wall',
        cushioning: 'Honeycomb wrap + kraft void fill',
        sealing: 'Fiber tape / QR tamper label',
        notes:
            'Keeps $itemName snug for medium-distance routes with minimal filler.',
        checklist: const [
          'Layer honeycomb wrap twice around the product',
          'Add kraft crinkle fill on the bottom + top',
          'Attach tamper label on both lid flaps',
        ],
      ),
      _PackagingSuggestion(
        title: 'Impact shield plan',
        icon: Icons.security_rounded,
        boxSize: '36 × 26 × 18 cm tri-wall',
        cushioning: 'Bio air pillows + edge guards',
        sealing: 'Water-activated tape',
        notes:
            'Use when courier indicates rough handling or long-haul transport.',
        checklist: const [
          'Edge-guard all four vertical corners',
          'Fill side cavities with two air pillows each',
          'Add fragile + orientation labels before dispatch',
        ],
      ),
      _PackagingSuggestion(
        title: 'Retail display finish',
        icon: Icons.auto_awesome_rounded,
        boxSize: 'Gift rigid box + outer mailer',
        cushioning: 'Micro-foam sleeve',
        sealing: 'Magnetic lid + branded sleeve',
        notes:
            'Creates unboxing moment for VIP customers while staying secure.',
        checklist: const [
          'Wrap item with micro-foam sleeve to avoid scuffs',
          'Place rigid box inside padded mailer for transit',
          'Include thank-you insert or care card',
        ],
      ),
    ];
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final WarehouseOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '#${order.id}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            order.itemName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _SummaryChip(
                label: 'Status',
                value: order.status.isEmpty ? 'n/a' : order.status,
                color: AppColors.primary.withValues(alpha: 0.12),
                valueColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SummaryRow(title: 'Customer', value: order.customerName),
          _SummaryRow(title: 'Address', value: order.address),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.1,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.1,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? '—' : value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion});

  final _PackagingSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(suggestion.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.notes,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Box size', value: suggestion.boxSize),
          _InfoRow(label: 'Cushioning', value: suggestion.cushioning),
          _InfoRow(label: 'Sealing', value: suggestion.sealing),
          if (suggestion.checklist.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Checklist',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...suggestion.checklist.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: const TextStyle(height: 1.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PackagingSuggestion {
  const _PackagingSuggestion({
    required this.title,
    required this.icon,
    required this.boxSize,
    required this.cushioning,
    required this.sealing,
    required this.notes,
    required this.checklist,
  });

  final String title;
  final IconData icon;
  final String boxSize;
  final String cushioning;
  final String sealing;
  final String notes;
  final List<String> checklist;
}

class _PackageInputs {
  const _PackageInputs({
    required this.weight,
    required this.productType,
    required this.distance,
    required this.transportMode,
    required this.materialCost,
  });

  factory _PackageInputs.fromMap(Map<String, dynamic> map) {
    return _PackageInputs(
      weight: (map['packageWeight'] ?? '').toString(),
      productType: (map['productType'] ?? '').toString(),
      distance: (map['deliveryDistance'] ?? '').toString(),
      transportMode: (map['transportMode'] ?? '').toString(),
      materialCost: (map['materialCost'] ?? '').toString(),
    );
  }

  final String weight;
  final String productType;
  final String distance;
  final String transportMode;
  final String materialCost;
}

class _InputsSummaryCard extends StatelessWidget {
  const _InputsSummaryCard({required this.inputs});

  final _PackageInputs inputs;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.fact_check_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const Text(
                'Packaging inputs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Package weight', value: '${inputs.weight} kg'),
          _InfoRow(label: 'Product type', value: inputs.productType),
          _InfoRow(label: 'Delivery distance', value: '${inputs.distance} km'),
          _InfoRow(label: 'Transport mode', value: inputs.transportMode),
          _InfoRow(label: 'Material cost budget', value: '\$${inputs.materialCost}'),
        ],
      ),
    );
  }
}
