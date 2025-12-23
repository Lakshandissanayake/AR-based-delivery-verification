import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/app_user.dart';
import '../models/warehouse_order.dart';
import '../services/warehouse_service.dart';
import 'auth_controller.dart';

class CustomerOrdersController extends GetxController {
  CustomerOrdersController({WarehouseService? warehouseService})
    : _warehouseService = warehouseService ?? WarehouseService();

  final WarehouseService _warehouseService;

  final RxList<WarehouseOrder> orders = <WarehouseOrder>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<WarehouseOrder> selectedOrder = Rxn<WarehouseOrder>();
  final RxnString updatingOrderId = RxnString();

  StreamSubscription<List<WarehouseOrder>>? _ordersSubscription;
  Worker? _userWorker;
  String? _activeCustomerId;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();
    _userWorker = ever<AppUser?>(authController.currentUser, _handleUserChange);
    _handleUserChange(authController.currentUser.value);
  }

  void _handleUserChange(AppUser? user) {
    _ordersSubscription?.cancel();
    orders.clear();
    errorMessage.value = null;
    _activeCustomerId = user?.id;

    if (user == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _ordersSubscription = _warehouseService
        // Listen to all orders for this customer (any status),
        // then group them by status in the UI.
        .listenToCustomerOrders(customerId: user.id)
        .listen(
          (remoteOrders) {
            orders.assignAll(remoteOrders);
            isLoading.value = false;
            errorMessage.value = null;
          },
          onError: (Object error, _) {
            errorMessage.value = _mapError(error);
            isLoading.value = false;
          },
        );

    print('orders: $orders');
    print('isLoading: $isLoading');
    print('errorMessage: $errorMessage');
    print('activeCustomerId: $_activeCustomerId');
    print('user: $user');
    print('userWorker: $_userWorker');
    print('ordersSubscription: $_ordersSubscription');
    print('warehouseService: _warehouseService');
    print('warehouseService: _warehouseService');
  }

  List<CustomerOrderSection> get sections {
    final Map<String, _StatusAccumulator> grouped = {};

    for (final order in orders) {
      final normalizedKey = _normalizeStatus(order.status);
      grouped.putIfAbsent(
        normalizedKey,
        () => _StatusAccumulator(rawLabel: order.status),
      );
      grouped[normalizedKey]!.orders.add(order);
    }

    final entries = grouped.entries.toList()
      ..sort(
        (a, b) => _statusPriority(a.key).compareTo(_statusPriority(b.key)),
      );

    return entries
        .map(
          (entry) => CustomerOrderSection(
            key: entry.key,
            label: _formatStatus(entry.value.rawLabel),
            orders: entry.value.orders,
          ),
        )
        .toList(growable: false);
  }

  List<WarehouseOrder> get pendingVerificationOrders {
    return orders
        .where(
          (order) => _normalizeStatus(order.status) == 'pendingverification',
        )
        .toList(growable: false);
  }

  WarehouseOrder? getOrderById(String? id) {
    if (id == null || id.isEmpty) {
      return selectedOrder.value;
    }

    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (_) {
      if (selectedOrder.value?.id == id) {
        return selectedOrder.value;
      }
      return null;
    }
  }

  void selectOrder(WarehouseOrder order) {
    selectedOrder.value = order;
  }

  bool isUpdatingStatus(String orderId) => updatingOrderId.value == orderId;

  Future<void> refreshOrders() async {
    final customerId = _activeCustomerId;
    if (customerId == null) return;

    isLoading.value = true;
    try {
      // Fetch all orders for this customer (any status) so that
      // accepted/declined orders also remain visible.
      final freshOrders = await _warehouseService.fetchOrdersOnceForCustomer(
        customerId: customerId,
      );
      orders.assignAll(freshOrders);
      errorMessage.value = null;
    } catch (error) {
      errorMessage.value = _mapError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(WarehouseOrder order, String status) async {
    if (isUpdatingStatus(order.id)) return;

    updatingOrderId.value = order.id;
    try {
      await _warehouseService.updateOrderStatus(
        orderId: order.id,
        status: status,
      );
      final index = orders.indexWhere((element) => element.id == order.id);
      if (index != -1) {
        final updatedOrder = order.copyWith(status: status);
        orders[index] = updatedOrder;
        selectedOrder.value = updatedOrder;
      }
    } finally {
      updatingOrderId.value = null;
    }
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    _userWorker?.dispose();
    super.onClose();
  }

  String _mapError(Object error) {
    if (error is FirebaseException) {
      return error.message ?? 'Unable to load your orders.';
    }
    return 'Something went wrong while loading your orders.';
  }

  String _normalizeStatus(String status) {
    final trimmed = status.trim();
    if (trimmed.isEmpty) return 'unknown';
    return trimmed.toLowerCase();
  }

  int _statusPriority(String key) {
    const priorities = [
      'verification',
      'pendingverification',
      'intransit',
      'accepted',
      'declined',
      'unknown',
    ];
    final normalized = key.toLowerCase();
    final index = priorities.indexOf(normalized);
    return index == -1 ? priorities.length : index;
  }

  String _formatStatus(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 'Status';
    }

    const overrides = {
      'verification': 'Verification',
      'pendingverification': 'Pending Verification',
      'intransit': 'In Transit',
      'accepted': 'Accepted',
      'declined': 'Declined',
      'outfordelivery': 'Out for Delivery',
      'enroute': 'En Route',
      'tamperdetection': 'Tamper Detection',
      'tampercheck': 'Tamper Check',
      'completed': 'Completed',
      'delivered': 'Delivered',
    };

    final normalized = _normalizeStatus(trimmed);
    if (overrides.containsKey(normalized)) {
      return overrides[normalized]!;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      final isLetter = RegExp(r'[A-Za-z0-9]').hasMatch(char);
      if (i == 0) {
        buffer.write(char.toUpperCase());
        continue;
      }
      final previous = trimmed[i - 1];
      final isCurrentUpper =
          char.toUpperCase() == char && char.toLowerCase() != char;
      final needsSpace = isCurrentUpper && previous != ' ';
      if (needsSpace) buffer.write(' ');
      if (char == '_' || char == '-') {
        buffer.write(' ');
      } else if (isLetter) {
        buffer.write(char);
      }
    }

    final result = buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    return result.isEmpty ? 'Status' : result;
  }
}

class CustomerOrderSection {
  const CustomerOrderSection({
    required this.key,
    required this.label,
    required this.orders,
  });

  final String key;
  final String label;
  final List<WarehouseOrder> orders;
}

class _StatusAccumulator {
  _StatusAccumulator({required this.rawLabel});

  final String rawLabel;
  final List<WarehouseOrder> orders = [];
}
