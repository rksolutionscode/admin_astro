import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testadm/sidebar/sidebar.dart';

class Rasi extends StatefulWidget {
  @override
  _RasiDisplayState createState() => _RasiDisplayState();
}

class _RasiDisplayState extends State<Rasi> {
  String _selectedRasi = "All Rasi";

  final List<String> _rasiList = [
    'மேஷம்',
    'ரிஷபம்',
    'மிதுனம்',
    'கடகம்',
    'சிம்மம்',
    'கன்னி',
    'துலாம்',
    'விருச்சிகம்',
    'தனுசு',
    'மகரம்',
    'கும்பம்',
    'மீனம்',
  ];

  Stream<QuerySnapshot> _getRasiStream() {
    return FirebaseFirestore.instance
        .collection('service_notes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: isMobile ? Sidebar() : null,
      body:
          isMobile
              ? _buildContent()
              : Row(
                children: [
                  SizedBox(width: screenWidth * 0.22, child: Sidebar()),
                  Expanded(child: _buildContent()),
                ],
              ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ராசி குறிப்புகள் மேலாண்மை',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal[800],
            ),
          ),
          const SizedBox(height: 20),
          _buildFilterDropdown(),
          const SizedBox(height: 20),
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.teal),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: Offset(2, 3),
          ),
        ],
      ),
      width: 280,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRasi,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          onChanged: (value) {
            setState(() {
              _selectedRasi = value!;
            });
          },
          items: [
            const DropdownMenuItem(value: "All Rasi", child: Text("All Rasi")),
            ..._rasiList.map(
              (rasi) => DropdownMenuItem(value: rasi, child: Text(rasi)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getRasiStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('பிழை ஏற்பட்டது'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final filteredDocs =
            _selectedRasi == "All Rasi"
                ? docs
                : docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['rasi']?.trim() ?? '') == _selectedRasi.trim();
                }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(
            child: Text("தேர்ந்தெடுக்கப்பட்ட ராசிக்கு குறிப்புகள் இல்லை."),
          );
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final rawNotes =
                data['notes']?.toString().trim() ?? 'குறிப்பு இல்லை';
            final notes = _formatNotesByWords(
              rawNotes,
              4,
            ); // ✅ Format by 4 words per line
            final rasi = data['rasi']?.toString().trim() ?? '';

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gradient Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        colors: [Color(0xFF00897B), Color(0xFF26A69A)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'எண்: ${index + 1}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          rasi,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notes
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Text(
                      notes,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const Divider(height: 0),

                  // Actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 12, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text(
                            "தொகு",
                            style: TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _editNoteDialog(doc.id, rawNotes),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text(
                            "அழி",
                            style: TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _deleteNote(doc.id),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteNote(String id) async {
    await FirebaseFirestore.instance
        .collection('service_notes')
        .doc(id)
        .delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('குறிப்பு நீக்கப்பட்டது')));
  }

  void _editNoteDialog(String id, String currentNote) {
    TextEditingController _controller = TextEditingController(
      text: currentNote,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("குறிப்பு திருத்துக"),
            content: TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "புதிய குறிப்பை உள்ளிடுக",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedNote = _controller.text.trim();
                  if (updatedNote.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('service_notes')
                        .doc(id)
                        .update({'notes': updatedNote});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('குறிப்பு புதுப்பிக்கப்பட்டது'),
                      ),
                    );
                  }
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }
}

String _formatNotesByWords(String text, int wordsPerLine) {
  final words = text.split(RegExp(r'\s+')); // Split by spaces
  final buffer = StringBuffer();

  for (int i = 0; i < words.length; i++) {
    buffer.write(words[i]);
    if ((i + 1) % wordsPerLine == 0) {
      buffer.write('\n');
    } else {
      buffer.write(' ');
    }
  }

  return buffer.toString().trim();
}
