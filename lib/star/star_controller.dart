import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testadm/star/star_model.dart';
import 'package:testadm/star/star_services.dart';
import 'package:testadm/star/star_utils.dart';

class StarController extends GetxController {
  final StarService service;
  var posts = <StarPost>[].obs;
  var selectedRasi = 'அனைத்து நட்சத்திரங்கள்'.obs;
  var selectedType = 'Positive'.obs; // Default to 'Positive' instead of 'All'
  var accessibleRasis = <String>[].obs; // List of accessible stars
  var hasPermission = true.obs;
  var isLoading = false.obs; // << Add this


  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  StarController({required this.service});

  @override
  void onInit() {
    super.onInit();
    print('StarController: Initialized');
    fetchAdminAccess(); // fetch accessible stars
    fetchPosts(); // fetch all posts
  }


  Future<void> fetchAdminAccess() async {
    try {
      print('StarController: Fetching admin access');
      final permissions = await service.fetchAdminAccess(
        1,
      ); // Replace with actual adminId
      final stars =
          permissions
              .where((p) => p['moduleName'] == 'Star')
              .map<String?>(
                (p) => starIdToName(p['moduleId']),
              ) // <-- fixed here
              .whereType<String>()
              .toList();
      accessibleRasis.assignAll(stars);
      if (stars.isNotEmpty) {
        selectedRasi.value =
            stars.first; // Set first accessible star as default
        print('StarController: Accessible stars: $stars');
      } else {
        hasPermission.value = false;
        print('StarController: No accessible stars, permission denied');
      }
    } catch (e) {
      print('StarController: Error fetching admin access: $e');
      Get.snackbar(
        'பிழை',
        'அணுகல் பெறுவதில் பிழை: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  // Fetch all star posts
  Future<void> fetchPosts() async {
    try {
      print('StarController: Fetching all star posts');
      final result = await service.fetchAllPosts();
      posts.value = result;
      print('StarController: Fetched ${posts.length} posts');
    } catch (e) {
      print('StarController: Fetch Error: $e');
      Get.snackbar(
        'பிழை',
        'குறிப்புகளை பெற முடியவில்லை: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  // Create a new star post
  Future<void> createPost(int starId, String description, String type) async {
    try {
      print(
        'StarController: Creating post for starId: $starId, description: $description, type: $type',
      );
      await service.createPost(starId, description, type);
      await fetchPosts();
      print('StarController: Post created successfully');
      Get.snackbar(
        'வெற்றி',
        'குறிப்பு வெற்றிகரமாக சேர்க்கப்பட்டது',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      print('StarController: Create Error: $e');
      Get.snackbar(
        'பிழை',
        'குறிப்பு சேர்க்க முடியவில்லை: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  // Update an existing post
  Future<void> updatePost(int postId, String content, int starId) async {
    try {
      print(
        'StarController: Updating postId: $postId with content: $content for starId: $starId',
      );
      await service.updatePost(postId, content, starId);
      await fetchPosts();
      print('StarController: Post updated successfully');
      Get.snackbar(
        'வெற்றி',
        'குறிப்பு வெற்றிகரமாக புதுப்பிக்கப்பட்டது',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      print('StarController: Update Error: $e');
      Get.snackbar(
        'பிழை',
        'குறிப்பு புதுப்பிக்க முடியவில்லை: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  // Delete a post
  Future<void> deletePost(int postId) async {
    try {
      print('StarController: Deleting postId: $postId');
      await service.deletePost(postId);
      await fetchPosts();
      print('StarController: Post deleted successfully');
      Get.snackbar(
        'வெற்றி',
        'குறிப்பு வெற்றிகரமாக நீக்கப்பட்டது',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      print('StarController: Delete Error: $e');
      Get.snackbar(
        'பிழை',
        'குறிப்பு நீக்க முடியவில்லை: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  // Show edit dialog for a post
  void showEditDialog(BuildContext context, StarPost post) {
    final textController = TextEditingController(text: post.description);
    final starIndex = post.starId;

    print('StarController: Opening edit dialog for postId: ${post.postId}');
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Star Note'),
            content: TextField(controller: textController),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  print(
                    'StarController: Edit cancelled for postId: ${post.postId}',
                  );
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('Update'),
                onPressed: () async {
                  if (textController.text.isNotEmpty) {
                    print('StarController: Updating postId: ${post.postId}');
                    await updatePost(
                      post.postId,
                      textController.text,
                      starIndex,
                    );
                    Navigator.pop(context);
                  } else {
                    print('StarController: Empty content, update cancelled');
                    Get.snackbar(
                      'பிழை',
                      'குறிப்பு காலியாக இருக்கக்கூடாது',
                      backgroundColor: Colors.red.shade100,
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  // Bulk upload dialog
  Future<void> showBulkUploadDialog() async {
    final bulkController = TextEditingController();

    print('StarController: Opening bulk upload dialog');
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 700),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'பல நட்சத்திர குறிப்புகள் சேர்க்க',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bulkController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'ஒரு வரியில் குறிப்புகளை சேர்க்கவும்...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 15),
                // Star dropdown (only accessible stars)
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value:
                          accessibleRasis.contains(selectedRasi.value)
                              ? selectedRasi.value
                              : null,
                      hint: const Text('நட்சத்திரத்தை தேர்ந்தெடுக்கவும்'),
                      underline: const SizedBox.shrink(),
                      items:
                          accessibleRasis
                              .map(
                                (star) => DropdownMenuItem(
                                  value: star,
                                  child: Text(star),
                                ),
                              )
                              .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          selectedRasi.value = newValue;
                          print(
                            'StarController: Selected star changed to: $newValue',
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Type dropdown (exclude 'All')
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedType.value,
                      underline: const SizedBox.shrink(),
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
                      onChanged: (newValue) {
                        if (newValue != null) {
                          selectedType.value = newValue;
                          print(
                            'StarController: Selected type changed to: $newValue',
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('ரத்து செய்யவும்'),
                        onPressed: () {
                          print('StarController: Bulk upload cancelled');
                          Get.back();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'பதிவேற்றவும்',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final notes = bulkController.text.trim().split('\n');
                          final star = selectedRasi.value;
                          final type = selectedType.value;

                          if (!accessibleRasis.contains(star)) {
                            print(
                              'StarController: Invalid star selected: $star',
                            );
                            Get.snackbar(
                              'பிழை',
                              'ஒரு குறிப்பிட்ட நட்சத்திரத்தை தேர்வு செய்யவும்.',
                              backgroundColor: Colors.red.shade100,
                            );
                            return;
                          }

                          final starId = rasis.indexOf(star);
                          bool success = true;

                          print(
                            'StarController: Uploading ${notes.length} notes for star: $star',
                          );
                          for (final note in notes) {
                            if (note.trim().isNotEmpty) {
                              try {
                                print('StarController: Adding note: $note');
                                await service.createPost(
                                  starId,
                                  note.trim(),
                                  type,
                                );
                              } catch (e) {
                                success = false;
                                print('StarController: Error adding note: $e');
                              }
                            }
                          }

                          if (success) {
                            print(
                              'StarController: All notes added successfully for $star',
                            );
                            Get.back();
                            await fetchPosts();
                            Get.snackbar(
                              'வெற்றி',
                              '$star க்கான அனைத்து குறிப்புகளும் சேர்க்கப்பட்டன.',
                              backgroundColor: Colors.green.shade100,
                            );
                          } else {
                            print(
                              'StarController: Some notes failed to upload for $star',
                            );
                            Get.snackbar(
                              'பிழை',
                              'சில குறிப்புகளை சேர்க்க முடியவில்லை.',
                              backgroundColor: Colors.red.shade100,
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
}
