// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:testadm/sidebar/sidebar.dart';

// class Advertisement extends StatefulWidget {
//   @override
//   _advertisementState createState() => _advertisementState();
// }

// class _advertisementState extends State<Advertisement> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final TextEditingController noteController = TextEditingController();

//   Future<void> addDataToFirestore(String note) async {
//     await FirebaseFirestore.instance.collection('advertisement').add({
//       'note': note,
//       'timestamp': Timestamp.now(),
//     });
//   }

//   Future<void> showBulkUploadDialog() async {
//     TextEditingController bulkController = TextEditingController();

//     await showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text("புல்க் நொட்டுகளை சேர்க்கவும்"),
//             content: TextField(
//               controller: bulkController,
//               maxLines: 10,
//               decoration: InputDecoration(
//                 hintText: "ஒரு கோடியில் ஒரு நொட்டை சேர்க்கவும்...",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 child: Text("ரத்து செய்யவும்"),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               ElevatedButton(
//                 child: Text("பதிவு செய்யவும்"),
//                 onPressed: () async {
//                   final notes = bulkController.text.trim().split('\n');
//                   for (String note in notes) {
//                     final trimmed = note.trim();
//                     if (trimmed.isNotEmpty) {
//                       await addDataToFirestore(trimmed);
//                     }
//                   }

//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("புல்க் நொட்டுகள் சேர்க்கப்பட்டன.")),
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
//         onPressed: showBulkUploadDialog,
//         child: Icon(Icons.library_add),
//         tooltip: 'புல்க் நொட்டுகளை சேர்க்கவும்',
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
//                       children: [
//                         SizedBox(
//                           width: 150, // Set desired width
//                           height: 50, // Set desired height
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
//                                   await addDataToFirestore(note);
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                         'பதிவு வெற்றிகரமாக சேர்க்கப்பட்டது!',
//                                       ),
//                                     ),
//                                   );
//                                   noteController.clear();
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text('பிழை: ${e.toString()}'),
//                                     ),
//                                   );
//                                 }
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       'தயவுசெய்து ஒரு பதிவு உள்ளிடுக',
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
//                         color: const Color.fromARGB(255, 229, 188, 127),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: TextField(
//                         controller: noteController,
//                         maxLines: 1,
//                         decoration: InputDecoration(
//                           hintText: "நொட்டை சேர்க்கவும்",
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 30),
//                     Expanded(
//                       child: StreamBuilder<QuerySnapshot>(
//                         stream:
//                             FirebaseFirestore.instance
//                                 .collection('advertisement')
//                                 .orderBy('timestamp', descending: true)
//                                 .snapshots(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return Center(child: CircularProgressIndicator());
//                           }

//                           if (!snapshot.hasData) {
//                             return Center(child: Text("தரவு கிடைக்கவில்லை."));
//                           }

//                           final allNotes = snapshot.data!.docs;
//                           if (allNotes.isEmpty) {
//                             return Center(
//                               child: Text("நொட்டுகள் கிடைக்கவில்லை."),
//                             );
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
//                                       color: const Color.fromARGB(255, 229, 188, 127),
//                                     ),
//                                     children: [
//                                       Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Text(
//                                           "எண்",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.deepOrange
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Text(
//                                           "நொட்டை",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.deepOrange
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Text(
//                                           "செயல்பாடுகள்",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.deepOrange
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
//                                                             "நொட்டை திருத்தவும்",
//                                                           ),
//                                                           content: TextField(
//                                                             controller:
//                                                                 editController,
//                                                             maxLines: null,
//                                                           ),
//                                                           actions: [
//                                                             TextButton(
//                                                               child: Text(
//                                                                 "ரத்து செய்யவும்",
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
//                                                                         'advertisement',
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
//                                                             "நொட்டை நீக்கவும்",
//                                                           ),
//                                                           content: Text(
//                                                             "நீங்கள் உறுதியாக உள்ளீர்களா?",
//                                                           ),
//                                                           actions: [
//                                                             TextButton(
//                                                               child: Text(
//                                                                 "ரத்து செய்யவும்",
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
//                                                                       'advertisement',
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
