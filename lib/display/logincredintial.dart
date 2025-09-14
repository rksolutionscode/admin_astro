// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:testadm/sidebar/sidebar.dart';

// class Logincredintial extends StatefulWidget {
//   const Logincredintial({super.key});

//   @override
//   State<Logincredintial> createState() => _LogincredintialFormState();
// }

// class _LogincredintialFormState extends State<Logincredintial> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   Widget _buildUserTable() {
//   return StreamBuilder<QuerySnapshot>(
//     stream: FirebaseFirestore.instance.collection('accountcreate').snapshots(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const CircularProgressIndicator();
//       }

//       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//         return const Text('பயனர்கள் எதுவும் கிடைக்கவில்லை'); // No users found
//       }

//       final users = snapshot.data!.docs;

//       return SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(minWidth: 600), // Set a minimum width
//           child: IntrinsicWidth(
//             child: Table(
//               border: TableBorder.all(color: Colors.grey, width: 1),
//               defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//               columnWidths: const {
//                 0: FlexColumnWidth(),
//                 1: FlexColumnWidth(),
//                 2: FlexColumnWidth(),
//               },
//               children: [
//                 // Header
//                 TableRow(
//                   decoration: const BoxDecoration( color: const Color.fromARGB(255, 229, 188, 127),),
//                   children: const [
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'பயனர் பெயர்',
//                         style: TextStyle(fontWeight: FontWeight.bold,
//                         color: Colors.deepOrange,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'கடவுச்சொல்',
//                         style: TextStyle(fontWeight: FontWeight.bold,
//                         color: Colors.deepOrange),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'அட்மின் ஐடி',
//                         style: TextStyle(fontWeight: FontWeight.bold,
//                         color: Colors.deepOrange),
//                       ),
//                     ),
//                   ],
//                 ),
//                 // Data rows
//                 for (final doc in users)
//                   TableRow(
//                     children: () {
//                       final data = doc.data() as Map<String, dynamic>;
//                       return [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(data['username'] ?? ''),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(data['password'] ?? ''),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(data['adminId'] ?? ''),
//                         ),
//                       ];
//                     }(),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }


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
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(30),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     if (!isLargeScreen)
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: IconButton(
//                           icon: const Icon(Icons.menu, color: Colors.orange),
//                           onPressed: () =>
//                               _scaffoldKey.currentState?.openDrawer(),
//                         ),
//                       ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       "பயனர் பட்டியல்", // User List
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _buildUserTable(),
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
