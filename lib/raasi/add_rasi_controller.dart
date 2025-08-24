import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:testadm/permission_controller.dart';
import 'rasi_model.dart';
import 'rasi_service.dart';
import 'rasi_utils.dart';

class AddRasiController extends GetxController {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  RxList<String> rasis = <String>[].obs;
  RxString selectedRasi = 'எல்லா ராசிகள்'.obs;
  RxList<RasiModel> raasiPosts = <RasiModel>[].obs;

  RxString selectedType = 'All'.obs;
  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  final TextEditingController noteController = TextEditingController();

  final List<String> allRasis = [
    'எல்லா ராசிகள்',
    'மேஷம்',
    'ரிஷபம்',
    'மிதுனம்',
    'கடகம்',
    'சிம்மம்',
    'கன்னி',
    'துலாம்',
    'விருச்சிகம்',
    'தனுசு',
    'மகரம்',
    'கும்பம்',
    'மீனம்',
  ];

  String? bearerToken;

  // ⇩ UPDATED BLOCK
  List<RasiModel> get filteredPosts {
    // Filter by rasi
    List<RasiModel> list;
    if (selectedRasi.value == 'எல்லா ராசிகள்') {
      list = raasiPosts;
    } else {
      final id = rasiNameToId(selectedRasi.value);
      print("Filtering posts for rasiId: $id");
      list = raasiPosts.where((post) => post.raasiId == id).toList();
    }

    // Filter by type (only if not "All")
    if (selectedType.value != 'All') {
      list = list.where((post) => post.type == selectedType.value).toList();
    }

    return list;
  }
  // ⇧ END OF UPDATED BLOCK

  void initData(String token) {
    if (bearerToken != null) return;
    bearerToken = token;
    print("Bearer token initialized: $bearerToken");

    _filterRasisByPermission();
    fetchRaasiPosts();
  }

  void _filterRasisByPermission() {
    // This contains the moduleIds -> example:   [2,4]
    final allowedRasiIds = PermissionController.to.rasiIds;
    print("Allowed Rasi Ids from PermissionController: $allowedRasiIds");

    if (allowedRasiIds.isEmpty) {
      rasis.value = allRasis;
      return;
    }

    // Convert allowed ids → names
    final List<String> filteredNames =
        allowedRasiIds
            .map((id) => rasiIdToName(id))
            .whereType<String>()
            .toList();

    // Add "எல்லா ராசிகள்" at the top
    rasis.value = ['எல்லா ராசிகள்', ...filteredNames];

    print("Filtered rasis for dropdown: $rasis");
  }

  Future<void> fetchRaasiPosts() async {
    if (bearerToken == null) return;

    try {
      final adminId = await _getAdminId();
      final posts = await RasiService.fetchRasiPostsByAdmin(
        bearerToken!,
        adminId,
      );
      raasiPosts.assignAll(posts);
      print("Fetched ${posts.length} Rasi posts (for admin $adminId)");
    } catch (e) {
      print("Error fetching posts: $e");
      showSnackBar("தரவுகளைப் பெற முடியவில்லை: $e");
    }
  }

  Future<void> addSingleNote() async {
    final rasi = selectedRasi.value;
    final note = noteController.text.trim();
    String type = selectedType.value;

    if (rasi == 'எல்லா ராசிகள்' || note.isEmpty) {
      showSnackBar('தயவுசெய்து ராசி தேர்வு செய்து ஒரு குறிப்பை உள்ளிடவும்');
      return;
    }

    if (type == 'All') {
      type = 'Positive'; // default backend-compatible type
    }

    await addRaasiPost(rasi, note, type);
  }

  Future<void> addRaasiPost(
    String rasiName,
    String content,
    String type, {
    bool showSnack = true, // optional
  }) async {
    final raasiId = rasiNameToId(rasiName);
    if (raasiId == null) {
      if (showSnack) showSnackBar("தவறான ராசி தேர்வு");
      return;
    }

    try {
      await RasiService.addRasiPost(
        bearerToken!,
        raasiId,
        content,
        await _getAdminId(),
        type: type,
      );
      noteController.clear();
      await fetchRaasiPosts();
      if (showSnack) showSnackBar("$rasiName வெற்றிகரமாக சேர்க்கப்பட்டது!");
      print("Successfully added post for $rasiName");
    } catch (e) {
      print("Error adding post: $e");
      if (showSnack) showSnackBar("பதிவு தோல்வி: $e");
      rethrow;
    }
  }

