import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testadm/permission_controller.dart';
import 'package:testadm/sidebar/routing.dart';
import 'package:testadm/services/auth_controller.dart';
import 'package:testadm/sugggestion/PrefsHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("[MAIN] Flutter binding initialized");

  // Initialize controllers
  Get.put(PermissionController());
  print("[MAIN] PermissionController initialized");

  final authController = Get.put(AuthController());
  print("[MAIN] AuthController initialized");

  // Determine initial route
  String initialRoute = '/logincredential';
  try {
    final token = await PrefsHelper.getToken();
    final adminId = await PrefsHelper.getAdminId() ?? 0;

    print("[MAIN] Token retrieved: $token");
    print("[MAIN] AdminId retrieved: $adminId");

    if (token != null && token.isNotEmpty) {
      authController.setToken(token);
      authController.setAdminId(adminId);
      initialRoute = '/lagnam';
      print("[MAIN] Token valid, setting initialRoute to /lagnam");
    }
  } catch (e) {
    print("[MAIN] Error reading token: $e");
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    print("[MyApp] Building GetMaterialApp with initialRoute: $initialRoute");
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
    );
  }
}
