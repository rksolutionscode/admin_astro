// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:testadm/sidebar/sidebar.dart';

// class StarDisplayScreen extends StatefulWidget {
//   @override
//   _StarScreenState createState() => _StarScreenState();
// }

// class _StarScreenState extends State<StarDisplayScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final ValueNotifier<String> selectedRasiNotifier = ValueNotifier<String>(
//     'அனைத்து நட்சத்திரங்கள்',
//   );
//   final TextEditingController noteController = TextEditingController();

//   final String bearerToken = "<YOUR_BEARER_TOKEN>";
//   List<Map<String, dynamic>> posts = [];

//   final List<String> rasis = [
//     "அனைத்து நட்சத்திரங்கள்",
//     "அசுவினி",
//     "பரணி",
//     "கார்த்திகை",
//     "ரோகிணி",
//     "மிருகசீரிடம்",
//     "திருவாதிரை",
//     "புனர்பூசம்",
//     "பூசம்",
//     "ஆயில்யம்",
//     "மகம்",
//     "பூரம்",
//     "உத்திரம்",
//     "ஹஸ்தம்",
//     "சித்திரை",
//     "சுவாதி",
//     "விசாகம்",
//     "அனுஷம்",
//     "கேட்டை",
//     "மூலம்",
//     "பூராடம்",
//     "உத்திராடம்",
//     "திருவோணம்",
//     "அவிட்டம்",
//     "சதயம்",
//     "பூரட்டாதி",
//     "உத்திரட்டாதி",
//     "ரேவதி",
//   ];

//   Future<void> fetchPosts() async {
//     final url = Uri.parse("http://astro-j7b4.onrender.com/api/admins/star");
//     final response = await http.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $bearerToken',
//         'Content-Type': 'application/json',
//       },
//     );
//     if (response.statusCode == 200) {
//       setState(() {
//         posts = List<Map<String, dynamic>>.from(json.decode(response.body));
//       });
//     }
//   }

//   Future<void> createPost(int starId, String description) async {
//     final url = Uri.parse("http://astro-j7b4.onrender.com/api/admins/star");
//     final response = await http.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $bearerToken',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         "starId": starId,
//         "description": description,
//         "type": "Positive",
//         "adminId": 8,
//       }),
//     );
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       await fetchPosts();
//       noteController.clear();
//     } else {
//       throw Exception("Failed to create post");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchPosts();
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
//                         Expanded(
//                           flex: 2,
//                           child: DropdownButton<String>(
//                             value: selectedRasiNotifier.value,
//                             onChanged:
//                                 (value) => selectedRasiNotifier.value = value!,
//                             items:
//                                 rasis
//                                     .map(
//                                       (rasi) => DropdownMenuItem(
//                                         value: rasi,
//                                         child: Text(rasi),
//                                       ),
//                                     )
//                                     .toList(),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         ElevatedButton(
//                           onPressed: () async {
//                             final rasi = selectedRasiNotifier.value;
//                             final note = noteController.text.trim();
//                             if (rasi != "அனைத்து நட்சத்திரங்கள்" &&
//                                 note.isNotEmpty) {
//                               await createPost(rasis.indexOf(rasi), note);
//                             }
//                           },
//                           child: Text("சேர்க்கவும்"),
//                         ),
//                       ],
//                     ),
//                     TextField(
//                       controller: noteController,
//                       decoration: InputDecoration(
//                         hintText: "குறிப்பு சேர்க்கவும்",
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: posts.length,
//                         itemBuilder: (context, index) {
//                           final post = posts[index];
//                           return ListTile(
//                             title: Text(post['description'] ?? ''),
//                             subtitle: Text("Star ID: ${post['starId']}"),
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
