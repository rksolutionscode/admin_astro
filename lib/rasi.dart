// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:csv/csv.dart';
// import 'package:http/http.dart' as http;
// import 'package:testadm/sidebar/sidebar.dart';
// import 'package:testadm/permission_controller.dart';

// class AddRaasiScreen extends StatefulWidget {
//   final String bearerToken; // You must pass the auth token here
//   AddRaasiScreen({required this.bearerToken});
//   @override
//   _AddRasiScreenState createState() => _AddRasiScreenState();
// }
// class _AddRasiScreenState extends State<AddRaasiScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   final List<String> allRasis = [
//     'எல்லா ராசிகள்',
//     'மேஷம்',
//     'ரிஷபம்',
//     'மிதுனம்',
//     'கடகம்',
//     'சிம்மம்',
//     'கன்னி',
//     'துலாம்',
//     'விருச்சிகம்',
//     'தனுசு',
//     'மகரம்',
//     'கும்பம்',
//     'மீனம்',
//   ];

//   List<String> rasis = [];

//   final ValueNotifier<String> selectedRasi = ValueNotifier<String>(
//     'எல்லா ராசிகள்',
//   );
//   final TextEditingController noteController = TextEditingController();

//   // List of Raasi posts fetched from API
//   List<dynamic> raasiPosts = [];

//   @override
//   void initState() {
//     super.initState();
//     _filterRasisByPermission();
//     fetchRaasiPosts();
//   }

//   void _filterRasisByPermission() {
//     final allowedRasis = PermissionController.to.allowedRasis;
//     print("Allowed rasis from PermissionController: $allowedRasis");

//     setState(() {
//       if (allowedRasis.contains("ALL")) {
//         rasis = allRasis;
//       } else {
//         rasis =
//             ['எல்லா ராசிகள்'] +
//             allRasis.where((rasi) => allowedRasis.contains(rasi)).toList();
//       }
//     });

//     print("Filtered rasis list: $rasis");
//   }

//   Future<void> fetchRaasiPosts() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://astro-j7b4.onrender.com/api/admins/raasi'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer ${widget.bearerToken}',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           raasiPosts = json.decode(response.body);
//         });
//       } else {
//         _showSnackBar("தரவுகளைப் பெற முடியவில்லை: ${response.statusCode}");
//       }
//     } catch (e) {
//       _showSnackBar("பிழை: $e");
//     }
//   }

//   Future<void> addRaasiPost(String rasiName, String content) async {
//     if (!PermissionController.to.allowedRasis.contains("ALL") &&
//         !PermissionController.to.allowedRasis.contains(rasiName)) {
//       _showSnackBar("இந்த ராசிக்கு அனுமதி இல்லை.");
//       return;
//     }

//     // Map rasiName to raasiId
//     int? raasiId = _rasiNameToId(rasiName);
//     if (raasiId == null) {
//       _showSnackBar("தவறான ராசி தேர்வு");
//       return;
//     }

