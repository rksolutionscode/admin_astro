import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testadm/sidebar/sidebar.dart';

class Pariharam extends StatefulWidget {
  @override
  _PariharamState createState() => _PariharamState();
}

class _PariharamState extends State<Pariharam> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController noteController = TextEditingController();

  // Dropdown மதிப்பு
  String? selectedPariharamType;

  // Dropdownக்கு பயன்படும் பரிகாரம் வகைகளின் பட்டியல்
  final List<String> pariharamTypes = ['ஜோதிடம்', 'வஸ்து', 'கோவில்'];

  Future<void> addDataToFirestore(String note, String pariharamType) async {
    await FirebaseFirestore.instance.collection('pariharam').add({
      'note': note,
      'pariharamType': pariharamType,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> showBulkUploadDialog() async {
    TextEditingController bulkController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("பல பதிவுகளைச் சேர்க்கவும்"),
            content: TextField(
              controller: bulkController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "பதிவுகளை உள்ளிடுக (ஒவ்வொன்றும் ஒரு வரி)...",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                child: Text("நிராகரிக்கவும்"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("பதிவுகளைப் பதிவேற்றவும்"),
                onPressed: () async {
                  final notes = bulkController.text.trim().split('\n');
                  for (String note in notes) {
                    final trimmed = note.trim();
                    if (trimmed.isNotEmpty) {
                      await addDataToFirestore(
                        trimmed,
                        selectedPariharamType ?? "Unknown",
                      );
                    }
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("பல பதிவுகள் சேர்க்கப்பட்டுள்ளன.")),
                  );
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;
    final ValueNotifier<String?> selectedPariharamTypeNotifier = ValueNotifier(
      null,
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: isLargeScreen ? null : Sidebar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: showBulkUploadDialog,
        child: Icon(Icons.library_add),
        tooltip: 'பல பதிவுகளைச் சேர்க்கவும்',
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen)
              Container(width: screenWidth * 0.15, child: Sidebar()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    if (!isLargeScreen)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.menu, color: Colors.orange),
                          onPressed:
                              () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                      ),
                    Row(
                      children: [
                        SizedBox(
                          width: 150, // Set desired width
                          height: 50, // Set desired height
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
                              final note = noteController.text.trim();
                              final pariharamType =
                                  selectedPariharamType ?? "Unknown";

                              if (note.isNotEmpty) {
                                try {
                                  await addDataToFirestore(note, pariharamType);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'பதிவு வெற்றிகரமாக சேர்க்கப்பட்டது!',
                                      ),
                                    ),
                                  );
                                  noteController.clear();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('பிழை: ${e.toString()}'),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'தயவுசெய்து ஒரு பதிவு உள்ளிடுக',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "சேர்க்கவும்",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 229, 188, 127),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: noteController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "பதிவு சேர்க்கவும்",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // பரிகாரம் வகை dropdown
                    ValueListenableBuilder<String?>(
                      valueListenable: selectedPariharamTypeNotifier,
                      builder: (context, selectedPariharamType, _) {
                        return DropdownButton<String>(
                          value: selectedPariharamType,
                          hint: Text("பரிகாரம் வகையை தேர்வு செய்க"),
                          items:
                              pariharamTypes.map((String pariharam) {
                                return DropdownMenuItem<String>(
                                  value: pariharam,
                                  child: Text(pariharam),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            selectedPariharamTypeNotifier.value = newValue;
                          },
                        );
                      },
                    ),

                    SizedBox(height: 30),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('pariharam')
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData) {
                            return Center(child: Text("தரவு கிடைக்கவில்லை."));
                          }

                          final allNotes = snapshot.data!.docs;
                          if (allNotes.isEmpty) {
                            return Center(
                              child: Text("பதிவுகள் கிடைக்கவில்லை."),
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Table(
                                border: TableBorder.all(color: Colors.black),
                                columnWidths: {
                                  0: FixedColumnWidth(200),
                                  1: FixedColumnWidth(200),
                                  2: FixedColumnWidth(200),
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.top,
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        229,
                                        188,
                                        127,
                                      ),
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "எண்",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "பதிவு",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "செயல்பாடுகள்",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...allNotes.asMap().entries.map((entry) {
                                    final index = entry.key + 1;
                                    final doc = entry.value;
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final docId = doc.id;

                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('$index'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            data['note'] ?? '',
                                            softWrap: true,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  final editController =
                                                      TextEditingController(
                                                        text: data['note'],
                                                      );
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => AlertDialog(
                                                          title: Text(
                                                            "பதிவை திருத்தவும்",
                                                          ),
                                                          content: TextField(
                                                            controller:
                                                                editController,
                                                            maxLines: null,
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              child: Text(
                                                                "ரத்து செய்க",
                                                              ),
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                      ),
                                                            ),
                                                            ElevatedButton(
                                                              child: Text(
                                                                "புதுப்பிக்கவும்",
                                                              ),
                                                              onPressed: () async {
                                                                final newNote =
                                                                    editController
                                                                        .text
                                                                        .trim();
                                                                if (newNote
                                                                    .isNotEmpty) {
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                        'pariharam',
                                                                      )
                                                                      .doc(
                                                                        docId,
                                                                      )
                                                                      .update({
                                                                        'note':
                                                                            newNote,
                                                                      });
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => AlertDialog(
                                                          title: Text(
                                                            "பதிவை அழிக்கவும்",
                                                          ),
                                                          content: Text(
                                                            "நிச்சயமாக அழிக்க விரும்புகிறீர்களா?",
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              child: Text(
                                                                "ரத்து செய்க",
                                                              ),
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                      ),
                                                            ),
                                                            ElevatedButton(
                                                              child: Text(
                                                                "அழிக்கவும்",
                                                              ),
                                                              onPressed: () async {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                      'pariharam',
                                                                    )
                                                                    .doc(docId)
                                                                    .delete();
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                            ),
                                                          ],
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
                                ],
                              ),
                            ),
                          );
                        },
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
