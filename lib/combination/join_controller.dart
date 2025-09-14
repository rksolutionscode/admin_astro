import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'join_service.dart';
import 'join_model.dart';

class JoinController extends GetxController {
  final JoinService service;

  JoinController({required this.service});

  var isLoading = false.obs;

  // posts = items
  var posts = <JoinModel>[].obs;

  // selected join name (instead of selectedName)
  final selectedJoin = RxString('அனைத்து சேர்க்கைகள்');

  // type filter
  final selectedType = 'All'.obs;

  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  // Permissions (dummy for now, you can integrate your own logic)
  final hasPermission = true.obs;

  // Allowed joins (dummy list for dropdown)
  final List<String> allowedJoins = [
    'அனைத்து சேர்க்கைகள்',
    'சூரியன் + சந்திரன்',
    'சூரியன் + செவ்வாய்',
    'சந்திரன் + புதன்',
  ];

  final noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
    ever(selectedJoin, (_) => fetchPosts());
    ever(selectedType, (_) => fetchPosts());
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  Future<void> addNote(String note) async {
    try {
      await service.createPost(1, note, 'postId', 'type');
      noteController.clear();
      await fetchPosts();
      Get.snackbar("Success", "Note added successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to add note: $e");
    }
  }

  Future<void> updateNote(String id, String newNote) async {
    try {
      await service.updatePost(id, newNote);
      await fetchPosts();
      Get.snackbar("Success", "Note updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update note: $e");
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await service.deletePost(id);
      await fetchPosts();
      Get.snackbar("Success", "Note deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete note: $e");
    }
  }

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      var result = await service.fetchAllPosts();

      // Filter by join description (instead of "name")
      if (selectedJoin.value != 'அனைத்து சேர்க்கைகள்') {
        result =
            result.where((p) => p.description == selectedJoin.value).toList();
      }

      // Filter by type
      if (selectedType.value != 'All') {
        result = result.where((p) => p.type == selectedType.value).toList();
      }

      posts.value = result;
    } catch (e) {
      Get.snackbar("Error", "Unable to fetch Join posts: $e");
    } finally {
      isLoading.value = false;
    }
  }


  // Bulk upload dialog
  void showBulkUploadDialog() {
    if (selectedJoin.value == 'அனைத்து சேர்க்கைகள்') {
      Get.snackbar(
        "பிழை",
        "ஒரு குறிப்பிட்ட சேர்க்கையைத் தேர்வு செய்யவும்.",
        backgroundColor: Colors.red.shade100,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text("Bulk Upload"),
        content: const Text("கோப்பை தேர்வு செய்யவும் (CSV/Excel)"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("ரத்து")),
        ],
      ),
    );
  }

  // Stub for file picker + upload
  Future<void> pickAndUploadFile() async {
    // TODO: integrate File Picker
    Get.snackbar("Info", "File picker not implemented yet");
  }

  // Edit dialog
  void showEditDialog(BuildContext context, JoinModel post) {
    final controller = TextEditingController(text: post.description);

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Note"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              updateNote(
                post.id.toString(),
                controller.text,
              ); // convert to String
              Get.back();
            },
            child: const Text("Save"),
          ),

        ],
      ),
    );
  }
}
