// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:testadm/sidebar/sidebar.dart';

// class Thantrigam extends StatefulWidget {
//   @override
//   _ThantrigamState createState() => _ThantrigamState();
// }

// class _ThantrigamState extends State<Thantrigam> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final TextEditingController noteController = TextEditingController();

//   // Thantrigam க்கான Controller
//   final TextEditingController thantrigamController = TextEditingController();

//   // Firestore இல் தரவு சேர்
//   Future<void> addDataToFirestore(String note, String collection) async {
//     await FirebaseFirestore.instance.collection('thantrigam').add({
//       'note': note,
//       'timestamp': Timestamp.now(),
//     });
//   }

//   Future<void> showBulkUploadDialog(String collection) async {
//     TextEditingController bulkController = TextEditingController();

//     await showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text("பல குறிப்புகள் சேர்க்கவும்"),
//             content: TextField(
//               controller: bulkController,
//               maxLines: 10,
//               decoration: InputDecoration(
//                 hintText: "ஒரு குறிப்பை ஒவ்வொரு வரிசையிலும் உள்ளிடவும்...",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 child: Text("ரத்து செய்"),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               ElevatedButton(
//                 child: Text("பதிவேற்றவும்"),
//                 onPressed: () async {
//                   final notes = bulkController.text.trim().split('\n');
//                   for (String note in notes) {
//                     final trimmed = note.trim();
//                     if (trimmed.isNotEmpty) {
//                       await addDataToFirestore(trimmed, collection);
//                     }
//                   }

//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("பல குறிப்புகள் சேர்க்கப்பட்டன.")),
//                   );
//                 },
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isLargeScreen = screenWidth >= 800;

