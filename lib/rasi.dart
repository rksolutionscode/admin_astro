import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:testadm/sidebar/sidebar.dart';
import 'package:testadm/permission_controller.dart';

class AddRasiScreen extends StatefulWidget {
  @override
  _AddRasiScreenState createState() => _AddRasiScreenState();
}

class _AddRasiScreenState extends State<AddRasiScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  List<String> rasis = [];

  final ValueNotifier<String> selectedRasi = ValueNotifier<String>(
    'எல்லா ராசிகள்',
  );
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filterRasisByPermission();
  }

  void _filterRasisByPermission() {
    final allowedRasis = PermissionController.to.allowedRasis;
    setState(() {
      if (allowedRasis.contains("ALL")) {
        rasis = allRasis;
      } else {
        rasis =
            ['எல்லா ராசிகள்'] +
            allRasis.where((rasi) => allowedRasis.contains(rasi)).toList();
      }
    });
  }

  Future<void> addDataToFirestore(String rasiName, String note) async {
    if (!PermissionController.to.allowedRasis.contains("ALL") &&
        !PermissionController.to.allowedRasis.contains(rasiName)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("இந்த ராசிக்கு அனுமதி இல்லை.")));
      return;
    }
    await FirebaseFirestore.instance.collection('service_notes').add({
      'rasi': rasiName,
      'notes': note,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> showBulkUploadDialog() async {
    TextEditingController bulkController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("பல பதிவு குறிப்புகள் சேர்க்க"),
            content: TextField(
              controller: bulkController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "ஒரு வரியில் குறிப்புகளை சேர்க்கவும்...",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                child: Text("ரத்து செய்யவும்"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("பதிவேற்றவும்"),
                onPressed: () async {
                  final notes = bulkController.text.trim().split('\n');
                  final rasi = selectedRasi.value;

                  if (rasi == 'எல்லா ராசிகள்') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "குறிப்புகள் சேர்க்கும் முன் ஒரு குறிப்பிட்ட ராசி தேர்வு செய்யவும்.",
                        ),
                      ),
                    );
                    return;
                  }

                  if (!PermissionController.to.allowedRasis.contains("ALL") &&
                      !PermissionController.to.allowedRasis.contains(rasi)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("இந்த ராசிக்கு அனுமதி இல்லை.")),
                    );
                    return;
                  }

                  for (String note in notes) {
                    final trimmed = note.trim();
                    if (trimmed.isNotEmpty) {
                      await addDataToFirestore(rasi, trimmed);
                    }
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "$rasi க்கான பல குறிப்புகள் சேர்க்கப்பட்டன.",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }

  Future<void> uploadCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final rawData = await file.readAsString();
      List<List<dynamic>> csvData = CsvToListConverter().convert(rawData);

      for (var row in csvData) {
        if (row.length >= 2) {
          final rasi = row[0].toString().trim();
          final note = row[1].toString().trim();

          if (rasi.isNotEmpty && note.isNotEmpty) {
            await addDataToFirestore(rasi, note);
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV கோப்பு வெற்றிகரமாக பதிவேற்றப்பட்டது.")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("CSV கோப்பு தேர்வு செய்யவில்லை.")));
    }
  }

  @override
  void dispose() {
    selectedRasi.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isLargeScreen ? null : Sidebar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: uploadCsvFile,
        child: Icon(Icons.upload_file),
        tooltip: 'CSV கோப்பு பதிவேற்றவும்',
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen)
              Container(width: screenWidth * 0.17, child: Sidebar()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isLargeScreen)
                      IconButton(
                        icon: Icon(Icons.menu, color: Colors.orange),
                        onPressed:
                            () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 229, 188, 127),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: ValueListenableBuilder<String>(
                                valueListenable: selectedRasi,
                                builder: (context, value, child) {
                                  return DropdownButton<String>(
                                    isExpanded: true,
                                    value: value,
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        selectedRasi.value = newValue;
                                      }
                                    },
                                    items:
                                        rasis.map((rasi) {
                                          return DropdownMenuItem(
                                            child: Text(rasi),
                                            value: rasi,
                                          );
                                        }).toList(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                255,
                                209,
                                134,
                                14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final rasi = selectedRasi.value;
                              final note = noteController.text.trim();

                              if (rasi != 'எல்லா ராசிகள்' && note.isNotEmpty) {
                                try {
                                  await addDataToFirestore(rasi, note);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$rasi வெற்றிகரமாக சேர்க்கப்பட்டது!',
                                      ),
                                    ),
                                  );
                                  noteController.clear();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('சிக்கல்: ${e.toString()}'),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'தயவுசெய்து ராசி தேர்வு செய்து ஒரு குறிப்பை உள்ளிடவும்',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "சேர்க்கவும்",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: noteController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "குறிப்பு சேர்க்க",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _buildNotesTable(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: showBulkUploadDialog,
                        child: Text(
                          "பல குறிப்புகள் சேர்க்க",
                          style: TextStyle(color: Colors.white),
                        ),
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

  Widget _buildNotesTable() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('service_notes')
              .orderBy('timestamp', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("தரவுகள் கிடைக்கவில்லை."));
        }

        final allNotes = snapshot.data!.docs;
        final filteredNotes =
            selectedRasi.value == 'எல்லா ராசிகள்'
                ? allNotes
                : allNotes
                    .where((doc) => doc['rasi'] == selectedRasi.value)
                    .toList();

        if (filteredNotes.isEmpty) {
          return const Center(
            child: Text(
              "தேர்வு செய்யப்பட்ட ராசிக்கு தொடர்புடைய தரவுகள் கிடைக்கவில்லை.",
            ),
          );
        }

        return Center(
          // ✅ Center horizontally
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 600,
                maxWidth: 1000, // ✅ Optional: limits max width on large screens
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color(0xFFE5BC7F),
                ),
                columnSpacing: 24,
                dataRowMinHeight: 60,
                dataRowMaxHeight: double.infinity,
                columns: const [
                  DataColumn(
                    label: Text(
                      'பி.நி',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'குறிப்பு',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'செயல்கள்',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows:
                    filteredNotes.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final doc = entry.value;
                      final data = doc.data() as Map<String, dynamic>;
                      final docId = doc.id;
                      final rawNote = data['notes']?.toString() ?? '';
                      final formattedNote = _formatNotesByWords(rawNote, 4);

                      return DataRow(
                        cells: [
                          DataCell(Text(index.toString())),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Text(
                                formattedNote,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
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
                                  ),
                                  tooltip: 'திருத்து',
                                  onPressed:
                                      () => _showEditDialog(docId, rawNote),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'நீக்கு',
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('service_notes')
                                        .doc(docId)
                                        .delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("குறிப்பு நீக்கப்பட்டது"),
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
          ),
        );
      },
    );
  }

  void _showEditDialog(String docId, String currentNote) {
    final TextEditingController editController = TextEditingController(
      text: currentNote,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'குறிப்பு திருத்து',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: editController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'புதிய குறிப்பு',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('ரத்து'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('சேமி'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('service_notes')
                    .doc(docId)
                    .update({'notes': editController.text});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("குறிப்பு திருத்தப்பட்டது")),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

String _formatNotesByWords(String text, int wordsPerLine) {
  final words = text.split(RegExp(r'\s+'));
  final buffer = StringBuffer();

  for (int i = 0; i < words.length; i++) {
    buffer.write(words[i]);
    if ((i + 1) % wordsPerLine == 0) {
      buffer.write('\n');
    } else {
      buffer.write(' ');
    }
  }

  return buffer.toString().trim();
}
