import 'dart:io' show File, HttpHeaders;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'giraham_model.dart';
import 'giraham_service.dart';
import 'giraham_utils.dart';

class GirahamController extends GetxController {
  RxList<GirahamModel> girahams = <GirahamModel>[].obs;
  RxString selectedPlanet = planetList[0].obs;
  RxString selectedType = 'All'.obs;
  RxBool isLoading = false.obs;
  RxBool hasPermission = true.obs;
  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];
  final TextEditingController descController = TextEditingController();
  String? bearerToken;
  RxList<String> accessiblePlanets = <String>[].obs;

  /// Initialize with token and adminId
  Future<void> initData(String token, int adminId) async {
    if (bearerToken != null) {
      print('initData: Token already set, skipping initialization.');
      return;
    }
    bearerToken = token;
    print('initData: Initializing with token: $token, adminId: $adminId');
    await fetchAdminAccess(adminId);
    if (accessiblePlanets.isNotEmpty) {
      selectedPlanet.value = accessiblePlanets.first;
      print('initData: Selected planet: ${selectedPlanet.value}');
      await fetchGirahams();
    } else {
      hasPermission.value = false;
      print('initData: No accessible planets, permission denied.');
    }
  }

  /// Fetch admin access and filter planets
  Future<void> fetchAdminAccess(int adminId) async {
    if (bearerToken == null) {
      print('fetchAdminAccess: No bearer token available.');
      return;
    }
    try {
      print('fetchAdminAccess: Fetching permissions for adminId: $adminId');
      final permissions = await GirahamService.fetchAdminAccess(
        bearerToken!,
        adminId,
      );
      final planets =
          permissions
              .where((p) => p['moduleName'] == 'Giraham')
              .map<String?>((p) => planetFromGirahamId(p['moduleId']))
              .whereType<String>()
              .toList();
      accessiblePlanets.assignAll(planets);
      print('fetchAdminAccess: Accessible planets: $planets');
    } catch (e) {
      print('fetchAdminAccess: Error fetching permissions: $e');
      showSnackBar('அணுகல் பெறுவதில் பிழை: $e', isError: true);
    }
  }

  /// Fetch girahams by planet and type
  Future<void> fetchGirahams() async {
    if (bearerToken == null || selectedPlanet.value == planetList[0]) {
      print('fetchGirahams: Invalid token or planet: ${selectedPlanet.value}');
      return;
    }
    isLoading.value = true;
    print(
      'fetchGirahams: Loading data for planet: ${selectedPlanet.value}, type: ${selectedType.value}',
    );
    try {
      final planetId = girahamIdFromPlanet(selectedPlanet.value);
      if (planetId == null) {
        print('fetchGirahams: Invalid planetId for ${selectedPlanet.value}');
        showSnackBar('தவறான கிரகம் தேர்ந்தெடுக்கப்பட்டது', isError: true);
        return;
      }
      print('fetchGirahams: Fetching all girahams for filtering.');
      final allGirahams = await GirahamService.fetchAllGiraham(bearerToken!);
      final filtered =
          allGirahams.where((g) {
            final matchesPlanet = g.girahamId == planetId;
            final matchesType =
                selectedType.value == 'All' || g.type == selectedType.value;
            return matchesPlanet && matchesType;
          }).toList();
      girahams.assignAll(filtered);
      print('fetchGirahams: Filtered ${filtered.length} girahams.');
    } catch (e) {
      print('fetchGirahams: Error fetching girahams: $e');
      showSnackBar('கிரகங்களை பெற முடியவில்லை: $e', isError: true);
    } finally {
      isLoading.value = false;
      print('fetchGirahams: Loading complete, isLoading: ${isLoading.value}');
    }
  }

  /// Add a new Giraham
  Future<void> addGiraham(int girahamId, String desc, String type) async {
    if (bearerToken == null) {
      print('addGiraham: No bearer token available.');
      return;
    }
    if (desc.trim().isEmpty) {
      print('addGiraham: Description is empty.');
      showSnackBar('குறிப்பு காலியாக இருக்கக்கூடாது', isError: true);
      return;
    }
    try {
      print(
        'addGiraham: Adding giraham with id: $girahamId, desc: $desc, type: $type',
      );
      await GirahamService.createGiraham(bearerToken!, girahamId, desc, type);
      descController.clear();
      await fetchGirahams();
      print('addGiraham: Giraham added successfully.');
      showSnackBar('கிரகம் வெற்றிகரமாக சேர்க்கப்பட்டது!', isError: false);
    } catch (e) {
      print('addGiraham: Error adding giraham: $e');
      showSnackBar('கிரகம் சேர்க்க முடியவில்லை: $e', isError: true);
    }
  }

  /// Update Giraham
  Future<void> updateGiraham(int id, String desc, String type) async {
    if (bearerToken == null) {
      print('updateGiraham: No bearer token available.');
      return;
    }
    if (desc.trim().isEmpty) {
      print('updateGiraham: Description is empty.');
      showSnackBar('குறிப்பு காலியாக இருக்கக்கூடாது', isError: true);
      return;
    }
    try {
      print(
        'updateGiraham: Updating giraham with id: $id, desc: $desc, type: $type',
      );
      await GirahamService.updateGiraham(bearerToken!, id, desc, type);
      await fetchGirahams();
      print('updateGiraham: Giraham updated successfully.');
      showSnackBar('கிரகம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது!', isError: false);
    } catch (e) {
      print('updateGiraham: Error updating giraham: $e');
      showSnackBar('கிரகம் புதுப்பிக்க முடியவில்லை: $e', isError: true);
    }
  }

  /// Delete Giraham
  Future<void> deleteGiraham(int id) async {
    if (bearerToken == null) {
      print('deleteGiraham: No bearer token available.');
      return;
    }
    try {
      print('deleteGiraham: Deleting giraham with id: $id');
      await GirahamService.deleteGiraham(bearerToken!, id);
      await fetchGirahams();
      print('deleteGiraham: Giraham deleted successfully.');
      showSnackBar('கிரகம் வெற்றிகரமாக நீக்கப்பட்டது!', isError: false);
    } catch (e) {
      print('deleteGiraham: Error deleting giraham: $e');
      showSnackBar('கிரகம் நீக்க முடியவில்லை: $e', isError: true);
    }
  }

  /// Show bulk upload dialog
  Future<void> showBulkUploadDialog() async {
    final bulkController = TextEditingController();
    final selectedType = this.selectedType;
    final selectedPlanet = this.selectedPlanet;

    print('showBulkUploadDialog: Opening bulk upload dialog.');
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "பல கிரகம் குறிப்புகள் சேர்க்க",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bulkController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: "ஒரு வரியில் குறிப்புகளை சேர்க்கவும்...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.deepOrange.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value:
                          selectedPlanet.value == planetList[0]
                              ? null
                              : selectedPlanet.value,
                      underline: const SizedBox(),
                      items:
                          accessiblePlanets
                              .map(
                                (planet) => DropdownMenuItem(
                                  value: planet,
                                  child: Text(planet),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          selectedPlanet.value = val;
                          print(
                            'showBulkUploadDialog: Planet changed to: $val',
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.deepOrange.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedType.value,
                      underline: const SizedBox(),
                      items:
                          allTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          selectedType.value = val;
                          print('showBulkUploadDialog: Type changed to: $val');
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("ரத்து செய்யவும்"),
                        onPressed: () {
                          print('showBulkUploadDialog: Dialog cancelled.');
                          Get.back();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "பதிவேற்றவும்",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final planetId = girahamIdFromPlanet(
                            selectedPlanet.value,
                          );
                          if (planetId == null) {
                            print(
                              'showBulkUploadDialog: Invalid planetId for ${selectedPlanet.value}',
                            );
                            showSnackBar(
                              'ஒரு கிரகம் தேர்ந்தெடுக்கவும்',
                              isError: true,
                            );
                            return;
                          }
                          final notes =
                              bulkController.text
                                  .trim()
                                  .split('\n')
                                  .where((line) => line.trim().isNotEmpty)
                                  .toList();
                          if (notes.isEmpty) {
                            print(
                              'showBulkUploadDialog: No valid notes provided.',
                            );
                            showSnackBar(
                              'குறிப்புகளை உள்ளிடவும்',
                              isError: true,
                            );
                            return;
                          }
                          try {
                            print(
                              'showBulkUploadDialog: Uploading ${notes.length} notes.',
                            );
                            for (var note in notes) {
                              await addGiraham(
                                planetId,
                                note.trim(),
                                selectedType.value,
                              );
                            }
                            print(
                              'showBulkUploadDialog: All notes uploaded successfully.',
                            );
                            Get.back();
                            showSnackBar(
                              'அனைத்து குறிப்புகளும் சேர்க்கப்பட்டன',
                              isError: false,
                            );
                          } catch (e) {
                            print(
                              'showBulkUploadDialog: Error uploading notes: $e',
                            );
                            showSnackBar(
                              'சில குறிப்புகளை சேர்க்க முடியவில்லை: $e',
                              isError: true,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show edit dialog
  void showEditDialog(BuildContext context, GirahamModel item) {
    final editController = TextEditingController(text: item.description);
    final selectedType = item.type.obs;

    print('showEditDialog: Opening edit dialog for giraham id: ${item.id}');
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'குறிப்பை திருத்து',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: editController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepOrange.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedType.value,
                    underline: const SizedBox(),
                    items:
                        allTypes
                            .where((type) => type != 'All')
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        selectedType.value = val;
                        print('showEditDialog: Type changed to: $val');
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        print('showEditDialog: Dialog cancelled.');
                        Get.back();
                      },
                      child: const Text('ரத்து'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        print(
                          'showEditDialog: Saving changes for giraham id: ${item.id}',
                        );
                        updateGiraham(
                          item.id,
                          editController.text.trim(),
                          selectedType.value,
                        );
                        Get.back();
                      },
                      child: const Text('சேமி'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show delete dialog
  void showDeleteDialog(BuildContext context, GirahamModel item) {
    print('showDeleteDialog: Opening delete dialog for giraham id: ${item.id}');
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'குறிப்பை நீக்கு',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 16),
              const Text('இந்த குறிப்பை நீக்க விரும்புகிறீர்களா?'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        print('showDeleteDialog: Dialog cancelled.');
                        Get.back();
                      },
                      child: const Text('ரத்து'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        print(
                          'showDeleteDialog: Deleting giraham id: ${item.id}',
                        );
                        await deleteGiraham(item.id);
                        Get.back();
                      },
                      child: const Text('நீக்கு'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show snackbar
  void showSnackBar(String msg, {required bool isError}) {
    print(
      'showSnackBar: Displaying snackbar - isError: $isError, message: $msg',
    );
    Get.snackbar(
      isError ? 'பிழை' : 'வெற்றி',
      msg,
      backgroundColor: isError ? Colors.red.shade100 : Colors.green.shade100,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      colorText: Colors.black,
    );
  }

  /// File upload
  Future<void> pickAndUploadFile() async {
    if (bearerToken == null || selectedPlanet.value == planetList[0]) {
      print(
        'pickAndUploadFile: Invalid token or planet: ${selectedPlanet.value}',
      );
      showSnackBar('ஒரு குறிப்பிட்ட கிரகம் தேர்ந்தெடுக்கவும்', isError: true);
      return;
    }
    try {
      print('pickAndUploadFile: Opening file picker.');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );
      if (result == null || result.files.isEmpty) {
        print('pickAndUploadFile: No file selected.');
        showSnackBar('கோப்பு தேர்ந்தெடுக்கப்படவில்லை', isError: true);
        return;
      }
      final file = result.files.single;
      print(
        'pickAndUploadFile: Selected file: ${file.name}, extension: ${file.extension}',
      );
      final planetId = girahamIdFromPlanet(selectedPlanet.value);
      if (planetId == null) {
        print(
          'pickAndUploadFile: Invalid planetId for ${selectedPlanet.value}',
        );
        showSnackBar('தவறான கிரகம் தேர்ந்தெடுக்கப்பட்டது', isError: true);
        return;
      }
      print('pickAndUploadFile: Uploading file for planetId: $planetId');
      if (kIsWeb) {
        await GirahamService.bulkUploadGirahamFile(bearerToken!, file);
      } else {
        await GirahamService.bulkUploadGirahamFile(
          bearerToken!,
          File(file.path!),
        );
      }
      await fetchGirahams();
      print('pickAndUploadFile: File upload completed successfully.');
      showSnackBar('கோப்பு வெற்றிகரமாக பதிவேற்றப்பட்டது', isError: false);
    } catch (e) {
      print('pickAndUploadFile: Error during file upload: $e');
      showSnackBar('கோப்பு பதிவேற்றத்தில் பிழை: $e', isError: true);
    }
  }
}
