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
    final isLargeScreen = screenWidth >= 600;

    controller.initData(bearerToken);

    return Scaffold(
      key: controller.scaffoldKey,
      drawer: isLargeScreen ? null : Sidebar(),
      appBar:
          isLargeScreen
              ? null // no AppBar for large screens
              : AppBar(
                backgroundColor: Colors.deepOrange,
                title: const Text(
                  "Raasi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed:
                      () => controller.scaffoldKey.currentState?.openDrawer(),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: controller.uploadCsvFile,
        child: const Icon(Icons.upload_file, color: Colors.white),
        tooltip: 'CSV கோப்பு பதிவேற்றவும்',
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen)
              SizedBox(width: screenWidth * 0.18, child: Sidebar()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top menu button for small screens

                    // Dropdowns + Add Button Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Only show dropdowns on mobile (small screen)
                            if (!isLargeScreen) ...[
                              Row(
                                children: [
                                  // Rasi Dropdown
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonHideUnderline(
                                      child: Obx(() {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value:
                                                controller.selectedRasi.value,
                                            onChanged: (newValue) {
                                              if (newValue != null) {
                                                controller.selectedRasi.value =
                                                    newValue;
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
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Type Dropdown
                                  Expanded(
                                    flex: 2,
                                    child: Obx(() {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: controller.selectedType.value,
                                          onChanged: (newType) {
                                            if (newType != null) {
                                              controller.selectedType.value =
                                                  newType;
                                            }
                                          },
                                          items:
                                              allTypes
                                                  .map(
                                                    (type) => DropdownMenuItem(
                                                      value: type,
                                                      child: Text(
                                                        type,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                            ],

                            // Add Button (next row)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              onPressed: controller.showBulkUploadDialog,
                              child: const Text(
                                "குறிப்புகள் சேர்க்க",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Data Table Card
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Obx(() {
                            if (controller.filteredPosts.isEmpty) {
                              return const Center(
                                child: Text(
                                  "தேர்வு செய்யப்பட்ட ராசிக்கு தொடர்புடைய தரவுகள் கிடைக்கவில்லை.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            }

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth:
                                      MediaQuery.of(context)
                                          .size
                                          .width, // make table take full width
                                ),
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    Colors.deepOrange.shade100,
                                  ),
                                  columnSpacing:
                                      16, // reduce spacing for mobile
                                  dataRowHeight: 50, // slightly smaller rows
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
                                      controller.filteredPosts
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final index = entry.key + 1;
                                            final post = entry.value;

                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    index.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                          maxWidth: 200,
                                                        ),
                                                    child: Text(
                                                      formatNotesByWords(
                                                        post.content ?? '',
                                                        4,
                                                      ),
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        height: 1.4,
                                                      ),
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
                                                        tooltip: 'திருத்து',
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
                                                        tooltip: 'நீக்கு',
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
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Bulk Upload Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.upload_file,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "குறிப்புகள் சேர்க்க",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: controller.showBulkUploadDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
