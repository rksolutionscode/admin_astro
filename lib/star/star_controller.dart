import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testadm/star/star_model.dart';
import 'package:testadm/star/star_services.dart';
import 'package:testadm/star/star_utils.dart';

class StarController extends GetxController {
  final StarService service;

  StarController({required this.service});

  var posts = <StarPost>[].obs;
  var selectedRasi = 'அனைத்து நட்சத்திரங்கள்'.obs;
  var selectedType = 'All'.obs;
  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  @override
  void onInit() {
    super.onInit();
    print("StarController initialized");
    fetchPosts();
  }

  // Fetch all star posts
  Future<void> fetchPosts() async {
    try {
      print("Fetching all star posts...");
      final result = await service.fetchAllPosts();
      posts.value = result;
      print("Fetched ${posts.length} posts");
    } catch (e) {
      print("Fetch Error: $e");
    }
  }

  // Create a new star post
 Future<void> createPost(int starId, String description, String type) async {
    try {
      print(
        "Creating post for starId: $starId, description: $description, type: $type",
      );
      await service.createPost(starId, description, type); // pass type
      await fetchPosts();
      print("Post created successfully");
    } catch (e) {
      print("Create Error: $e");
    }
  }


  // Update an existing post
  Future<void> updatePost(int postId, String content, int starId) async {
    try {
      print(
        "Updating postId: $postId with content: $content for starId: $starId",
      );
      await service.updatePost(postId, content, starId);
      await fetchPosts();
      print("Post updated successfully");
    } catch (e) {
      print("Update Error: $e");
    }
  }

  // Delete a post
  Future<void> deletePost(int postId) async {
    try {
      print("Deleting postId: $postId");
      await service.deletePost(postId);
      await fetchPosts();
      print("Post deleted successfully");
    } catch (e) {
      print("Delete Error: $e");
    }
  }

  // Show edit dialog for a post
  void showEditDialog(BuildContext context, StarPost post) {
    final textController = TextEditingController(text: post.description);
    final starIndex = post.starId;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Edit Star Note"),
            content: TextField(controller: textController),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  print("Edit cancelled for postId: ${post.postId}");
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: Text("Update"),
                onPressed: () async {
                  if (textController.text.isNotEmpty) {
                    print("Updating postId: ${post.postId}");
                    await updatePost(
                      post.postId,
                      textController.text,
                      starIndex,
                    );
                    Navigator.pop(context);
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
                // Title
                const Text(
                  "பல நட்சத்திர குறிப்புகள் சேர்க்க",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),

                // Notes input
                TextField(
                  controller: bulkController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: "ஒரு வரியில் குறிப்புகளை சேர்க்கவும்...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 15),

                // Star dropdown
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
                      value: selectedRasi.value,
                      underline: const SizedBox(),
                      items:
                          rasis
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
                          print("Selected star changed to: $newValue");
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Type dropdown
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
                      onChanged: (newValue) {
                        if (newValue != null) {
                          selectedType.value = newValue;
                          print("Selected type changed to: $newValue");
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Action buttons
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
                          print("Bulk upload cancelled");
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
                          "பதிவேற்றவும்",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final notes = bulkController.text.trim().split('\n');
                          final star = selectedRasi.value;
                          final type = selectedType.value;

                          print(
                            "Bulk upload started for star: $star, type: $type",
                          );

                          if (star == 'அனைத்து நட்சத்திரங்கள்') {
                            print("Error: No specific star selected");
                            Get.snackbar(
                              "பிழை",
                              "ஒரு குறிப்பிட்ட நட்சத்திரத்தை தேர்வு செய்யவும்.",
                              backgroundColor: Colors.red.shade100,
                            );
                            return;
                          }

                          bool success = true;

                         for (final note in notes) {
                            if (note.trim().isNotEmpty) {
                              String typeToSend =
                                  type == 'All' ? 'Positive' : type;
                              try {
                                print("Adding note: $note");
                                await service.createPost(
                                  rasis.indexOf(star) + 1, // starId
                                  note.trim(), // description/content
                                  typeToSend, // type
                                );
                              } catch (e) {
                                success = false;
                                print("Error adding note: $e");
                              }
                            }
                          }


                          if (success) {
                            print("All notes added successfully for $star");
                            Get.back(); // close dialog
                            fetchPosts(); // refresh list
                            Get.snackbar(
                              "வெற்றி",
                              "$star க்கான அனைத்து குறிப்புகளும் சேர்க்கப்பட்டன.",
                              backgroundColor: Colors.green.shade100,
                            );
                          } else {
                            print("Some notes failed to upload for $star");
                            Get.snackbar(
                              "பிழை",
                              "சில குறிப்புகளை சேர்க்க முடியவில்லை.",
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
