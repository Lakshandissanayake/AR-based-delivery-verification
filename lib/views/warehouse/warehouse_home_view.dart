import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/navigation_controller.dart';
import '../../theme/app_theme.dart';
import 'orders_view.dart';
import 'pending_verifications_view.dart';
import 'profile_view.dart';

class WarehouseHomeView extends GetView<NavigationController> {
  const WarehouseHomeView({super.key});

  static const _pages = <Widget>[
    OrdersView(),
    PendingVerificationsView(),
    ProfileView(),
  ];

  static const _titles = <String>[
    'Orders',
    'Verifications',
    'Warehouse Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final index = controller.currentIndex.value;
          return Column(
            children: [
              _buildTopBar(_titles[index]),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _pages[index],
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final index = controller.currentIndex.value;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: controller.changeTab,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey.shade500,
              showUnselectedLabels: true,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_rounded),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.verified_rounded),
                  label: 'Verifications',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTopBar(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updated • ${_timeStamp()}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: AppColors.primary.withValues(alpha: 0.12),
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: const Icon(
              //     Icons.qr_code_scanner_rounded,
              //     color: AppColors.primary,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeStamp() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minutes = now.minute.toString().padLeft(2, '0');
    final suffix = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minutes $suffix';
  }
}
