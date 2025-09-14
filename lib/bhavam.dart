// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:testadm/sidebar/sidebar.dart';

// class bhavamScreen extends StatefulWidget {
//   @override
//   _bhavamScreenState createState() => _bhavamScreenState();
// }

// class _bhavamScreenState extends State<bhavamScreen> {
//   final List<String> planets = [
//     'அனைத்து பாவமும்',
//     'முதல் பாவம்',
//     'இரண்டாம் பாவம்',
//     'மூன்றாம் பாவம்',
//     'நான்காம் பாவம்',
//     'ஐந்தாம் பாவம்',
//     'ஆறாம் பாவம்',
//     'ஏழாம் பாவம்',
//     'எட்டாம் பாவம்',
//     'ஒன்பதாம் பாவம்',
//     'பத்தாம் பாவம்',
//     'பதினொன்றாம் பாவம்',
//     'பன்னிரண்டாம் பாவம்'
//   ];

//   final ValueNotifier<String?> selectedPlanetNotifier = ValueNotifier<String?>(null);
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final TextEditingController noteController = TextEditingController();

//   Future<void> addDataToFirestore(String planetName, String note) async {
//     await FirebaseFirestore.instance.collection('bhavam').add({
//       'bhavam': planetName,
//       'notes': note,
//       'timestamp': Timestamp.now(),
//     });
//   }

//   Future<void> updateNote(String docId, String newNote) async {
//     await FirebaseFirestore.instance
//         .collection('bhavam')
//         .doc(docId)
//         .update({'notes': newNote});
//   }

//   Future<void> deleteNote(String docId) async {
//     await FirebaseFirestore.instance.collection('bhavam').doc(docId).delete();
//   }

//   @override
//   void dispose() {
//     noteController.dispose();
//     selectedPlanetNotifier.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isLargeScreen = screenWidth >= 800;

//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: isLargeScreen ? null : Sidebar(),
//       body: SafeArea(
//         child: Row(
//           children: [
//             if (isLargeScreen)
//               Container(
//                 width: screenWidth * 0.15,
//                 child: Sidebar(),
//               ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(30.0),
//                 child: Column(
//                   children: [
//                     if (!isLargeScreen)
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: IconButton(
//                           icon: Icon(Icons.menu, color: Colors.orange),
//                           onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//                         ),
//                       ),
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 2,
//                           child: Container(
//                             padding: EdgeInsets.symmetric(horizontal: 16),
//                             decoration: BoxDecoration(
//                               color: const Color.fromARGB(255, 229, 188, 127),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: ValueListenableBuilder<String?>(
//                               valueListenable: selectedPlanetNotifier,
//                               builder: (context, selectedPlanet, _) {
//                                 return DropdownButtonHideUnderline(
//                                   child: DropdownButton<String>(
//                                     value: selectedPlanet,
//                                     hint: Text("பாவத்தைத் தேர்ந்தெடுக்கவும்"),
//                                     onChanged: (value) {
//                                       selectedPlanetNotifier.value = value;
//                                     },
//                                     items: planets.map((planet) {
//                                       return DropdownMenuItem(
//                                         child: Text(planet),
//                                         value: planet,
//                                       );
//                                     }).toList(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color.fromARGB(255, 209, 134, 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           onPressed: () async {
//                             final planet = selectedPlanetNotifier.value ?? '';
//                             final note = noteController.text.trim();

//                             if (planet != 'அனைத்து பாவமும்' && note.isNotEmpty) {
//                               try {
//                                 await addDataToFirestore(planet, note);
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('$planet வெற்றிகரமாக சேர்க்கப்பட்டது!')),
//                                 );
//                                 noteController.clear();
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('தோல்வி: ${e.toString()}')),
//                                 );
//                               }
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('பாவத்தை தேர்ந்தெடுத்து குறிப்பு எழுத்துக்களை உள்ளிடவும்')),
//                               );
//                             }
//                           },
//                           child: Text("சேர்", style: TextStyle(color: Colors.white)),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: TextField(
//                         controller: noteController,
//                         maxLines: null,
//                         decoration: InputDecoration(
//                           hintText: "குறிப்பை உள்ளிடவும்",
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 30),
//                     Expanded(
//                       child: ValueListenableBuilder<String?>(
//                         valueListenable: selectedPlanetNotifier,
//                         builder: (context, selectedPlanet, _) {
//                           return StreamBuilder<QuerySnapshot>(
//                             stream: FirebaseFirestore.instance
//                                 .collection('bhavam')
//                                 .orderBy('timestamp', descending: true)
//                                 .snapshots(),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState == ConnectionState.waiting) {
//                                 return Center(child: CircularProgressIndicator());
//                               }

