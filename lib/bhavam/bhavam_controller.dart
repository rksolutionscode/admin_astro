import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bhavam_model.dart';
import 'bhavam_service.dart';

class BhavamController extends GetxController {
  RxList<BhavamModel> sins = <BhavamModel>[].obs;
  final selectedSin = RxnInt();
  final selectedType = 'All'.obs; // Add selectedType
  final TextEditingController noteController = TextEditingController();
  String? bearerToken;

  var allowedBhavams = <int>[].obs;
  var hasPermission = false.obs;
  var isLoading = false.obs; // Add isLoading for UI feedback

  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  final List<Map<String, dynamic>> sinList = [
    {'id': 1, 'name': 'முதல் பாவம்'},
    {'id': 2, 'name': 'இரண்டாம் பாவம்'},
    {'id': 3, 'name': 'மூன்றாம் பாவம்'},
    {'id': 4, 'name': 'நான்காம் பாவம்'},
    {'id': 5, 'name': 'ஐந்தாம் பாவம்'},
    {'id': 6, 'name': 'ஆறாம் பாவம்'},
    {'id': 7, 'name': 'ஏழாம் பாவம்'},
    {'id': 8, 'name': 'எட்டாம் பாவம்'},
    {'id': 9, 'name': 'ஒன்பதாம் பாவம்'},
    {'id': 10, 'name': 'பத்தாம் பாவம்'},
    {'id': 11, 'name': 'பதினொன்றாம் பாவம்'},
    {'id': 12, 'name': 'பன்னிரண்டாம் பாவம்'},
  ];

  void initData(String token, int adminId) {
    if (bearerToken != null) return;
    bearerToken = token;
    print('Initializing BhavamController with token: $token');

    fetchAdminPermissions(adminId).then((_) {
      ever(selectedSin, (_) => fetchSins());
      ever(selectedType, (_) => fetchSins()); // Fetch sins when type changes
      if (selectedSin.value != null) fetchSins();
    });
  }

  Future<void> fetchAdminPermissions(int adminId) async {
    if (bearerToken == null) return;
    try {
      print('Fetching admin permissions for adminId: $adminId');
      final access = await BhavamService.fetchAdminAccess(
        bearerToken!,
        adminId,
      );
      allowedBhavams.value =
          access
              .where((p) => p['moduleName'] == 'Sin')
              .map((p) => p['moduleId'] as int)
              .toList();
      hasPermission.value = allowedBhavams.isNotEmpty;
      print('Allowed Bhavams: $allowedBhavams');
      if (hasPermission.value) selectedSin.value = allowedBhavams.first;
    } catch (e) {
      hasPermission.value = false;
      print('Permission fetch failed: $e');
      Get.snackbar(
        "Error",
        "Permission fetch failed: $e",
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> fetchSins() async {
    if (bearerToken == null || selectedSin.value == null) return;
    isLoading.value = true;
    try {
      print(
        'Fetching sins for sinId: ${selectedSin.value}, type: ${selectedType.value}',
      );
      final data = await BhavamService.fetchSinsBySinId(
        bearerToken!,
        selectedSin.value!,
        selectedType.value == 'All'
            ? null
            : selectedType.value, // Filter by type
      );
      sins.assignAll(data);
      print('Fetched ${data.length} sins');
    } catch (e) {
      print('Failed to fetch sins: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch sins: $e',
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSin() async {
    if (bearerToken == null || selectedSin.value == null) return;
    if (!allowedBhavams.contains(selectedSin.value)) {
      print('Access denied for sinId: ${selectedSin.value}');
      Get.snackbar(
        "Error",
        "You don’t have access to this பாவம்",
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final desc = noteController.text.trim();
    if (desc.isEmpty) {
      print('Note is empty');
      Get.snackbar(
        'Error',
        'Please enter a note',
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      print(
        'Adding sin: description="$desc", sinId=${selectedSin.value}, type=${selectedType.value}',
      );
      await BhavamService.createSin(
        bearerToken!,
        22, // postId (consider generating dynamically if needed)
        selectedSin.value!,
        desc,
        selectedType.value == 'All' ? 'Positive' : selectedType.value,
      );

      noteController.clear();
      await fetchSins();
      print('Sin added successfully');
      Get.snackbar(
        'Success',
        'Sin added successfully',
        backgroundColor: Colors.green.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      print('Error adding sin: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> updateSin(int postId, String newDesc) async {
    if (bearerToken == null || selectedSin.value == null) return;
    if (!allowedBhavams.contains(selectedSin.value)) {
      print('Access denied for sinId: ${selectedSin.value}');
      Get.snackbar(
        "Error",
        "You don’t have access to this பாவம்",
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      print(
        'Updating sin $postId with newDesc="$newDesc", type=${selectedType.value}',
      );
      await BhavamService.updateSin(
        bearerToken!,
        postId,
        newDesc,
        selectedType.value == 'All' ? 'Positive' : selectedType.value,
      );

      await fetchSins();
      print('Sin updated successfully');
      Get.snackbar(
        'Success',
        'Sin updated successfully',
        backgroundColor: Colors.green.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      print('Failed to update sin: $e');
      Get.snackbar(
        'Error',
        'Failed to update sin: $e',
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> deleteSin(int postId) async {
    if (bearerToken == null || selectedSin.value == null) return;
    if (!allowedBhavams.contains(selectedSin.value)) {
      print('Access denied for sinId: ${selectedSin.value}');
      Get.snackbar(
        "Error",
        "You don’t have access to this பாவம்",
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      print('Deleting sin $postId');
      await BhavamService.deleteSin(bearerToken!, postId);
      await fetchSins();
      print('Sin deleted successfully');
      Get.snackbar(
        'Success',
        'Sin deleted successfully',
        backgroundColor: Colors.green.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      print('Failed to delete sin: $e');
      Get.snackbar(
        'Error',
        'Failed to delete sin: $e',
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> pickAndUploadFile() async {
    if (bearerToken == null || selectedSin.value == null) return;
    if (!allowedBhavams.contains(selectedSin.value)) {
      print('Access denied for sinId: ${selectedSin.value}');
      Get.snackbar(
        "Error",
        "You don’t have access to this பாவம்",
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      try {
        final lines = await file.readAsLines();
        print('Read ${lines.length} lines from file');

        final sins =
            lines.where((line) => line.trim().isNotEmpty).map((line) {
              print('Preparing sin: $line');
              return {
                'description': line.trim(),
                'type':
                    selectedType.value == 'All'
                        ? 'Positive'
                        : selectedType.value,
              };
            }).toList();

        await BhavamService.bulkUploadSins(
          bearerToken!,
          selectedSin.value!,
          sins,
        );

        await fetchSins();
        print('Bulk upload successful');
        Get.snackbar(
          'Success',
          'All sins added successfully',
          backgroundColor: Colors.green.shade100,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      } catch (e) {
        print('Failed to upload sins: $e');
        Get.snackbar(
          'Error',
          'Failed to upload sins: $e',
          backgroundColor: Colors.red.shade100,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  List<DropdownMenuItem<int>> get dropdownItems {
    return allowedBhavams
        .map(
          (id) => DropdownMenuItem(
            value: id,
            child: Text(sinList.firstWhere((s) => s['id'] == id)['name']),
          ),
        )
        .toList();
  }
}