  Future<void> uploadCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) {
      print("CSV file not selected");
      showSnackBar("CSV கோப்பு தேர்வு செய்யவில்லை.");
      return;
    }

    final file = File(result.files.single.path!);
    final rawData = await file.readAsString();
    final csvData = CsvToListConverter().convert(rawData);
    print("CSV data read: ${csvData.length} rows");

    for (var row in csvData) {
      if (row.length >= 3) {
        final rasi = row[0].toString().trim();
        final note = row[1].toString().trim();
        final type = row[2].toString().trim();
        print("Processing CSV row -> rasi: $rasi, type: $type, note: $note");

        if (rasi.isNotEmpty && note.isNotEmpty && allTypes.contains(type)) {
          await addRaasiPost(rasi, note, type);
        }
      }
    }

    print("CSV upload completed");
    showSnackBar("CSV கோப்பு வெற்றிகரமாக பதிவேற்றப்பட்டது.");
    await fetchRaasiPosts();
  }

  Future<void> deleteRaasiPost(int postId) async {
    print("Deleting postId: $postId");

    try {
      await RasiService.deleteRasiPost(bearerToken!, postId);
      showSnackBar("குறிப்பு நீக்கப்பட்டது");
      await fetchRaasiPosts();
    } catch (e) {
      print("Error deleting post: $e");
      showSnackBar("நீக்கு தோல்வி: $e");
    }
  }

  Future<void> updateRaasiPost(
    int postId,
    String content,
    int raasiId,
    String type,
  ) async {
    print(
      "Updating postId: $postId -> raasiId: $raasiId, type: $type, content: $content",
    );

    try {
      await RasiService.updateRasiPost(
        bearerToken!,
        postId,
        content,
        raasiId,
        type: type,
      );
      showSnackBar("குறிப்பு திருத்தப்பட்டது");
      await fetchRaasiPosts();
    } catch (e) {
      print("Error updating post: $e");
      showSnackBar("திருத்தம் தோல்வி: $e");
    }
  }

  void showEditDialog(RasiModel post) {
    final editController = TextEditingController(text: post.content);
    String selectedRasiForEdit = rasiIdToName(post.raasiId) ?? 'மேஷம்';
    RxString selectedTypeForEdit = post.type.obs;

    print(
      "Opening edit dialog for postId: ${post.postId}, current rasiId: ${post.raasiId}",
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'குறிப்பு திருத்து',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              isExpanded: true,
              value: selectedRasiForEdit,
              items:
                  allRasis
                      .where((rasi) => rasi != 'எல்லா ராசிகள்')
                      .map(
                        (rasi) =>
                            DropdownMenuItem(value: rasi, child: Text(rasi)),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) selectedRasiForEdit = value;
                print("Selected rasi for edit: $selectedRasiForEdit");
              },
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedTypeForEdit.value,
              items:
                  allTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) selectedTypeForEdit.value = value;
                print("Selected type for edit: ${selectedTypeForEdit.value}");
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'புதிய குறிப்பு',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(child: const Text('ரத்து'), onPressed: () => Get.back()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('சேமி'),
            onPressed: () async {
              final newId = rasiNameToId(selectedRasiForEdit);
              if (newId == null) {
                showSnackBar("தவறான ராசி தேர்வு");
                return;
              }
              await updateRaasiPost(
                post.postId,
                editController.text,
                newId,
                selectedTypeForEdit.value,
              );
              Get.back();
            },
          ),
        ],
      ),
    );
  }

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
                  "பல பதிவு குறிப்புகள் சேர்க்க",
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

                // Rasi dropdown
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
                                (rasi) => DropdownMenuItem(
                                  value: rasi,
                                  child: Text(rasi),
                                ),
                              )
                              .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) selectedRasi.value = newValue;
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
                        if (newValue != null) selectedType.value = newValue;
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
                        onPressed: () => Get.back(),
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
                          final rasi = selectedRasi.value;
                          final type = selectedType.value;

                          if (rasi == 'எல்லா ராசிகள்') {
                            showSnackBar(
                              "குறிப்புகள் சேர்க்கும் முன் ஒரு குறிப்பிட்ட ராசி தேர்வு செய்யவும்.",
                            );
                            return;
                          }

                          bool success = true;

                          for (final note in notes) {
                            if (note.trim().isNotEmpty) {
                              String typeToSend =
                                  type == 'All' ? 'Positive' : type;
                              try {
                                await addRaasiPost(
                                  rasi,
                                  note.trim(),
                                  typeToSend,
                                  showSnack: false,
                                );
                              } catch (e) {
                                success = false;
                                print("Error adding note: $e");
                              }
                            }
                          }

                          // Close the dialog **after all posts are added**
                          if (success) {
                            Get.back(); // close dialog
                            showSnackBar(
                              "$rasi க்கான அனைத்து குறிப்புகளும் வெற்றிகரமாக சேர்க்கப்பட்டன.",
                            );
                          } else {
                            showSnackBar(
                              "சில குறிப்புகளை சேர்க்க முடியவில்லை, மீண்டும் முயற்சிக்கவும்.",
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

  Future<int> _getAdminId() async => 8;

  void showSnackBar(String message) {
    print("SnackBar: $message");
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Text(message, style: const TextStyle(color: Colors.white)),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      margin: const EdgeInsets.all(8),
    );
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
