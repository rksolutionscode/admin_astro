import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testadm/bhavam/bhavam_service.dart';
import 'package:testadm/sidebar/sidebar.dart';
import '../sugggestion/PrefsHelper.dart';
import 'bhavam_controller.dart';
import 'bhavam_utils.dart';
import 'package:uuid/uuid.dart';

class BhavamScreen extends StatelessWidget {
  final BhavamController controller = Get.put(BhavamController());

  BhavamScreen({super.key});

  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  Future<void> _initController() async {
    print('Initializing controller...');
    final token = await PrefsHelper.getToken();
    final adminId = await PrefsHelper.getAdminId();
    print('Fetched token: $token');
    print('Fetched adminId: $adminId');
    if (token != null && adminId != null) {
      print('Calling controller.initData with token and adminId');
      controller.initData(token, adminId);
    } else {
      print('Token or adminId is null, cannot initialize controller');
    }
  }

  Future<void> showBulkUploadDialog(BuildContext context) async {
    final bulkController = TextEditingController();
    final selectedType = 'Positive'.obs;
    final selectedSin = controller.selectedSin;

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
                  "பல குறிப்புகள் சேர்க்க",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 20),
                // TextField for notes
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
                // Sin dropdown
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
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: selectedSin.value,
                      hint: const Text("பாவம் தேர்ந்தெடுக்கவும்"),
                      underline: const SizedBox(),
                      items: controller.dropdownItems,
                      onChanged: (int? value) {
                        if (value != null) {
                          selectedSin.value = value;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Type dropdown
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
                                  child: Text(
                                    type,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) selectedType.value = newValue;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Buttons
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
                          if (selectedSin.value == null) {
                            Get.snackbar(
                              "பிழை",
                              "ஒரு பாவம் தேர்ந்தெடுக்கவும்",
                              backgroundColor: Colors.red.shade100,
                              borderRadius: 12,
                              margin: const EdgeInsets.all(16),
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
                            Get.snackbar(
                              "பிழை",
                              "குறிப்புகளை உள்ளிடவும்",
                              backgroundColor: Colors.red.shade100,
                              borderRadius: 12,
                              margin: const EdgeInsets.all(16),
                            );
                            return;
                          }
                          try {
                            for (var note in notes) {
                              await BhavamService.createSin(
                                controller.bearerToken!,
                                1, // Backend will auto-generate postId
                                selectedSin.value!,
                                note.trim(),
                                selectedType.value,
                              );
                            }
                            await controller.fetchSins();
                            Get.back();
                            Get.snackbar(
                              "வெற்றி",
                              "அனைத்து குறிப்புகளும் சேர்க்கப்பட்டன",
                              backgroundColor: Colors.green.shade100,
                              borderRadius: 12,
                              margin: const EdgeInsets.all(16),
                            );
                          } catch (e) {
                            print('Upload failed: $e');
                            Get.snackbar(
                              "பிழை",
                              "சில குறிப்புகளை சேர்க்க முடியவில்லை: $e",
                              backgroundColor: Colors.red.shade100,
                              borderRadius: 12,
                              margin: const EdgeInsets.all(16),
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

  @override
  Widget build(BuildContext context) {
    _initController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 768;
    final isMediumScreen = screenWidth >= 600;

    return Scaffold(
      drawer: isLargeScreen ? null : const Sidebar(),
      appBar:
          isLargeScreen
              ? null
              : AppBar(
                backgroundColor: Colors.deepOrange,
                title: const Text(
                  "Bhavam",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                leading: Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                ),
              ),
      floatingActionButton:
          isLargeScreen
              ? null
              : FloatingActionButton(
                backgroundColor: Colors.deepOrange,
                onPressed: () async {
                  if (controller.selectedSin.value == null) {
                    Get.snackbar(
                      "பிழை",
                      "ஒரு குறிப்பிட்ட பாவம் தேர்வு செய்யவும்.",
                      backgroundColor: Colors.red.shade100,
                      borderRadius: 12,
                      margin: const EdgeInsets.all(16),
                    );
                    return;
                  }
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['xlsx', 'xls', 'csv'],
                    );
                    if (result != null && result.files.single.path != null) {
                      await controller.pickAndUploadFile();
                    }
                  } catch (e) {
                    Get.snackbar(
                      "பிழை",
                      "பதிவு சேர்க்க முடியவில்லை: $e",
                      backgroundColor: Colors.red.shade100,
                      borderRadius: 12,
                      margin: const EdgeInsets.all(16),
                    );
                  }
                },
                child: const Icon(Icons.upload_file, color: Colors.white),
                tooltip: 'Upload Bhavam Notes',
              ),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen)
              Container(
                width: screenWidth * 0.2,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: const Sidebar(),
              ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.orange.shade50,
                      Colors.white,
                      Colors.orange.shade50,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      if (isLargeScreen)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.deepOrange.shade400,
                                  Colors.deepOrange.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "பாவம் குறிப்புகள்",
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isLargeScreen) const SizedBox(height: 20),
                      // Filter Section
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isLargeScreen)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "தேர்வு செய்யப்பட்ட பாவம்:",
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 16 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        "வகை:",
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 16 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (isLargeScreen) const SizedBox(height: 12),
                              Obx(() {
                                if (!controller.hasPermission.value) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "பாவம் தேர்வு செய்ய உங்களுக்கு அனுமதி இல்லை",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                }
                                return isLargeScreen
                                    ? Row(
                                      children: [
                                        // Sin dropdown
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.deepOrange
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            child: DropdownButton<int>(
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              value:
                                                  controller.selectedSin.value,
                                              onChanged: (newValue) {
                                                if (newValue != null) {
                                                  controller.selectedSin.value =
                                                      newValue;
                                                  controller.fetchSins();
                                                }
                                              },
                                              items: controller.dropdownItems,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Type dropdown
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.deepOrange
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              value:
                                                  controller.selectedType.value,
                                              onChanged: (newType) {
                                                if (newType != null)
                                                  controller
                                                      .selectedType
                                                      .value = newType;
                                              },
                                              items:
                                                  allTypes
                                                      .map(
                                                        (
                                                          type,
                                                        ) => DropdownMenuItem(
                                                          value: type,
                                                          child: Text(
                                                            type,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : Column(
                                      children: [
                                        // Sin dropdown
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.deepOrange
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: DropdownButton<int>(
                                            isExpanded: true,
                                            underline: const SizedBox(),
                                            value: controller.selectedSin.value,
                                            onChanged: (newValue) {
                                              if (newValue != null) {
                                                controller.selectedSin.value =
                                                    newValue;
                                                controller.fetchSins();
                                              }
                                            },
                                            items: controller.dropdownItems,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Type dropdown
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.deepOrange
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            underline: const SizedBox(),
                                            value:
                                                controller.selectedType.value,
                                            onChanged: (newType) {
                                              if (newType != null)
                                                controller.selectedType.value =
                                                    newType;
                                            },
                                            items:
                                                allTypes
                                                    .map(
                                                      (
                                                        type,
                                                      ) => DropdownMenuItem(
                                                        value: type,
                                                        child: Text(
                                                          type,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                        ),
                                      ],
                                    );
                              }),
                              const SizedBox(height: 16),
                              // Add Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                onPressed: () => showBulkUploadDialog(context),
                                child: const Text(
                                  "குறிப்புகள் சேர்க்க",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Data Table Section
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Obx(() {
                              if (controller.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.deepOrange,
                                  ),
                                );
                              }
                              if (controller.sins.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inbox,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "தேர்வு செய்யப்பட்ட பாவத்திற்கு தொடர்புடைய தரவுகள் இல்லை",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 18 : 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              if (isLargeScreen) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.deepOrange.shade50,
                                    ),
                                    headingRowHeight: 60,
                                    columnSpacing: 24,
                                    dataRowHeight: 60,
                                    horizontalMargin: 16,
                                    headingTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isLargeScreen ? 16 : 14,
                                      color: Colors.deepOrange.shade800,
                                    ),
                                    dataTextStyle: TextStyle(
                                      fontSize: isLargeScreen ? 15 : 13,
                                    ),
                                    columns: [
                                      DataColumn(
                                        label: SizedBox(
                                          width: 60,
                                          child: Text(
                                            'பி.நி',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Text(
                                            'குறிப்பு',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 120,
                                          child: Text(
                                            'செயல்கள்',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows:
                                        controller.sins.asMap().entries.map((
                                          entry,
                                        ) {
                                          final index = entry.key + 1;
                                          final item = entry.value;
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Center(
                                                  child: Text(index.toString()),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        isLargeScreen
                                                            ? 600
                                                            : 200,
                                                  ),
                                                  child: Text(
                                                    item.description,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                      ),
                                                      onPressed: () {
                                                        final editController =
                                                            TextEditingController(
                                                              text:
                                                                  item.description,
                                                            );
                                                        Get.dialog(
                                                          Dialog(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    16,
                                                                  ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Text(
                                                                    'குறிப்பை திருத்து',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          Colors
                                                                              .deepOrange,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 16,
                                                                  ),
                                                                  TextField(
                                                                    controller:
                                                                        editController,
                                                                    maxLines: 5,
                                                                    decoration: InputDecoration(
                                                                      border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                      ),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Colors
                                                                              .grey
                                                                              .shade50,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 16,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: TextButton(
                                                                          onPressed:
                                                                              () =>
                                                                                  Get.back(),
                                                                          child: const Text(
                                                                            'ரத்து',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                Colors.deepOrange,
                                                                            foregroundColor:
                                                                                Colors.white,
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(
                                                                                12,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onPressed: () {
                                                                            controller.updateSin(
                                                                              item.postId,
                                                                              editController.text,
                                                                            );
                                                                            Get.back();
                                                                          },
                                                                          child: const Text(
                                                                            'சேமி',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        Get.dialog(
                                                          Dialog(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    16,
                                                                  ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Text(
                                                                    'குறிப்பை நீக்கு',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          Colors
                                                                              .deepOrange,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 16,
                                                                  ),
                                                                  const Text(
                                                                    'இந்த குறிப்பை நீக்க விரும்புகிறீர்களா?',
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 16,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: TextButton(
                                                                          onPressed:
                                                                              () =>
                                                                                  Get.back(),
                                                                          child: const Text(
                                                                            'ரத்து',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                Colors.deepOrange,
                                                                            foregroundColor:
                                                                                Colors.white,
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(
                                                                                12,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onPressed: () async {
                                                                            await controller.deleteSin(
                                                                              item.postId,
                                                                            );
                                                                            Get.back();
                                                                          },
                                                                          child: const Text(
                                                                            'நீக்கு',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                );
                              } else {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                    ),
                                    child: DataTable(
                                      headingRowColor:
                                          MaterialStateProperty.all(
                                            Colors.deepOrange.shade100,
                                          ),
                                      headingRowHeight: 60,
                                      columnSpacing: 16,
                                      dataRowHeight: 50,
                                      headingTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      dataTextStyle: const TextStyle(
                                        fontSize: 13,
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('பி.நி')),
                                        DataColumn(label: Text('குறிப்பு')),
                                        DataColumn(label: Text('செயல்கள்')),
                                      ],
                                      rows:
                                          controller.sins.asMap().entries.map((
                                            entry,
                                          ) {
                                            final index = entry.key + 1;
                                            final item = entry.value;
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(index.toString()),
                                                ),
                                                DataCell(
                                                  Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                          maxWidth: 200,
                                                        ),
                                                    child: Text(
                                                      item.description,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color: Colors.blue,
                                                          size: 18,
                                                        ),
                                                        onPressed: () {
                                                          final editController =
                                                              TextEditingController(
                                                                text:
                                                                    item.description,
                                                              );
                                                          Get.dialog(
                                                            Dialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      16,
                                                                    ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      16,
                                                                    ),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    const Text(
                                                                      'குறிப்பை திருத்து',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.deepOrange,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          16,
                                                                    ),
                                                                    TextField(
                                                                      controller:
                                                                          editController,
                                                                      maxLines:
                                                                          5,
                                                                      decoration: InputDecoration(
                                                                        border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                        ),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            Colors.grey.shade50,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          16,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: TextButton(
                                                                            onPressed:
                                                                                () =>
                                                                                    Get.back(),
                                                                            child: const Text(
                                                                              'ரத்து',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child: ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor:
                                                                                  Colors.deepOrange,
                                                                              foregroundColor:
                                                                                  Colors.white,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  12,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onPressed: () {
                                                                              controller.updateSin(
                                                                                item.postId,
                                                                                editController.text,
                                                                              );
                                                                              Get.back();
                                                                            },
                                                                            child: const Text(
                                                                              'சேமி',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                          size: 18,
                                                        ),
                                                        onPressed: () {
                                                          Get.dialog(
                                                            Dialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      16,
                                                                    ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      16,
                                                                    ),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    const Text(
                                                                      'குறிப்பை நீக்கு',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.deepOrange,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          16,
                                                                    ),
                                                                    const Text(
                                                                      'இந்த குறிப்பை நீக்க விரும்புகிறீர்களா?',
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          16,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: TextButton(
                                                                            onPressed:
                                                                                () =>
                                                                                    Get.back(),
                                                                            child: const Text(
                                                                              'ரத்து',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child: ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor:
                                                                                  Colors.deepOrange,
                                                                              foregroundColor:
                                                                                  Colors.white,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  12,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onPressed: () async {
                                                                              await controller.deleteSin(
                                                                                item.postId,
                                                                              );
                                                                              Get.back();
                                                                            },
                                                                            child: const Text(
                                                                              'நீக்கு',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bottom Button (only shown on large screens)
                      if (isLargeScreen)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.upload_file),
                            label: const Text(
                              "கோப்பு பதிவேற்று",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              if (controller.selectedSin.value == null) {
                                Get.snackbar(
                                  "பிழை",
                                  "ஒரு குறிப்பிட்ட பாவம் தேர்வு செய்யவும்.",
                                  backgroundColor: Colors.red.shade100,
                                  borderRadius: 12,
                                  margin: const EdgeInsets.all(16),
                                );
                                return;
                              }
                              try {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['xlsx', 'xls', 'csv'],
                                    );
                                if (result != null &&
                                    result.files.single.path != null) {
                                  await controller.pickAndUploadFile();
                                }
                              } catch (e) {
                                Get.snackbar(
                                  "பிழை",
                                  "பதிவு சேர்க்க முடியவில்லை: $e",
                                  backgroundColor: Colors.red.shade100,
                                  borderRadius: 12,
                                  margin: const EdgeInsets.all(16),
                                );
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
