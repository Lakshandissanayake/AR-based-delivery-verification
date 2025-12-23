import 'package:flutter/material.dart';

import '../models/warehouse_order.dart';
import '../theme/app_theme.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.onTap, this.trailing});

  final WarehouseOrder order;
  final VoidCallback? onTap;
  final Widget? trailing;

  bool get _isPending => order.submittedAt != null;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '#${order.id}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 10,
                        //     vertical: 4,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: _priorityColor(order.priority),
                        //     borderRadius: BorderRadius.circular(999),
                        //   ),
                        //   child: Text(
                        //     order.priority,
                        //     style: const TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.w600,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.itemName,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    // const SizedBox(height: 8),
                    // Text(
                    //   order.address,
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: const TextStyle(fontSize: 13, height: 1.4),
                    // ),
                    // const SizedBox(height: 10),
                    // Row(
                    //   children: [
                    //     // _StatusChip(label: order.status, isPending: _isPending),
                    //     const SizedBox(width: 8),
                    //     Expanded(
                    //       child: Text(
                    //         _isPending
                    //             ? 'Submitted ${_timeLabel(order.submittedAt!)}'
                    //             : '',
                    //         style: TextStyle(
                    //           color: Colors.grey.shade600,
                    //           fontSize: 12.5,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 24,
                    color: Colors.grey.shade400,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFFB4C26);
      case 'medium':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  String _timeLabel(DateTime submittedAt) {
    final difference = DateTime.now().difference(submittedAt);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m ago';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isPending});

  final String label;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isPending
            ? const Color(0xFFEEF2FF)
            : AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPending ? const Color(0xFF4C5BD4) : AppColors.primary,
        ),
      ),
    );
  }
}
