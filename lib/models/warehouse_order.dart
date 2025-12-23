import 'package:cloud_firestore/cloud_firestore.dart';

class WarehouseOrder {
  const WarehouseOrder({
    required this.id,
    required this.itemName,
    required this.customerName,
    required this.customerId,
    required this.address,
    required this.status,
    required this.eta,
    required this.priority,
    this.submittedAt,
    this.imageUrl,
    this.modelUrl,
    this.createdAt,
  });

  final String id;
  final String itemName;
  final String customerName;
  final String address;
  final String customerId;
  final String status;
  final String eta;
  final String priority;
  final DateTime? submittedAt;
  final String? imageUrl;
  final String? modelUrl;
  final DateTime? createdAt;

  WarehouseOrder copyWith({
    String? id,
    String? itemName,
    String? customerName,
    String? address,
    String? customerId,
    String? status,
    String? eta,
    String? priority,
    DateTime? submittedAt,
    String? imageUrl,
    String? modelUrl,
    DateTime? createdAt,
  }) {
    return WarehouseOrder(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      address: address ?? this.address,
      status: status ?? this.status,
      eta: eta ?? this.eta,
      priority: priority ?? this.priority,
      submittedAt: submittedAt ?? this.submittedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      modelUrl: modelUrl ?? this.modelUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory WarehouseOrder.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    final submittedAt = _parseDate(map['submittedAt']);
    final createdAt = _parseDate(map['createdAt']);

    return WarehouseOrder(
      id: (map['id'] as String?) ?? documentId ?? '',
      itemName: map['itemName'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      address: map['address'] as String? ?? '',
      status: map['status'] as String? ?? '',
      eta: map['eta'] as String? ?? '',
      priority: map['priority'] as String? ?? '',
      submittedAt: submittedAt,
      imageUrl: map['imageUrl'] as String?,
      modelUrl: map['modelUrl'] as String?,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'customerName': customerName,
      'customerId': customerId,
      'address': address,
      'status': status,
      'eta': eta,
      'priority': priority,
      'submittedAt': submittedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'modelUrl': modelUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'itemName': itemName,
      'customerName': customerName,
      'customerId': customerId,
      'address': address,
      'status': status,
      'eta': eta,
      'priority': priority,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      if (modelUrl != null && modelUrl!.isNotEmpty) 'modelUrl': modelUrl,
      if (submittedAt != null) 'submittedAt': Timestamp.fromDate(submittedAt!),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw is Timestamp) {
      return raw.toDate();
    }
    if (raw is DateTime) {
      return raw;
    }
    if (raw is String) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}
