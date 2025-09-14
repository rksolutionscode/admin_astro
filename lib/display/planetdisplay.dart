// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:testadm/sidebar/sidebar.dart';

// class Planetdisplay extends StatefulWidget {
//   @override
//   _planetdisplayState createState() => _planetdisplayState();
// }

// class _planetdisplayState extends State<Planetdisplay> {
//   String? _selectedStar;
//   final List<String> _starList = [
//     'சூரியன்', 'சந்திரன்', 'சிறகு', 'புகிரி', 'சட்டுரன்', 'புரவகாடு', 'ராஹு', 'கேது', 'கபிலா'
//   ];

//   Stream<QuerySnapshot> _getStarStream() {
//     return FirebaseFirestore.instance
//         .collection('planet')
//         .orderBy('timestamp', descending: true)
//         .snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       drawer: screenWidth < 800 ? Sidebar() : null,
//       body: screenWidth < 800
//           ? _buildContent()
//           : Row(
//               children: [
//                 Container(
//                   width: screenWidth * 0.25,
//                   child: Sidebar(),
//                 ),
//                 Container(
//                   width: screenWidth * 0.75,
//                   child: _buildContent(),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildContent() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           _buildFilterDropdown(),
//           const SizedBox(height: 16),
//           Expanded(child: _buildTable()),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterDropdown() {
//     return Container(
//       width: 250,
//       padding: EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedStar,
//           hint: Text("பிரபஞ்சத்தை வடிகட்டுங்கள்"),
//           isExpanded: true,
//           onChanged: (value) {
            
//               _selectedStar = value;
          
//           },
//           items: [
//             DropdownMenuItem(value: null, child: Text("எல்லா கிரகம்")),
//             ..._starList.map((star) => DropdownMenuItem(
//                   value: star,
//                   child: Text(star),
//                 ))
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTable() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _getStarStream(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) return Center(child: Text('பிழை: ${snapshot.error}'));
//         if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

//         final docs = snapshot.data!.docs;
//         final filteredDocs = _selectedStar == null
//             ? docs
//             : docs.where((doc) =>
//                 (doc.data() as Map<String, dynamic>)['planet'] == _selectedStar).toList();

//         if (filteredDocs.isEmpty) {
//           return Center(child: Text("தேர்ந்தெடுக்கப்பட்ட கிரகத்திற்கு ஏதுமான குறிப்புகள் இல்லை."));
//         }

//         return SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Table(
//             columnWidths: const {
//               0: IntrinsicColumnWidth(),
//               1: FlexColumnWidth(),
//               2: IntrinsicColumnWidth(),
//             },
//             border: TableBorder.all(color: Colors.black26),
//             children: [
//               TableRow(
//                 decoration: BoxDecoration(color: Colors.deepPurple[100]),
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(8),
//                     child: Text("எண்", style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(8),
//                     child: Text("கரகம்", style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(8),
//                     child: Text("செயல்கள்", style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                 ],
//               ),
//               ...filteredDocs.asMap().entries.map((entry) {
//                 final index = entry.key + 1;
//                 final doc = entry.value;
//                 final data = doc.data() as Map<String, dynamic>;
//                 final notes = data['notes'] ?? '';

//                 return TableRow(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Text(index.toString()),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Text(
//                         notes,
//                         softWrap: true,
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.edit, color: Colors.blue),
//                             onPressed: () {
//                               _editNoteDialog(doc.id, data['notes']);
//                             },
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete, color: Colors.red),
//                             onPressed: () {
//                               _deleteNote(doc.id);
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _deleteNote(String id) async {
//     await FirebaseFirestore.instance.collection('planet').doc(id).delete();
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('குறிப்புகள் நீக்கப்பட்டுள்ளன')));
//   }

//   void _editNoteDialog(String id, String currentNote) {
//     TextEditingController _controller = TextEditingController(text: currentNote);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("குறிப்பை திருத்தவும்"),
//         content: TextField(
//           controller: _controller,
//           maxLines: 5,
//           decoration: InputDecoration(hintText: "புதிய குறிப்பை உள்ளிடவும்"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("ரத்துசெய்"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final updatedNote = _controller.text.trim();
//               if (updatedNote.isNotEmpty) {
//                 await FirebaseFirestore.instance
//                     .collection('planet')
//                     .doc(id)
//                     .update({'notes': updatedNote});
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context)
//                     .showSnackBar(SnackBar(content: Text('குறிப்பு புதுப்பிக்கப்பட்டது')));
//               }
//             },
//             child: Text("புதுப்பிக்கவும்"),
//           ),
//         ],
//       ),
//     );
//   }
// }