//                               if (!snapshot.hasData) {
//                                 return Center(child: Text("தரவு இல்லை."));
//                               }

//                               final allNotes = snapshot.data!.docs;
//                               final filteredNotes = (selectedPlanet == null || selectedPlanet == 'அனைத்து பாவமும்')
//                                   ? allNotes
//                                   : allNotes.where((doc) => doc['bhavam'] == selectedPlanet).toList();

//                               if (filteredNotes.isEmpty) {
//                                 return Center(child: Text("தேர்ந்தெடுக்கப்பட்ட பாவத்திற்கு தரவு இல்லை."));
//                               }

//                               return SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: SingleChildScrollView(
//                                   scrollDirection: Axis.vertical,
//                                   child: Table(
//                                     border: TableBorder.all(color: Colors.black),
//                                     columnWidths: {
//                                       0: FixedColumnWidth(200),
//                                       1: FixedColumnWidth(200),
//                                       2: FixedColumnWidth(200),
//                                     },
//                                     defaultVerticalAlignment: TableCellVerticalAlignment.top,
//                                     children: [
//                                       TableRow(
//                                         decoration: BoxDecoration(
//                                           color: const Color.fromARGB(255, 229, 188, 127),
//                                         ),
//                                         children: [
//                                           Padding(
//                                             padding: EdgeInsets.all(8.0),
//                                             child: Text("எண்", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
//                                           ),
//                                           Padding(
//                                             padding: EdgeInsets.all(8.0),
//                                             child: Text("குறிப்பு", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
//                                           ),
//                                           Padding(
//                                             padding: EdgeInsets.all(8.0),
//                                             child: Text("நடவடிக்கைகள்", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
//                                           ),
//                                         ],
//                                       ),
//                                       ...filteredNotes.asMap().entries.map((entry) {
//                                         final index = entry.key + 1;
//                                         final doc = entry.value;
//                                         final data = doc.data() as Map<String, dynamic>;
//                                         final docId = doc.id;

//                                         return TableRow(
//                                           children: [
//                                             Padding(
//                                               padding: EdgeInsets.all(8.0),
//                                               child: Text('$index'),
//                                             ),
//                                             Padding(
//                                               padding: EdgeInsets.all(8.0),
//                                               child: Text(data['notes'] ?? '', softWrap: true),
//                                             ),
//                                             Padding(
//                                               padding: EdgeInsets.all(8.0),
//                                               child: Row(
//                                                 children: [
//                                                   IconButton(
//                                                     icon: Icon(Icons.edit, color: Colors.blue),
//                                                     onPressed: () {
//                                                       final editController = TextEditingController(text: data['notes']);
//                                                       showDialog(
//                                                         context: context,
//                                                         builder: (context) => AlertDialog(
//                                                           title: Text("குறிப்பை திருத்து"),
//                                                           content: TextField(
//                                                             controller: editController,
//                                                             maxLines: null,
//                                                           ),
//                                                           actions: [
//                                                             TextButton(
//                                                               child: Text("ரத்து"),
//                                                               onPressed: () => Navigator.pop(context),
//                                                             ),
//                                                             ElevatedButton(
//                                                               child: Text("புதுப்பிக்கவும்"),
//                                                               onPressed: () async {
//                                                                 final newNote = editController.text.trim();
//                                                                 if (newNote.isNotEmpty) {
//                                                                   await updateNote(docId, newNote);
//                                                                   Navigator.pop(context);
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                   IconButton(
//                                                     icon: Icon(Icons.delete, color: Colors.red),
//                                                     onPressed: () {
//                                                       showDialog(
//                                                         context: context,
//                                                         builder: (context) => AlertDialog(
//                                                           title: Text("குறிப்பை நீக்கு"),
//                                                           content: Text("நீக்க விரும்புகிறீர்களா?"),
//                                                           actions: [
//                                                             TextButton(
//                                                               child: Text("ரத்து"),
//                                                               onPressed: () => Navigator.pop(context),
//                                                             ),
//                                                             ElevatedButton(
//                                                               child: Text("நீக்கு"),
//                                                               onPressed: () async {
//                                                                 await deleteNote(docId);
//                                                                 Navigator.pop(context);
//                                                               },
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         );
//                                       }).toList(),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
