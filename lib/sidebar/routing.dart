import 'package:get/get.dart';
import 'package:testadm/bhavam/bhavam_screen.dart';
import 'package:testadm/logincredintial.dart';
import 'package:testadm/raasi/add_rasi_screen.dart';
import 'package:testadm/lagnam/laknam_screen.dart';
import 'package:testadm/combination/threecombination_screen.dart';
import 'package:testadm/giraham/giraham_screen.dart';
import 'package:testadm/star/star_screen.dart';
import 'package:testadm/display/logincredintial.dart';
import 'package:testadm/services/auth_controller.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/logincredential', page: () => Logincredintialpage()),
    GetPage(
      name: '/rasi',
      page: () {
        final authController = Get.find<AuthController>();
        return AddRasiScreen(bearerToken: authController.token.value);
      },
    ),
    GetPage(name: '/star', page: () => StarScreen(bearerToken: '')),
    GetPage(name: '/lagnam', page: () => LaknamScreen()),
    GetPage(name: '/twocombination', page: () => GirahamScreen()),
    GetPage(name: '/threecombination', page: () => JoinScreen()),
    GetPage(name: '/bhavam', page: () => BhavamScreen()),
  ];
}
