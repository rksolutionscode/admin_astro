// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:testadm/sidebar/sidebar.dart';

// class AddAiScreen extends StatefulWidget {
//   @override
//   _AddAiScreenState createState() => _AddAiScreenState();
// }

// class _AddAiScreenState extends State<AddAiScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   final List<String> aiTypes = [    'பொதுவான ஏ.ஐ',
//     'மத்திய ஏ.ஐ',
//     'மேம்பட்ட ஏ.ஐ'];
//   String selectedAIType = 'எல்லா AI';
//   final TextEditingController noteController = TextEditingController();

//   Future<void> addDataToFirestore(String aiType, String note) async {
//     await FirebaseFirestore.instance.collection('ai').add({
//       'ai': aiType,
//       'note': note,
//       'timestamp': Timestamp.now(),
//     });
//   }

//   Future<void> showBulkUploadDialog() async {
//     TextEditingController bulkController = TextEditingController();

//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("பல்வேறு குறிப்புகள் பதிவேற்றம்"),
//         content: TextField(
//           controller: bulkController,
//           maxLines: 10,
//           decoration: InputDecoration(
//             hintText: "குறிப்புகளை உள்ளிடவும் (ஒன்றன் பின் ஒன்று)...",
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: Text("ரத்து செய்யவும்"),
//             onPressed: () => Navigator.pop(context),
//           ),
//           ElevatedButton(
//             child: Text("பதிவேற்று"),
//             onPressed: () async {
//               final notes = bulkController.text.trim().split('\n');
//               final type = selectedAIType;

//               if (type == 'எல்லா AI') {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("தயவுசெய்து குறிப்பிட்ட AI வகையைத் தேர்வு செய்யவும்.")),
//                 );
//                 return;
//               }

//               for (String note in notes) {
//                 final trimmed = note.trim();
//                 if (trimmed.isNotEmpty) {
//                   await addDataToFirestore(type, trimmed);
//                 }
//               }

//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text("$type என்பதற்கான பல்வேறு குறிப்புகள் பதிவேற்றம் செய்யப்பட்டது.")),
//               );
//             },
//           ),
//         ],
//       ),
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
//         tooltip: 'பல குறிப்புகளைச் சேர்க்கவும்',
//       ),
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
//                               color: const Color.fromARGB(255, 233, 187, 117),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: selectedAIType,
//                                 onChanged: (value) {
//                                  selectedAIType = value!;
//                                 },
//                                 items: aiTypes.map((type) {
//                                   return DropdownMenuItem(
//                                     child: Text(type),
//                                     value: type,
//                                   );
//                                 }).toList(),
//                               ),
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
//                             final type = selectedAIType;
//                             final note = noteController.text.trim();

//                             if (type != 'எல்லா AI' && note.isNotEmpty) {
//                               try {
//                                 await addDataToFirestore(type, note);
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('$type வெற்றிகரமாக சேர்க்கப்பட்டது!')),
//                                 );
//                                 noteController.clear();
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('பிரச்சினை: ${e.toString()}')),
//                                 );
//                               }
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('தயவுசெய்து AI வகையைத் தேர்வு செய்து குறிப்பு ஒன்றை உள்ளிடவும்')),
//                               );
//                             }
//                           },
//                           child: Text("சேர்க்கவும்", style: TextStyle(color: Colors.white)),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                          color: const Color.fromARGB(255, 229, 188, 127),
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
//                         stream: FirebaseFirestore.instance
//                             .collection('ai')
//                             .orderBy('timestamp', descending: true)
//                             .snapshots(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return Center(child: CircularProgressIndicator());
//                           }

//                           if (!snapshot.hasData) {
//                             return Center(child: Text("தரவு கிடைக்கவில்லை."));
//                           }

//                           final allNotes = snapshot.data!.docs;
//                           final filteredNotes = selectedAIType == 'எல்லா AI'
//                               ? allNotes
//                               : allNotes.where((doc) => doc['ai'] == selectedAIType).toList();

//                           if (filteredNotes.isEmpty) {
//                             return Center(child: Text("தேர்வு செய்த AI வகைக்கு எந்த குறிப்புகளும் இல்லை."));
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
//                                 defaultVerticalAlignment: TableCellVerticalAlignment.top,
//                                 children: [
//                                   TableRow(
//                                     decoration: BoxDecoration( color: const Color.fromARGB(255, 229, 188, 127),),
//                                     children: [
//                                       Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Text("எண்", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.deepOrange)),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Text("குறிப்பு", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.deepOrange)),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(8.0),
//                                         child: Text("செயல்முறைகள்", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.deepOrange)),
//                                       ),
//                                     ],
//                                   ),
//                                   ...filteredNotes.asMap().entries.map((entry) {
//                                     final index = entry.key + 1;
//                                     final doc = entry.value;
//                                     final data = doc.data() as Map<String, dynamic>;
//                                     final docId = doc.id;

//                                     return TableRow(
//                                       children: [
//                                         Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Text('$index'),
//                                         ),
//                                         Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Text(data['note'] ?? '', softWrap: true),
//                                         ),
//                                         Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Row(
//                                             children: [
//                                               IconButton(
//                                                 icon: Icon(Icons.edit, color: Colors.blue),
//                                                 onPressed: () {
//                                                   final editController = TextEditingController(text: data['note']);
//                                                   showDialog(
//                                                     context: context,
//                                                     builder: (context) => AlertDialog(
//                                                       title: Text("குறிப்பைத் திருத்தவும்"),
//                                                       content: TextField(
//                                                         controller: editController,
//                                                         maxLines: null,
//                                                       ),
//                                                       actions: [
//                                                         TextButton(
//                                                           child: Text("ரத்து செய்யவும்"),
//                                                           onPressed: () => Navigator.pop(context),
//                                                         ),
//                                                         ElevatedButton(
//                                                           child: Text("புதுப்பிக்கவும்"),
//                                                           onPressed: () async {
//                                                             final newNote = editController.text.trim();
//                                                             if (newNote.isNotEmpty) {
//                                                               await FirebaseFirestore.instance
//                                                                   .collection('ai')
//                                                                   .doc(docId)
//                                                                   .update({'note': newNote});
//                                                               Navigator.pop(context);
//                                                             }
//                                                           },
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                               IconButton(
//                                                 icon: Icon(Icons.delete, color: Colors.red),
//                                                 onPressed: () {
//                                                   showDialog(
//                                                     context: context,
//                                                     builder: (context) => AlertDialog(
//                                                       title: Text("குறிப்பை நீக்கு"),
//                                                       content: Text("நீக்கு என்றால் சரி."),
//                                                       actions: [
//                                                         TextButton(
//                                                           child: Text("ரத்து செய்யவும்"),
//                                                           onPressed: () => Navigator.pop(context),
//                                                         ),
//                                                         ElevatedButton(
//                                                           child: Text("நீக்கு"),
//                                                           onPressed: () async {
//                                                             await FirebaseFirestore.instance
//                                                                 .collection('ai')
//                                                                 .doc(docId)
//                                                                 .delete();
//                                                             Navigator.pop(context);
//                                                           },
//                                                         ),
//                                                       ],
//                                                     ),
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
