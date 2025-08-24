import 'package:get/get.dart';

class AuthController extends GetxController {
  final token = ''.obs;
  final adminId = 0.obs;

  void setToken(String newToken) => token.value = newToken;
  void setAdminId(int id) => adminId.value = id;

  bool get isLoggedIn => token.value.isNotEmpty;
}

final authController = Get.put(AuthController());
