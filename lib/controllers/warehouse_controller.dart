import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../models/photo_data.dart';
import '../models/warehouse_order.dart';
import '../services/warehouse_service.dart';

class WarehouseController extends GetxController {
  WarehouseController({WarehouseService? warehouseService})
    : _warehouseService = warehouseService ?? WarehouseService();

  final WarehouseService _warehouseService;

  final RxList<WarehouseOrder> orders = <WarehouseOrder>[].obs;
  final RxList<WarehouseOrder> pendingVerifications = <WarehouseOrder>[].obs;
  final Rxn<WarehouseOrder> selectedOrder = Rxn<WarehouseOrder>();
  final RxBool isOrdersLoading = false.obs;
  final RxBool isSendingVerification = false.obs;
  final RxBool isMarkingOutForDelivery = false.obs;
  final RxnString ordersError = RxnString();
  
  // Photo management for 3D model creation
  final RxList<PhotoData> verificationPhotos = <PhotoData>[].obs;
  final RxBool isPickingPhoto = false.obs;

  StreamSubscription<List<WarehouseOrder>>? _ordersSubscription;
  StreamSubscription<List<WarehouseOrder>>? _verificationSubscription;

  @override
  void onInit() {
    _startOrdersListener();
    _startVerificationListener();
    super.onInit();
  }

  void _startOrdersListener() {
    isOrdersLoading.value = true;
    ordersError.value = null;

    _ordersSubscription = _warehouseService.listenToOrders().listen(
      (remoteOrders) {
        orders.assignAll(remoteOrders);
        isOrdersLoading.value = false;
        ordersError.value = null;
      },
      onError: (error, _) {
        ordersError.value = _mapOrdersError(error);
        isOrdersLoading.value = false;
      },
    );
  }

  Future<void> retryOrders() async {
    await _ordersSubscription?.cancel();
    _startOrdersListener();
  }

  String _mapOrdersError(Object error) {
    if (error is FirebaseException) {
      return error.message ?? 'Firebase error while loading orders.';
    }
    return 'Something went wrong while loading orders.';
  }

  void _startVerificationListener() {
    _verificationSubscription = _warehouseService
        .listenToVerificationOrders()
        .listen(
          pendingVerifications.assignAll,
          onError: (Object error, _) {
            pendingVerifications.clear();
          },
        );
  }

  void selectOrder(WarehouseOrder order) {
    selectedOrder.value = order;
  }

  WarehouseOrder? getOrderById(String? id) {
    if (id == null) {
      return selectedOrder.value;
    }

    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (_) {
      try {
        return pendingVerifications.firstWhere((order) => order.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> sendOrderForVerification() async {
    final order = selectedOrder.value;
    if (order == null || isSendingVerification.value) return;

    isSendingVerification.value = true;
    try {
      final submittedAt = DateTime.now();

      await _warehouseService.markOrderPendingVerification(
        orderId: order.id,
        submittedAt: submittedAt,
      );

      orders.removeWhere((element) => element.id == order.id);
      pendingVerifications.removeWhere((element) => element.id == order.id);
      pendingVerifications.add(
        order.copyWith(
          status: 'pendingVerification',
          eta: 'Submitted',
          submittedAt: submittedAt,
        ),
      );
      selectedOrder.value = null;
    } finally {
      isSendingVerification.value = false;
    }
  }

  Future<void> markOrderOutForDelivery(WarehouseOrder order) async {
    if (isMarkingOutForDelivery.value) return;

    isMarkingOutForDelivery.value = true;
    try {
      await _warehouseService.updateOrderStatus(
        orderId: order.id,
        status: 'outfordelivery',
      );

      final updatedOrder = order.copyWith(status: 'outfordelivery');
      _replaceOrder(updatedOrder);
      pendingVerifications.removeWhere((element) => element.id == order.id);
      selectedOrder.value = updatedOrder;
    } finally {
      isMarkingOutForDelivery.value = false;
    }
  }

  void _replaceOrder(WarehouseOrder order) {
    final index = orders.indexWhere((element) => element.id == order.id);
    if (index >= 0) {
      orders[index] = order;
    } else {
      orders.removeWhere((element) => element.id == order.id);
      orders.add(order);
    }
  }

  // Photo management methods
  void clearVerificationPhotos() {
    verificationPhotos.clear();
  }

  Future<void> pickPhoto(int index, {ImageSource source = ImageSource.gallery}) async {
    if (isPickingPhoto.value) return;
    
    isPickingPhoto.value = true;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: source);
      
      if (file != null) {
        // Get image dimensions
        final File imageFile = File(file.path);
        final List<int> imageBytes = await imageFile.readAsBytes();
        final img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));
        
        if (image != null) {
          final photoData = PhotoData(
            path: file.path,
            width: image.width,
            height: image.height,
          );
          
          // Add or replace photo at index
          if (index < verificationPhotos.length) {
            verificationPhotos[index] = photoData;
          } else {
            verificationPhotos.add(photoData);
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPickingPhoto.value = false;
    }
  }

  void removePhoto(int index) {
    if (index < verificationPhotos.length) {
      verificationPhotos.removeAt(index);
    }
  }

  bool get hasAllPhotos => verificationPhotos.length == 6;

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    _verificationSubscription?.cancel();
    super.onClose();
  }
}
