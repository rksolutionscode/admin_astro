import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:testadm/sidebar/sidebar.dart';

class Logindata extends StatefulWidget {
  @override
  _loginScreenState createState() => _loginScreenState();
}

class _loginScreenState extends State<Logindata> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
  }

  Future<Map<String, String>> getUserDetails(String userId) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userSnapshot.exists) {
      final data = userSnapshot.data() as Map<String, dynamic>;
      return {
        'username': data['username'] ?? 'Unknown',
        'phone': data['phone'] ?? 'Unknown',
        'email': data['email'] ?? 'Unknown',
        'password': data['password'] ?? 'Unknown',
      };
    } else {
      return {
        'username': 'Unknown',
        'phone': 'Unknown',
        'email': 'Unknown',
        'password': 'Unknown',
      };
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
                            .collection('users')
                            .orderBy('username', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(child: Text("No data available."));
                          }

                          final allUsers = snapshot.data!.docs;

                          // Fetch user details for all users in advance
                          List<Future<Map<String, String>>> userDetailsFutures =
                              allUsers.map((doc) {
                            final userId = doc.id;
                            return getUserDetails(userId);
                          }).toList();

                          // Future.wait to fetch all user details at once
                          return FutureBuilder<List<Map<String, String>>>(
                            future: Future.wait(userDetailsFutures),
                            builder: (context, userDetailsSnapshot) {
                              if (userDetailsSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (userDetailsSnapshot.hasError) {
                                return Center(child: Text("Error loading data."));
                              }

                              final userDetailsList = userDetailsSnapshot.data ?? [];

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Table(
                                    border: TableBorder.all(color: Colors.black),
                                    columnWidths: {
                                      0: FixedColumnWidth(60),
                                      1: FixedColumnWidth(150),
                                      2: FixedColumnWidth(150),
                                      3: FixedColumnWidth(150),
                                      4: FixedColumnWidth(150),
                                    },
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                           color: const Color.fromARGB(255, 229, 188, 127),
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
                                              "Username",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepOrange),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Phone Number",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepOrange),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Email",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepOrange),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Password",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepOrange),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ...List.generate(allUsers.length, (index) {
                                        final doc = allUsers[index];
                                        final userDetails = userDetailsList[index];

                                        return TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text((index + 1).toString()),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(userDetails['username'] ?? 'Unknown'),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(userDetails['phone'] ?? 'Unknown'),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(userDetails['email'] ?? 'Unknown'),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(userDetails['password'] ?? 'Unknown'),
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            },
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