//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: isLargeScreen ? null : Sidebar(),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.orange,
//         onPressed: () {
//           // Thantrigam க்கான பல பதிவுகளை சேர்க்கும் உரையாடலை காட்டவும்
//           showBulkUploadDialog("thantrigam");
//         },
//         child: Icon(Icons.library_add),
//         tooltip: 'பல குறிப்புகள் சேர்க்கவும்',
//       ),
//       body: SafeArea(
//         child: Row(
//           children: [
//             if (isLargeScreen)
//               Container(width: screenWidth * 0.15, child: Sidebar()),
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
//                           onPressed:
//                               () => _scaffoldKey.currentState?.openDrawer(),
//                         ),
//                       ),
//                     Row(
//                       mainAxisAlignment:
//                           MainAxisAlignment
//                               .end, // பொத்தானை வலப்பக்கத்தில் சமமாக்க
//                       children: [
//                         Container(
//                           width: 150, // பொத்தானின் அகலம்
//                           height: 50, // பொத்தானின் உயரம்
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color.fromARGB(
//                                 255,
//                                 209,
//                                 134,
//                                 14,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             onPressed: () async {
//                               final note = noteController.text.trim();

//                               if (note.isNotEmpty) {
//                                 try {
//                                   // 'thantrigam' என்ற சேகரிப்பில் குறிப்பை Firestore-க்கு சேர்க்கவும்
//                                   await addDataToFirestore(note, "thantrigam");
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                         'குறிப்பு வெற்றிகரமாக சேர்க்கப்பட்டது!',
//                                       ),
//                                     ),
//                                   );
//                                   noteController.clear();
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text('தோல்வி: ${e.toString()}'),
//                                     ),
//                                   );
//                                 }
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       'தயவு செய்து ஒரு குறிப்பை உள்ளிடவும்',
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                             child: Text(
//                               "சேர்க்கவும்",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: 20),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color:  const Color.fromARGB(255, 229, 188, 127),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: TextField(
//                         controller: noteController,
//                         maxLines: 1,
//                         decoration: InputDecoration(
//                           hintText: "குறிப்பு சேர்க்கவும்",
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 30),
//                     Expanded(
//                       child: StreamBuilder<QuerySnapshot>(
//                         stream:
//                             FirebaseFirestore.instance
//                                 .collection('thantrigam')
//                                 .orderBy('timestamp', descending: true)
//                                 .snapshots(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return Center(child: CircularProgressIndicator());
//                           }

//                           if (!snapshot.hasData) {
//                             return Center(child: Text("தரவுகள் இல்லை."));
//                           }

//                           final allNotes = snapshot.data!.docs;
//                           if (allNotes.isEmpty) {
//                             return Center(child: Text("குறிப்புகள் இல்லை."));
//                           }

//                           return SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: SingleChildScrollView(
//                               scrollDirection: Axis.vertical,
//                               child: Table(
//                                 border: TableBorder.all(color: Colors.black),
//                                 columnWidths: {
//                                   0: FixedColumnWidth(200),
//                                   1: FixedColumnWidth(200),
//                                   2: FixedColumnWidth(200),
//                                 },
//                                 defaultVerticalAlignment:
//                                     TableCellVerticalAlignment.top,
//                                 children: [
//                                   TableRow(
//                                     decoration: BoxDecoration(
//                                       color:  const Color.fromARGB(255, 229, 188, 127),
//                                     ),
//                                     children: [
//                                       Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Text(
//                                           "எ. நா.",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.deepOrange
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Text(
//                                           "குறிப்பு",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.deepOrange
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Text(
//                                           "செயல்கள்",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   ...allNotes.asMap().entries.map((entry) {
//                                     final index = entry.key + 1;
//                                     final doc = entry.value;
//                                     final data =
//                                         doc.data() as Map<String, dynamic>;
//                                     final docId = doc.id;

//                                     return TableRow(
//                                       children: [
//                                         Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Text('$index'),
//                                         ),
//                                         Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Text(
//                                             data['note'] ?? '',
//                                             softWrap: true,
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Row(
//                                             children: [
//                                               IconButton(
//                                                 icon: Icon(
//                                                   Icons.edit,
//                                                   color: Colors.blue,
//                                                 ),
//                                                 onPressed: () {
//                                                   final editController =
//                                                       TextEditingController(
//                                                         text: data['note'],
//                                                       );
//                                                   showDialog(
//                                                     context: context,
//                                                     builder:
//                                                         (
//                                                           context,
//                                                         ) => AlertDialog(
//                                                           title: Text(
//                                                             "குறிப்பு தொகுக்கவும்",
//                                                           ),
//                                                           content: TextField(
//                                                             controller:
//                                                                 editController,
//                                                             maxLines: null,
//                                                           ),
//                                                           actions: [
//                                                             TextButton(
//                                                               child: Text(
//                                                                 "ரத்து செய்",
//                                                               ),
//                                                               onPressed:
//                                                                   () =>
//                                                                       Navigator.pop(
//                                                                         context,
//                                                                       ),
//                                                             ),
//                                                             ElevatedButton(
//                                                               child: Text(
//                                                                 "புதுப்பிக்கவும்",
//                                                               ),
//                                                               onPressed: () async {
//                                                                 final newNote =
//                                                                     editController
//                                                                         .text
//                                                                         .trim();
//                                                                 if (newNote
//                                                                     .isNotEmpty) {
//                                                                   await FirebaseFirestore
//                                                                       .instance
//                                                                       .collection(
//                                                                         'thantrigam',
//                                                                       )
//                                                                       .doc(
//                                                                         docId,
//                                                                       )
//                                                                       .update({
//                                                                         'note':
//                                                                             newNote,
//                                                                       });
//                                                                   Navigator.pop(
//                                                                     context,
//                                                                   );
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ],
//                                                         ),
//                                                   );
//                                                 },
//                                               ),
//                                               IconButton(
//                                                 icon: Icon(
//                                                   Icons.delete,
//                                                   color: Colors.red,
//                                                 ),
//                                                 onPressed: () {
//                                                   showDialog(
//                                                     context: context,
//                                                     builder:
//                                                         (
//                                                           context,
//                                                         ) => AlertDialog(
//                                                           title: Text(
//                                                             "குறிப்பு நீக்கவும்",
//                                                           ),
//                                                           content: Text(
//                                                             "நீங்கள் நிச்சயமாக நீக்க விரும்புகிறீர்களா?",
//                                                           ),
//                                                           actions: [
//                                                             TextButton(
//                                                               child: Text(
//                                                                 "ரத்து செய்",
//                                                               ),
//                                                               onPressed:
//                                                                   () =>
//                                                                       Navigator.pop(
//                                                                         context,
//                                                                       ),
//                                                             ),
//                                                             ElevatedButton(
//                                                               child: Text(
//                                                                 "நீக்கவும்",
//                                                               ),
//                                                               onPressed: () async {
//                                                                 await FirebaseFirestore
//                                                                     .instance
//                                                                     .collection(
//                                                                       'thantrigam',
//                                                                     )
//                                                                     .doc(docId)
//                                                                     .delete();
//                                                                 Navigator.pop(
//                                                                   context,
//                                                                 );
//                                                               },
//                                                             ),
//                                                           ],
//                                                         ),
//                                                   );
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   }).toList(),
//                                 ],
//                               ),
//                             ),
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
