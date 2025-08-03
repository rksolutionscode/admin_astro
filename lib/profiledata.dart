import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:testadm/sidebar/sidebar.dart';

class ProfileData extends StatefulWidget {
  @override
  _ProfileDataScreenState createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileData> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();
  String searchTerm = '';

  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by username or phone',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            
                              searchTerm = '';
                            
                          },
                        ),
                      ),
                      onChanged: (value) {
                        
                          searchTerm = value.toLowerCase();
                        
                      },
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('profile')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text("No data available."));
                        }

                        final allNotes = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final username = (data['username'] ?? '').toString().toLowerCase();
                          final phone = (data['phone'] ?? '').toString().toLowerCase();
                          return username.contains(searchTerm) || phone.contains(searchTerm);
                        }).toList();

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Table(
                              border: TableBorder.all(color: Colors.black),
                              columnWidths: const {
                                0: FixedColumnWidth(50),
                                1: FixedColumnWidth(150),
                                2: FixedColumnWidth(120),
                                3: FixedColumnWidth(100),
                                4: FixedColumnWidth(100),
                                5: FixedColumnWidth(150),
                                6: FixedColumnWidth(150),
                                7: FixedColumnWidth(180),
                              },
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  decoration: BoxDecoration( color: const Color.fromARGB(255, 229, 188, 127),),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("S.No", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Username", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Phone", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("DOB", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("TOB", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("POB", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Aadhar", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Date & Time", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                ...allNotes.asMap().entries.map((entry) {
                                  final index = entry.key + 1;
                                  final doc = entry.value;
                                  final data = doc.data() as Map<String, dynamic>;

                                  final username = data['username'] ?? 'Unknown';
                                  final phone = data['phone'] ?? '';
                                  final dob = data['dob'] ?? '';
                                  final tob = data['tob'] ?? '';
                                  final pob = data['pob'] ?? '';
                                  final aadhar = data['aadhar'] ?? '';
                                  final timestamp = data['timestamp'] as Timestamp?;

                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(index.toString()),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(username),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(phone),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(dob),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(tob),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(pob),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(aadhar),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          timestamp != null ? formatTimestamp(timestamp) : '',
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
          ],
        ),
      ),
    );
  }
}