//     final body = json.encode({
//       "raasiId": raasiId,
//       "content": content,
//       "adminId": await _getAdminId(), // You can implement adminId retrieval
//       "type": "Negative", // or dynamic based on your app
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('http://astro-j7b4.onrender.com/api/admins/raasi'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer ${widget.bearerToken}',
//           'Content-Type': 'application/json',
//         },
//         body: body,
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         _showSnackBar("$rasiName வெற்றிகரமாக சேர்க்கப்பட்டது!");
//         noteController.clear();
//         await fetchRaasiPosts();
//       } else {
//         _showSnackBar(
//           "பதிவு தோல்வி: ${response.statusCode} - ${response.body}",
//         );
//       }
//     } catch (e) {
//       _showSnackBar("பிழை: $e");
//     }
//   }

//   Future<int> _getAdminId() async {
//     // TODO: Implement logic to retrieve adminId from your auth/session system.
//     // For now, return a dummy fixed id or pass it as parameter.
//     return 29; // Example adminId
//   }

//   int? _rasiNameToId(String rasiName) {
//     // Map Tamil rasi names to IDs (replace with your actual IDs)
//     final map = {
//       'மேஷம்': 1,
//       'ரிஷபம்': 2,
//       'மிதுனம்': 3,
//       'கடகம்': 4,
//       'சிம்மம்': 5,
//       'கன்னி': 6,
//       'துலாம்': 7,
//       'விருச்சிகம்': 8,
//       'தனுசு': 9,
//       'மகரம்': 10,
//       'கும்பம்': 11,
//       'மீனம்': 12,
//     };
//     return map[rasiName];
//   }

//   Future<void> showBulkUploadDialog() async {
//     TextEditingController bulkController = TextEditingController();

//     await showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text("பல பதிவு குறிப்புகள் சேர்க்க"),
//             content: TextField(
//               controller: bulkController,
//               maxLines: 10,
//               decoration: InputDecoration(
//                 hintText: "ஒரு வரியில் குறிப்புகளை சேர்க்கவும்...",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 child: Text("ரத்து செய்யவும்"),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               ElevatedButton(
//                 child: Text("பதிவேற்றவும்"),
//                 onPressed: () async {
//                   final notes = bulkController.text.trim().split('\n');
//                   final rasi = selectedRasi.value;

//                   if (rasi == 'எல்லா ராசிகள்') {
//                     _showSnackBar(
//                       "குறிப்புகள் சேர்க்கும் முன் ஒரு குறிப்பிட்ட ராசி தேர்வு செய்யவும்.",
//                     );
//                     return;
//                   }

//                   if (!PermissionController.to.allowedRasis.contains("ALL") &&
//                       !PermissionController.to.allowedRasis.contains(rasi)) {
//                     _showSnackBar("இந்த ராசிக்கு அனுமதி இல்லை.");
//                     return;
//                   }

//                   for (String note in notes) {
//                     final trimmed = note.trim();
//                     if (trimmed.isNotEmpty) {
//                       await addRaasiPost(rasi, trimmed);
//                     }
//                   }

//                   Navigator.pop(context);
//                   _showSnackBar("$rasi க்கான பல குறிப்புகள் சேர்க்கப்பட்டன.");
//                   await fetchRaasiPosts();
//                 },
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> uploadCsvFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['csv'],
//     );

//     if (result != null) {
//       final file = File(result.files.single.path!);
//       final rawData = await file.readAsString();
//       List<List<dynamic>> csvData = CsvToListConverter().convert(rawData);

//       for (var row in csvData) {
//         if (row.length >= 2) {
//           final rasi = row[0].toString().trim();
//           final note = row[1].toString().trim();

//           if (rasi.isNotEmpty && note.isNotEmpty) {
//             await addRaasiPost(rasi, note);
//           }
//         }
//       }

//       _showSnackBar("CSV கோப்பு வெற்றிகரமாக பதிவேற்றப்பட்டது.");
//       await fetchRaasiPosts();
//     } else {
//       _showSnackBar("CSV கோப்பு தேர்வு செய்யவில்லை.");
//     }
//   }

//   Future<void> deleteRaasiPost(int postId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('http://astro-j7b4.onrender.com/api/admins/raasi/$postId'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer ${widget.bearerToken}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         _showSnackBar("குறிப்பு நீக்கப்பட்டது");
//         await fetchRaasiPosts();
//       } else {
//         _showSnackBar("நீக்கு தோல்வி: ${response.statusCode}");
//       }
//     } catch (e) {
//       _showSnackBar("பிழை: $e");
//     }
//   }

//   Future<void> updateRaasiPost(int postId, String content, int raasiId) async {
//     try {
//       final response = await http.put(
//         Uri.parse('http://astro-j7b4.onrender.com/api/admins/raasi/$postId'),
//         headers: {
//           HttpHeaders.authorizationHeader: 'Bearer ${widget.bearerToken}',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({'content': content, 'raasiId': raasiId}),
//       );

//       if (response.statusCode == 200) {
//         _showSnackBar("குறிப்பு திருத்தப்பட்டது");
//         await fetchRaasiPosts();
//       } else {
//         _showSnackBar("திருத்தம் தோல்வி: ${response.statusCode}");
//       }
//     } catch (e) {
//       _showSnackBar("பிழை: $e");
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   void _showEditDialog(int postId, String currentContent, int raasiId) {
//     final TextEditingController editController = TextEditingController(
//       text: currentContent,
//     );
//     String selectedRasiForEdit = _rasiIdToName(raasiId) ?? 'மேஷம்';

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Text(
//             'குறிப்பு திருத்து',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButton<String>(
//                 isExpanded: true,
//                 value: selectedRasiForEdit,
//                 items:
//                     allRasis
//                         .where((rasi) => rasi != 'எல்லா ராசிகள்')
//                         .map(
//                           (rasi) =>
//                               DropdownMenuItem(value: rasi, child: Text(rasi)),
//                         )
//                         .toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       selectedRasiForEdit = value;
//                     });
//                   }
//                 },
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: editController,
//                 maxLines: 5,
//                 decoration: InputDecoration(
//                   labelText: 'புதிய குறிப்பு',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: Text('ரத்து'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//               child: Text('சேமி'),
//               onPressed: () async {
//                 int? newRaasiId = _rasiNameToId(selectedRasiForEdit);
//                 if (newRaasiId == null) {
//                   _showSnackBar("தவறான ராசி தேர்வு");
//                   return;
//                 }
//                 await updateRaasiPost(postId, editController.text, newRaasiId);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   String? _rasiIdToName(int id) {
//     final map = {
//       1: 'மேஷம்',
//       2: 'ரிஷபம்',
//       3: 'மிதுனம்',
//       4: 'கடகம்',
//       5: 'சிம்மம்',
//       6: 'கன்னி',
//       7: 'துலாம்',
//       8: 'விருச்சிகம்',
//       9: 'தனுசு',
//       10: 'மகரம்',
//       11: 'கும்பம்',
//       12: 'மீனம்',
//     };
//     return map[id];
//   }

//   @override
//   void dispose() {
//     selectedRasi.dispose();
//     noteController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isLargeScreen = screenWidth >= 600;

//     // Filter displayed posts by selected rasi
//     List<dynamic> filteredPosts =
//         selectedRasi.value == 'எல்லா ராசிகள்'
//             ? raasiPosts
//             : raasiPosts.where((post) {
//               return post['raasiId'] == _rasiNameToId(selectedRasi.value);
//             }).toList();

//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: isLargeScreen ? null : Sidebar(),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.orange,
//         onPressed: uploadCsvFile,
//         child: Icon(Icons.upload_file),
//         tooltip: 'CSV கோப்பு பதிவேற்றவும்',
//       ),
//       body: SafeArea(
//         child: Row(
//           children: [
//             if (isLargeScreen)
//               Container(width: screenWidth * 0.17, child: Sidebar()),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (!isLargeScreen)
//                       IconButton(
//                         icon: Icon(Icons.menu, color: Colors.orange),
//                         onPressed:
//                             () => _scaffoldKey.currentState?.openDrawer(),
//                       ),
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 3,
//                           child: Container(
//                             padding: EdgeInsets.symmetric(horizontal: 16),
//                             decoration: BoxDecoration(
//                               color: Color.fromARGB(255, 229, 188, 127),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: ValueListenableBuilder<String>(
//                                 valueListenable: selectedRasi,
//                                 builder: (context, value, child) {
//                                   return DropdownButton<String>(
//                                     isExpanded: true,
//                                     value: value,
//                                     onChanged: (newValue) {
//                                       if (newValue != null) {
//                                         selectedRasi.value = newValue;
//                                         setState(
//                                           () {},
//                                         ); // Refresh UI for filtered posts
//                                       }
//                                     },
//                                     items:
//                                         rasis
//                                             .map(
//                                               (rasi) => DropdownMenuItem(
//                                                 child: Text(rasi),
//                                                 value: rasi,
//                                               ),
//                                             )
//                                             .toList(),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                           flex: 2,
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
//                               final rasi = selectedRasi.value;
//                               final note = noteController.text.trim();

//                               if (rasi != 'எல்லா ராசிகள்' && note.isNotEmpty) {
//                                 await addRaasiPost(rasi, note);
//                               } else {
//                                 _showSnackBar(
//                                   'தயவுசெய்து ராசி தேர்வு செய்து ஒரு குறிப்பை உள்ளிடவும்',
//                                 );
//                               }
//                             },
//                             child: Text(
//                               "சேர்க்கவும்",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
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
//                         maxLines: 1,
//                         decoration: InputDecoration(
//                           hintText: "குறிப்பு சேர்க்க",
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 30),
//                     Expanded(
//                       child: Container(
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 6,
//                               offset: Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child:
//                             filteredPosts.isEmpty
//                                 ? Center(
//                                   child: Text(
//                                     "தேர்வு செய்யப்பட்ட ராசிக்கு தொடர்புடைய தரவுகள் கிடைக்கவில்லை.",
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                 )
//                                 : SingleChildScrollView(
//                                   scrollDirection: Axis.horizontal,
//                                   child: ConstrainedBox(
//                                     constraints: BoxConstraints(
//                                       minWidth: 600,
//                                       maxWidth: 1000,
//                                     ),
//                                     child: DataTable(
//                                       headingRowColor:
//                                           MaterialStateProperty.all(
//                                             Color(0xFFE5BC7F),
//                                           ),
//                                       columnSpacing: 24,
//                                       dataRowMinHeight: 60,
//                                       dataRowMaxHeight: double.infinity,
//                                       columns: const [
//                                         DataColumn(
//                                           label: Text(
//                                             'பி.நி',
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                         DataColumn(
//                                           label: Text(
//                                             'குறிப்பு',
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                         DataColumn(
//                                           label: Text(
//                                             'செயல்கள்',
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                       rows:
//                                           filteredPosts.asMap().entries.map((
//                                             entry,
//                                           ) {
//                                             final index = entry.key + 1;
//                                             final post = entry.value;
//                                             final postId = post['postId'];
//                                             final rawNote =
//                                                 post['content'] ?? '';
//                                             final raasiId =
//                                                 post['raasiId'] ?? 0;
//                                             final formattedNote =
//                                                 _formatNotesByWords(rawNote, 4);

//                                             return DataRow(
//                                               cells: [
//                                                 DataCell(
//                                                   Text(index.toString()),
//                                                 ),
//                                                 DataCell(
//                                                   ConstrainedBox(
//                                                     constraints: BoxConstraints(
//                                                       maxWidth: 400,
//                                                     ),
//                                                     child: Text(
//                                                       formattedNote,
//                                                       softWrap: true,
//                                                       overflow:
//                                                           TextOverflow.visible,
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         height: 1.5,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 DataCell(
//                                                   Row(
//                                                     children: [
//                                                       IconButton(
//                                                         icon: Icon(
//                                                           Icons.edit,
//                                                           color: Colors.blue,
//                                                         ),
//                                                         tooltip: 'திருத்து',
//                                                         onPressed:
//                                                             () =>
//                                                                 _showEditDialog(
//                                                                   postId,
//                                                                   rawNote,
//                                                                   raasiId,
//                                                                 ),
//                                                       ),
//                                                       IconButton(
//                                                         icon: Icon(
//                                                           Icons.delete,
//                                                           color: Colors.red,
//                                                         ),
//                                                         tooltip: 'நீக்கு',
//                                                         onPressed: () async {
//                                                           await deleteRaasiPost(
//                                                             postId,
//                                                           );
//                                                         },
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             );
//                                           }).toList(),
//                                     ),
//                                   ),
//                                 ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         onPressed: showBulkUploadDialog,
//                         child: Text(
//                           "பல குறிப்புகள் சேர்க்க",
//                           style: TextStyle(color: Colors.white),
//                         ),
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

// String _formatNotesByWords(String text, int wordsPerLine) {
//   final words = text.split(RegExp(r'\s+'));
//   final buffer = StringBuffer();

//   for (int i = 0; i < words.length; i++) {
//     buffer.write(words[i]);
//     if ((i + 1) % wordsPerLine == 0) {
//       buffer.write('\n');
//     } else {
//       buffer.write(' ');
//     }
//   }

//   return buffer.toString().trim();
// }
