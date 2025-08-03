import 'package:get/get.dart';

class PermissionController extends GetxController {
  RxMap<String, List<String>> permissions = <String, List<String>>{}.obs;

  static PermissionController get to => Get.find<PermissionController>();

  void setPermissions(Map<String, dynamic> permissionMap) {
    permissions.value = permissionMap.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );
  }

  bool hasAccess(String type, String value) {
    return permissions[type]?.contains(value) ?? false;
  }

  List<String> getAllowedValues(String type) {
    return permissions[type] ?? [];
  }

  List<String> get allowedRasis => permissions["rasi"] ?? [];
  List<String> get allowedLagnams => permissions["lagnam"] ?? [];
  List<String> get allowedBhavams => permissions["bhavam"] ?? [];
  List<String> get allowedPlanets => permissions["planet"] ?? [];
  List<String> get allowedStars => permissions["star"] ?? [];
  List<String> get allowedCombinations => permissions["combination"] ?? [];
}
