import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'controllers/auth_controller.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/warehouse_controller.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const DeliveryVerificationApp());
}

class DeliveryVerificationApp extends StatelessWidget {
  const DeliveryVerificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '3D Delivery Verification',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(WarehouseController());
        Get.put(NavigationController());
      }),
    );
  }
}
