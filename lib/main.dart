import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testadm/sidebar/routing.dart';
import 'package:testadm/services/auth_controller.dart';
import 'package:testadm/sugggestion/PrefsHelper.dart';

// Add these imports
import 'package:testadm/combination/join_service.dart';
import 'package:testadm/combination/join_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("[MAIN] Flutter binding initialized");

  // Initialize controllers
  final authController = Get.put(AuthController());
  print("[MAIN] AuthController initialized");

  // ✅ Register JoinService & JoinController
  final joinService = Get.put(JoinService());
  Get.put(JoinController(service: joinService));
  print("[MAIN] JoinService & JoinController initialized");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test Admin App',
      initialRoute: '/splash', // Splash screen first
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        ...AppRoutes.routes, // Existing routes
      ],
    );
  }
}

/// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    String nextRoute = '/logincredential';

    try {
      final token = await PrefsHelper.getToken();
      final adminId = await PrefsHelper.getAdminId() ?? 0;

      print("[Splash] Token: $token, AdminId: $adminId");

      if (token != null && token.isNotEmpty) {
        authController.setToken(token);
        authController.setAdminId(adminId);
        nextRoute = '/lagnam';
      }
    } catch (e) {
      print("[Splash] Error reading auth data: $e");
    }

    // Small delay to show splash effect
    await Future.delayed(Duration(seconds: 2));

    // Navigate to the next screen
    Get.offAllNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
