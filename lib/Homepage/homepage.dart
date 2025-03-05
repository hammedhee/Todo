import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/notes_services.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  NotesServices notesServices = NotesServices();
  final TextEditingController noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // open box for update and add a new note

  void openNotBox({String? docId, String? existingNote}) {
    if (existingNote != null) {
      noteController.text = existingNote;
    } else {
      noteController.clear();
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please fill the field';
                  }
                  return null;
                },
                controller: noteController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelText: 'Notes',
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  //   validation
                  if (_formKey.currentState!.validate()) {
                    if (docId == null) {
                      //   adding to firebase
                      notesServices.addNotes(noteController.text);
                    } else {
                      //  upadating the currunt data
                      notesServices.updateData(docId, noteController.text);
                    }
                    noteController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 184, 184, 184),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => openNotBox(),
        child: Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Notes', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: notesServices.getNoteStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = notesList[index];
                  String documentId = document.id;
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText =
                      data['notes']?.toString() ?? 'No note available';
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        noteText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              notesServices.deleteData(documentId);
                            },
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                          ),
                          IconButton(
                            onPressed:
                                () => openNotBox(
                                  docId: documentId,
                                  existingNote: noteText,
                                ),
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ), // Edit icon
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No data'));
            }
          },
        ),
      ),
    );
  }
}
