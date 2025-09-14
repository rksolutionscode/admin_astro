import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testadm/raasi/add_rasi_controller.dart';
import 'package:testadm/raasi/rasi_utils.dart';
import 'package:testadm/sidebar/sidebar.dart';

class AddRasiScreen extends StatelessWidget {
  final String bearerToken;

  AddRasiScreen({Key? key, required this.bearerToken}) : super(key: key);

  final AddRasiController controller = Get.put(AddRasiController());
  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 768;
    final isMediumScreen = screenWidth >= 600;

    controller.initData();

    return Scaffold(
      key: controller.scaffoldKey,
      drawer: isLargeScreen ? null : const Sidebar(),
      appBar:
          isLargeScreen
              ? null
              : AppBar(
                backgroundColor: Colors.deepOrange,
                title: const Text(
                  "ராசி",
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
                onPressed: controller.pickAndUploadFile,
                child: const Icon(Icons.upload_file, color: Colors.white),
                tooltip: 'Upload Rasi Notes',
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
                                  "ராசி குறிப்புகள்",
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
                                        "தேர்வு செய்யப்பட்ட ராசி:",
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
                              Obx(
                                () =>
                                    isLargeScreen
                                        ? Row(
                                          children: [
                                            // Rasi dropdown for large screens
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                      controller
                                                          .selectedRasi
                                                          .value,
                                                  onChanged: (newValue) {
                                                    if (newValue != null) {
                                                      controller
                                                          .selectedRasi
                                                          .value = newValue;
                                                    }
                                                  },
                                                  items:
                                                      controller.rasis
                                                          .map(
                                                            (
                                                              rasi,
                                                            ) => DropdownMenuItem(
                                                              value: rasi,
                                                              child: Text(
                                                                rasi,
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Type dropdown for large screens
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                      controller
                                                          .selectedType
                                                          .value,
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
                                                                      fontSize:
                                                                          14,
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
                                            // Rasi dropdown for small screens
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                    controller
                                                        .selectedRasi
                                                        .value,
                                                onChanged: (newValue) {
                                                  if (newValue != null) {
                                                    controller
                                                        .selectedRasi
                                                        .value = newValue;
                                                  }
                                                },
                                                items:
                                                    controller.rasis
                                                        .map(
                                                          (
                                                            rasi,
                                                          ) => DropdownMenuItem(
                                                            value: rasi,
                                                            child: Text(
                                                              rasi,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // Type dropdown for small screens
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                    controller
                                                        .selectedType
                                                        .value,
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
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
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
                                onPressed: controller.showBulkUploadDialog,
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

                              if (controller.filteredPosts.isEmpty) {
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
                                        "தேர்வு செய்யப்பட்ட ராசிக்கு தொடர்புடைய தரவுகள் இல்லை",
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

                              // For web, use a more sophisticated data table
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
                                        controller.filteredPosts
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                              final index = entry.key + 1;
                                              final post = entry.value;

                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Center(
                                                      child: Text(
                                                        index.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                            maxWidth:
                                                                isLargeScreen
                                                                    ? 600
                                                                    : 200,
                                                          ),
                                                      child: Text(
                                                        post.content ?? '',
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            color: Colors.blue,
                                                          ),
                                                          onPressed:
                                                              () => controller
                                                                  .showEditDialog(
                                                                    post,
                                                                  ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed:
                                                              () => controller
                                                                  .deleteRaasiPost(
                                                                    post.postId,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            })
                                            .toList(),
                                  ),
                                );
                              } else {
                                // Mobile layout
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
                                      columns: const [
                                        DataColumn(label: Text('பி.நி')),
                                        DataColumn(label: Text('குறிப்பு')),
                                        DataColumn(label: Text('செயல்கள்')),
                                      ],
                                      rows:
                                          controller.filteredPosts.asMap().entries.map((
                                            entry,
                                          ) {
                                            final index = entry.key + 1;
                                            final post = entry.value;

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
                                                      post.content ?? '',
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
                                                        onPressed:
                                                            () => controller
                                                                .showEditDialog(
                                                                  post,
                                                                ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                          size: 18,
                                                        ),
                                                        onPressed:
                                                            () => controller
                                                                .deleteRaasiPost(
                                                                  post.postId,
                                                                ),
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
                            }
                            ),
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
                            onPressed: controller.pickAndUploadFile,
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
