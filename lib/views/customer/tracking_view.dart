import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class CustomerTrackingView extends StatelessWidget {
  const CustomerTrackingView({super.key});

  static const _trackingCards = [
    {
      'orderId': 'ORD-9021',
      'status': 'Drone en route',
      'eta': 'ETA 45 min',
      'steps': [
        '3D verification approved',
        'Drone dispatched from warehouse',
        'Approaching delivery zone',
      ],
    },
    {
      'orderId': 'ORD-8872',
      'status': 'Awaiting confirmation',
      'eta': 'ETA 1h 10m',
      'steps': [
        'Verification proof captured',
        'QA review complete',
        'Delivery agent assigned',
      ],
    },
    {
      'orderId': 'ORD-8810',
      'status': 'Preparing verification',
      'eta': 'Scheduling',
      'steps': [
        'Packaging queued for inspection',
        '3D scan scheduled',
        'Awaiting customer confirmation',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _trackingCards.length,
      itemBuilder: (_, index) {
        final card = _trackingCards[index];
        return _TrackingCard(
          orderId: card['orderId'] as String,
          status: card['status'] as String,
          eta: card['eta'] as String,
          steps: (card['steps'] as List<String>),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 16),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({
    required this.orderId,
    required this.status,
    required this.eta,
    required this.steps,
  });

  final String orderId;
  final String status;
  final String eta;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  eta,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(status, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((entry) {
            final isActive = entry.key == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isActive
                        ? Icons.radio_button_checked
                        : Icons.circle_outlined,
                    color: isActive ? AppColors.primary : Colors.grey.shade400,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}



