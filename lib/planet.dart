import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testadm/permission_controller.dart';
import 'package:testadm/sidebar/sidebar.dart';

class PlanetScreen extends StatefulWidget {
  @override
  _PlanetScreenState createState() => _PlanetScreenState();
}

class _PlanetScreenState extends State<PlanetScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController noteController = TextEditingController();

  List<String> allPlanets = [
    'சூரியன்',
    'சந்திரன்',
    'செவ்வாய்',
    'புதன்',
    'குரு',
    'சுக்கிரன்',
    'சனி',
    'ராகு',
    'கேது',
  ];

  List<String> planets = [];
  String? selectedPlanet;

  @override
  void initState() {
    super.initState();
    _filterPlanetsByPermission();
  }

  void _filterPlanetsByPermission() {
    final allowed = PermissionController.to.allowedPlanets;
    if (allowed.contains("ALL")) {
      planets = allPlanets;
    } else {
      planets = allPlanets.where((p) => allowed.contains(p)).toList();
    }
    if (planets.isNotEmpty) {
      selectedPlanet = planets.first;
    }
  }

  Future<void> addDataToFirestore(String planetName, String note) async {
    await FirebaseFirestore.instance.collection('planet').add({
      'planet': planetName,
      'notes': note,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> updateNote(String docId, String newNote) async {
    await FirebaseFirestore.instance.collection('planet').doc(docId).update({
      'notes': newNote,
    });
  }

  Future<void> deleteNote(String docId) async {
    await FirebaseFirestore.instance.collection('planet').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;

    if (planets.isEmpty) {
      return Scaffold(
        body: Center(child: Text("உங்களுக்கு பிளானெட் அணுகல் அனுமதி இல்லை.")),
      );
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
                                value: selectedPlanet,
                                onChanged: (value) {
                                  setState(() {
                                    selectedPlanet = value!;
                                  });
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
                            final planet = selectedPlanet ?? '';
                            final note = noteController.text.trim();

                            if (!PermissionController.to.allowedPlanets
                                    .contains("ALL") &&
                                !PermissionController.to.allowedPlanets
                                    .contains(planet)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'இந்த பிளானெட்டுக்கு அனுமதி இல்லை.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (planet.isNotEmpty && note.isNotEmpty) {
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
                                    content: Text('தவறு: ${e.toString()}'),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'தயவுசெய்து பிளானெட்டை தேர்வு செய்து, ஒரு குறிப்பை உள்ளிடவும்',
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
                          hintText: "குறிப்பு சேர்க்கவும்",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('planet')
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData) {
                            return Center(
                              child: Text("தரவுகள் கிடைக்கவில்லை."),
                            );
                          }

                          final allNotes = snapshot.data!.docs;
                          final filteredNotes =
                              selectedPlanet == null
                                  ? []
                                  : allNotes
                                      .where(
                                        (doc) =>
                                            doc['planet'] == selectedPlanet,
                                      )
                                      .toList();

                          if (filteredNotes.isEmpty) {
                            return Center(
                              child: Text(
                                "தேர்ந்த பிளானெட்டுக்கு தரவுகள் கிடைக்கவில்லை.",
                              ),
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
                                      color: Colors.grey[300],
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "வரிசை எண்",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "குறிப்பு",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "செயல்கள்",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...filteredNotes.asMap().entries.map((entry) {
                                    final index = entry.key + 1;
                                    final doc = entry.value;
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final docId = doc.id;

                                    final planetName = data['planet'];

                                    final hasPermission =
                                        PermissionController.to.allowedPlanets
                                            .contains("ALL") ||
                                        PermissionController.to.allowedPlanets
                                            .contains(planetName);

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
                                          child:
                                              hasPermission
                                                  ? Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          color: Colors.blue,
                                                        ),
                                                        onPressed: () {
                                                          final editController =
                                                              TextEditingController(
                                                                text:
                                                                    data['notes'],
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
                                                                    maxLines:
                                                                        null,
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
                                                                        "புதுப்பிக்க",
                                                                      ),
                                                                      onPressed: () async {
                                                                        final newNote =
                                                                            editController.text.trim();
                                                                        if (newNote
                                                                            .isNotEmpty) {
                                                                          await updateNote(
                                                                            docId,
                                                                            newNote,
                                                                          );
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
                                                                    "நீக்கல் உறுதி",
                                                                  ),
                                                                  content: Text(
                                                                    "இந்த குறிப்பை நீக்க விரும்புகிறீர்களா?",
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
                                                                        await deleteNote(
                                                                          docId,
                                                                        );
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
                                                  )
                                                  : Text("அனுமதி இல்லை"),
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
