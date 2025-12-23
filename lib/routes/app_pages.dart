import 'package:get/get.dart';

import '../controllers/customer_navigation_controller.dart';
import '../controllers/customer_orders_controller.dart';
import '../controllers/customer_register_controller.dart';
import '../views/customer/customer_home_view.dart';
import '../views/customer/customer_order_details_view.dart';
import '../views/customer/customer_tamper_capture_view.dart';
import '../views/customer/customer_tamper_model_view.dart';
import '../views/customer/customer_tamper_result_view.dart';
import '../views/customer/register_view.dart';
import '../views/delivery/delivery_home_view.dart';
import '../views/login_view.dart';
import '../views/warehouse/order_details_view.dart';
import '../views/warehouse/package_suggestion_view.dart';
import '../views/warehouse/verification_capture_view.dart';
import '../views/warehouse/verification_model_view.dart';
import '../views/warehouse/warehouse_home_view.dart';

abstract class Routes {
  static const String login = '/login';
  static const String warehouseHome = '/warehouse';
  static const String orderDetails = '/order-details';
  static const String packageSuggestion = '/package-suggestion';
  static const String verificationCapture = '/verification-capture';
  static const String verificationModel = '/verification-model';
  static const String register = '/register';
  static const String deliveryHome = '/delivery';
  static const String customerHome = '/customer';
  static const String customerOrderDetails = '/customer/order-details';
  static const String customerTamperCapture = '/customer/tamper-capture';
  static const String customerTamperModel = '/customer/tamper-model';
  static const String customerTamperResult = '/customer/tamper-result';
}

class AppPages {
  static const String initial = Routes.login;

  static final List<GetPage<dynamic>> routes = [
    GetPage(name: Routes.login, page: () => const LoginView()),
    GetPage(name: Routes.warehouseHome, page: () => const WarehouseHomeView()),
    GetPage(
      name: Routes.orderDetails,
      page: () => const OrderDetailsView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.packageSuggestion,
      page: () => const PackageSuggestionView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.verificationCapture,
      page: () => const VerificationCaptureView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.verificationModel,
      page: () => const VerificationModelView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => CustomerRegisterController()),
      ),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.deliveryHome,
      page: () => const DeliveryHomeView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.customerHome,
      page: () => const CustomerHomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(CustomerOrdersController.new);
        Get.lazyPut(CustomerNavigationController.new);
      }),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.customerOrderDetails,
      page: () => const CustomerOrderDetailsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CustomerOrdersController>()) {
          Get.put(CustomerOrdersController());
        }
      }),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.customerTamperCapture,
      page: () => const CustomerTamperCaptureView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CustomerOrdersController>()) {
          Get.put(CustomerOrdersController());
        }
      }),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.customerTamperModel,
      page: () => const CustomerTamperModelView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CustomerOrdersController>()) {
          Get.put(CustomerOrdersController());
        }
      }),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.customerTamperResult,
      page: () => const CustomerTamperResultView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CustomerOrdersController>()) {
          Get.put(CustomerOrdersController());
        }
      }),
      transition: Transition.cupertino,
    ),
  ];
}
