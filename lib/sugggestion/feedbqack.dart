import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:testadm/sidebar/sidebar.dart';

class Suggestion extends StatefulWidget {
  @override
  _SuggestionScreenState createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<Suggestion> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedRow;

  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
  }

  Future<String> getUserName(String userId) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    if (userSnapshot.exists) {
      return userSnapshot.data()?['username'] ?? 'Unknown';
    } else {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;

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
                          icon: Icon(Icons.menu),
                          onPressed:
                              () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                      ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('suggestion')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(child: Text("No data available."));
                          }

                          final allNotes = snapshot.data!.docs;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Table(
                                border: TableBorder.all(color: Colors.black),
                                columnWidths: {
                                  0: FixedColumnWidth(60),
                                  1: FixedColumnWidth(150),
                                  2: FixedColumnWidth(350),
                                  3: FixedColumnWidth(180),
                                  4: FixedColumnWidth(80),
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "S.No",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "User Name",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Suggestion",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Date & Time",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Select",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...allNotes.asMap().entries.map((entry) {
                                    final index = entry.key + 1;
                                    final doc = entry.value;
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final userId = data['username'] ?? '';
                                    final suggestion = data['suggestion'] ?? '';
                                    final timestamp =
                                        data['timestamp'] as Timestamp;

                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(index.toString()),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: FutureBuilder<String>(
                                            future: getUserName(userId),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Text("Loading...");
                                              }
                                              return Text(snapshot.data ??
                                                  'Unknown');
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(suggestion),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                              formatTimestamp(timestamp)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Checkbox(
                                            value: _selectedRow == index,
                                            onChanged: (bool? value) {
                                             _selectedRow = value == true ? index : null;

                                            },
                                          ),
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
