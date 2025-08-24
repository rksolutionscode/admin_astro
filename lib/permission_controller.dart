import 'package:get/get.dart';

class PermissionController extends GetxController {
  static PermissionController get to => Get.find<PermissionController>();

  // Store allowed IDs for each module
  RxList<int> rasiIds = <int>[].obs;
  RxList<int> lagnamIds = <int>[].obs;
  RxList<int> bhavamIds = <int>[].obs;
  RxList<int> planetIds = <int>[].obs;
  RxList<int> starIds = <int>[].obs;
  RxList<int> combinationIds = <int>[].obs;

  /// Call this after login
  void setPermissions(List<dynamic> permissionsList) {
    // Clear old values
    rasiIds.clear();
    lagnamIds.clear();
    bhavamIds.clear();
    planetIds.clear();
    starIds.clear();
    combinationIds.clear();

    for (final perm in permissionsList) {
      final moduleName = perm['moduleName']?.toString().toLowerCase();
      final moduleId = perm['moduleId'];

      if (moduleId is! int) continue;

      switch (moduleName) {
        case 'raasi':
          rasiIds.add(moduleId);
          break;
        case 'lagnam':
          lagnamIds.add(moduleId);
          break;
        case 'bhavam':
          bhavamIds.add(moduleId);
          break;
        case 'planet':
          planetIds.add(moduleId);
          break;
        case 'star':
          starIds.add(moduleId);
          break;
        case 'combination':
          combinationIds.add(moduleId);
          break;
      }
    }

    print('Allowed Rasi IDs => $rasiIds');
  }
}
