import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testadm/display/stardispaly.dart';
import 'package:testadm/sidebar/sidebar.dart';

class StarDisplayScreen extends StatefulWidget {
  @override
  _starScreenState createState() => _starScreenState();
}

class _starScreenState extends State<StarDisplayScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<String> selectedRasiNotifier = ValueNotifier<String>(
    'அனைத்து நட்சத்திரங்கள்',
  );
  final TextEditingController noteController = TextEditingController();

  final List<String> rasis = [
    "அனைத்து நட்சத்திரங்கள்",
    "அசுவினி",
    "பரணி",
    "கார்த்திகை",
    "ரோகிணி",
    "மிருகசீரிடம்",
    "திருவாதிரை",
    "புனர்பூசம்",
    "பூசம்",
    "ஆயில்யம்",
    "மகம்",
    "பூரம்",
    "உத்திரம்",
    "ஹஸ்தம்",
    "சித்திரை",
    "சுவாதி",
    "விசாகம்",
    "அனுஷம்",
    "கேட்டை",
    "மூலம்",
    "பூராடம்",
    "உத்திராடம்",
    "திருவோணம்",
    "அவிட்டம்",
    "சதயம்",
    "பூரட்டாதி",
    "உத்திரட்டாதி",
    "ரேவதி",
  ];

  Future<void> addDataToFirestore(String rasiName, String note) async {
    await FirebaseFirestore.instance.collection('star').add({
      'rasi': rasiName,
      'notes': note,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isLargeScreen ? null : Sidebar(),
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
                    ValueListenableBuilder<String>(
                      valueListenable: selectedRasiNotifier,
                      builder:
                          (context, selectedRasi, _) => Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      229,
                                      188,
                                      127,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedRasi,
                                      onChanged: (value) {
                                        selectedRasiNotifier.value = value!;
                                      },
                                      items:
                                          rasis.map((rasi) {
                                            return DropdownMenuItem<String>(
                                              value: rasi,
                                              child: Text(rasi),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
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
                                  final rasi = selectedRasiNotifier.value;
                                  final note = noteController.text.trim();

                                  if (rasi != 'அனைத்து நட்சத்திரங்கள்' &&
                                      note.isNotEmpty) {
                                    try {
                                      await addDataToFirestore(rasi, note);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '$rasi சேர்க்கப்பட்டது!',
                                          ),
                                        ),
                                      );
                                      noteController.clear();
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'தவறு: ${e.toString()}',
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'தயவுசெய்து ஒரு நட்சத்திரத்தை தேர்ந்தெடுக்கவும் மற்றும் ஒரு குறிப்பை உள்ளிடவும்',
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
                            ],
                          ),
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
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "குறிப்பு சேர்க்கவும்",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: ValueListenableBuilder<String>(
                        valueListenable: selectedRasiNotifier,
                        builder: (context, selectedRasi, _) {
                          return StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('star')
                                    .orderBy('timestamp', descending: true)
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (!snapshot.hasData) {
                                return Center(child: Text("தரவு இல்லை."));
                              }

                              final allNotes = snapshot.data!.docs;
                              final filteredNotes =
                                  selectedRasi == 'அனைத்து நட்சத்திரங்கள்'
                                      ? allNotes
                                      : allNotes.where((doc) {
                                        final data =
                                            doc.data() as Map<String, dynamic>;
                                        return data['rasi'] == selectedRasi;
                                      }).toList();

                              if (filteredNotes.isEmpty) {
                                return Center(
                                  child: Text(
                                    "தேர்ந்தெடுத்த நட்சத்திரத்திற்கு எந்த தரவும் இல்லை.",
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Table(
                                    border: TableBorder.all(
                                      color: Colors.black,
                                    ),
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
                                            239,
                                            191,
                                            119,
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
                                              "குறிப்பு",
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
                                      ...filteredNotes.asMap().entries.map((
                                        entry,
                                      ) {
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
                                                data['notes'] ?? '',
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
                                                            text: data['notes'],
                                                          );
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (
                                                              context,
                                                            ) => AlertDialog(
                                                              title: Text(
                                                                "குறிப்பை திருத்தவும்",
                                                              ),
                                                              content: TextField(
                                                                controller:
                                                                    editController,
                                                                maxLines: null,
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  child: Text(
                                                                    "ரத்து",
                                                                  ),
                                                                  onPressed:
                                                                      () => Navigator.pop(
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
                                                                            'star',
                                                                          )
                                                                          .doc(
                                                                            docId,
                                                                          )
                                                                          .update({
                                                                            'notes':
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
                                                                "குறிப்பை நீக்கவும்",
                                                              ),
                                                              content: Text(
                                                                "நிச்சயமாக நீக்க விரும்புகிறீர்களா?",
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  child: Text(
                                                                    "ரத்து",
                                                                  ),
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                      ),
                                                                ),
                                                                ElevatedButton(
                                                                  child: Text(
                                                                    "நீக்கு",
                                                                  ),
                                                                  onPressed: () async {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                          'star',
                                                                        )
                                                                        .doc(
                                                                          docId,
                                                                        )
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
