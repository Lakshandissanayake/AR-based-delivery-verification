import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/warehouse_order.dart';

class WarehouseService {
  WarehouseService({FirebaseFirestore? firestore})
    : _ordersCollection = (firestore ?? FirebaseFirestore.instance).collection(
        'orders',
      );

  final CollectionReference<Map<String, dynamic>> _ordersCollection;
  static const List<String> _verificationStatuses = <String>[
    'pendingVerification',
    'accepted',
    'declined',
  ];

  Stream<List<WarehouseOrder>> listenToOrders() {
    return _ordersCollection.snapshots().map(_mapSnapshot);
  }

  Stream<List<WarehouseOrder>> listenToCustomerOrders({
    required String customerId,
    String? status,
  }) {
    Query<Map<String, dynamic>> query = _ordersCollection.where(
      'customerId',
      isEqualTo: customerId,
    );

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    print(
      'query: $query.where("customerId", isEqualTo: $customerId).where("status", isEqualTo: $status).orderBy("submittedAt", descending: true).snapshots().map(_mapSnapshot)',
    );

    return query.orderBy('submittedAt', descending: true).snapshots().map((
      snapshot,
    ) {
      final orders = _mapSnapshot(snapshot);
      print(
        'DEBUG orders for $customerId: '
        '${orders.map((o) => '${o.id} / ${o.customerId} / ${o.status}').toList()}',
      );
      return orders;
    });
  }

  Stream<List<WarehouseOrder>> listenToVerificationOrders() {
    return _ordersCollection
        .where('status', whereIn: _verificationStatuses)
        .snapshots()
        .map(_mapSnapshot);
  }

  Future<List<WarehouseOrder>> fetchOrdersOnce() async {
    final snapshot = await _ordersCollection.get();
    return _mapSnapshot(snapshot);
  }

  Future<List<WarehouseOrder>> fetchOrdersOnceForCustomer({
    required String customerId,
    String? status,
  }) async {
    Query<Map<String, dynamic>> query = _ordersCollection.where(
      'customerId',
      isEqualTo: customerId,
    );

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.orderBy('submittedAt', descending: true).get();
    return _mapSnapshot(snapshot);
  }

  Future<void> markOrderPendingVerification({
    required String orderId,
    DateTime? submittedAt,
  }) async {
    await _ordersCollection.doc(orderId).update({
      'status': 'pendingVerification',
      'eta': 'Submitted',
      'submittedAt': submittedAt != null
          ? Timestamp.fromDate(submittedAt)
          : FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _ordersCollection.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  List<WarehouseOrder> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map((doc) => WarehouseOrder.fromMap(doc.data(), documentId: doc.id))
        .where((order) => order.id.isNotEmpty)
        .toList(growable: false);
  }
}
