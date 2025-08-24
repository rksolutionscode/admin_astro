import 'package:get/get.dart';
import 'package:testadm/bhavam.dart';
import 'package:testadm/display/advertisement.dart';
import 'package:testadm/display/ai.dart';
import 'package:testadm/display/dhosham.dart';
import 'package:testadm/display/logincredintial.dart';
import 'package:testadm/display/malar.dart';
import 'package:testadm/display/mantrigam.dart';
import 'package:testadm/display/pariharam.dart';
import 'package:testadm/display/parvai.dart';
import 'package:testadm/display/prasanam.dart';
import 'package:testadm/display/thantrigam.dart';
import 'package:testadm/lagnam.dart';
import 'package:testadm/logincredintial.dart';
import 'package:testadm/logindata.dart';
import 'package:testadm/planet.dart';
import 'package:testadm/profiledata.dart';
import 'package:testadm/raasi/add_rasi_screen.dart';
import 'package:testadm/rasi.dart';
import 'package:testadm/services/auth_controller.dart';
import 'package:testadm/star.dart';
import 'package:testadm/star/star_screen.dart';
import 'package:testadm/sugggestion/feedbqack.dart';
import 'package:testadm/threecombination.dart';
import 'package:testadm/twoplanetconjuction.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/logincredential', page: () => Logincredintialpage()),
    GetPage(
      name: '/rasi',
      page: () => AddRasiScreen(bearerToken: authController.token.value),
    ),

    GetPage(name: '/planet', page: () => PlanetScreen()),
    GetPage(name: '/star', page: () => StarScreen(bearerToken: '',)),
    GetPage(name: '/suggestion', page: () => Suggestion()),
    GetPage(name: '/lagnam', page: () => Lagnam()),
    GetPage(name: '/twocombination', page: () => Twoplanetconjuction()),
    GetPage(name: '/threecombination', page: () => Threecombination()),
    GetPage(name: '/bhavam', page: () => bhavamScreen()),
    GetPage(name: '/login', page: () => Logindata()),
    GetPage(name: '/ai', page: () => AddAiScreen()),
    GetPage(name: '/dhosham', page: () => Dhosham()),
    GetPage(name: '/malar', page: () => Malar()),
    GetPage(name: '/mantrigam', page: () => Mantrigam()),
    GetPage(name: '/pariharam', page: () => Pariharam()),
    GetPage(name: '/paravi', page: () => Parvai()),
    GetPage(name: '/prasanam', page: () => Prasanam()),
    GetPage(name: '/thantrigam', page: () => Thantrigam()),
    GetPage(name: '/advertisement', page: () => Advertisement()),
    GetPage(name: '/profile', page: () => ProfileData()),
    GetPage(name: '/logincredential', page: () => Logincredintialpage()),
  ];
}
