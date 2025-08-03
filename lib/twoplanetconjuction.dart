import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testadm/sidebar/sidebar.dart';

class Twoplanetconjuction extends StatefulWidget {
  @override
  _twocombinationScreenState createState() => _twocombinationScreenState();
}

class _twocombinationScreenState extends State<Twoplanetconjuction> {
  final List<String> planets = [
    'அனைத்து சேர்க்கைகள்',
   'சூரி+ சந்',
    'சூரி+ செவ்',
    'சூரி+ புத',
    'சூரி+ குரு',
    'சூரி+ சுக்',
    'சூரி+ சனி',
    'சூரி+ ரா',
    'சூரி+ கே',
    'சந் + செவ்',
    'சந் + புத',
    'சந் + குரு',
    'சந் + சுக்',
    'சந் + சனி',
    'சந் + ரா',
    'சந் + கே',
    'செவ் + புத',
    'செவ் + குரு',
    'செவ் + சுக்',
    'செவ் + சனி',
    'செவ் + ரா',
    'செவ் + கே',
    'புத + குரு',
    'புத + சுக்',
    'புத + சனி',
    'புத + ரா',
    'புத + கே',
    'குரு + சுக்',
    'குரு + சனி',
    'குரு + ரா',
    'குரு + கே',
    'சுக் + சனி',
    'சுக் + ரா',
    'சுக் + கே',
    'சனி + ரா',
    'சனி + கே',
  ];

  String? selectedlagnam;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController noteController = TextEditingController();

  Future<void> addDataToFirestore(String planetName, String note) async {
    await FirebaseFirestore.instance.collection('twocombination').add({
      'two': planetName,
      'notes': note,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> updateNote(String docId, String newNote) async {
    await FirebaseFirestore.instance
        .collection('twocombination')
        .doc(docId)
        .update({'notes': newNote});
  }

  Future<void> deleteNote(String docId) async {
    await FirebaseFirestore.instance
        .collection('twocombination')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;

    // Firestore stream depending on selectedlagnam
    Stream<QuerySnapshot> notesStream;
    if (selectedlagnam == null || selectedlagnam == 'அனைத்து சேர்க்கைகள்') {
      notesStream =
          FirebaseFirestore.instance
              .collection('twocombination')
              .orderBy('timestamp', descending: true)
              .snapshots();
    } else {
      notesStream =
          FirebaseFirestore.instance
              .collection('twocombination')
              .where('two', isEqualTo: selectedlagnam)
              .orderBy('timestamp', descending: true)
              .snapshots();
    }

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
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                               color: const Color.fromARGB(255, 229, 188, 127),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedlagnam,
                                hint: Text(
                                  "ஒரு சேர்க்கையைத் தேர்ந்தெடுக்கவும்",
                                ),
                                onChanged: (value) {
                                   selectedlagnam = value;
                                },
                                items:
                                    planets.map((planet) {
                                      return DropdownMenuItem(
                                        child: Text(planet),
                                        value: planet,
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 209, 134, 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final planet = selectedlagnam ?? '';
                            final note = noteController.text.trim();

                            if (planet != 'அனைத்து சேர்க்கைகள்' &&
                                note.isNotEmpty) {
                              try {
                                await addDataToFirestore(planet, note);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$planet வெற்றிகரமாக சேர்க்கப்பட்டது!',
                                    ),
                                  ),
                                );
                                noteController.clear();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('தோல்வி: ${e.toString()}'),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'தயவு செய்து ஒரு சேர்க்கையை தேர்ந்தெடுத்து குறிப்பு சேர்க்கவும்',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            "சேர்",
                            style: TextStyle(color: Colors.white),
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
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "குறிப்பை எழுதவும்",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: notesStream,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }

      final documents = snapshot.data!.docs;

      if (documents.isEmpty) {
        return Center(child: Text('தகவல் இல்லை'));
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.orange[100]!),
          columns: const [
            DataColumn(
              label: Text(
                'பார்வை எண்',
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
          rows: documents.asMap().entries.map((entry) {
            int index = entry.key;
            DocumentSnapshot doc = entry.value;
            final notes = doc['notes'] ?? '';
            final docId = doc.id;

            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())), // Displaying 1-based index
                DataCell(
                  Text(notes),
                  showEditIcon: true,
                  onTap: () {
                    noteController.text = notes;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('குறிப்பைத் திருத்து'),
                          content: TextField(
                            controller: noteController,
                            maxLines: null,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('ரத்து'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (noteController.text.trim().isNotEmpty) {
                                  await updateNote(docId, noteController.text.trim());
                                  Navigator.pop(context);
                                }
                              },
                              child: Text('சேமி'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          noteController.text = notes;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('குறிப்பைத் திருத்து'),
                                content: TextField(
                                  controller: noteController,
                                  maxLines: null,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('ரத்து'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (noteController.text.trim().isNotEmpty) {
                                        await updateNote(docId, noteController.text.trim());
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text('சேமி'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async => await deleteNote(docId),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    },
  ),
)

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
