import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class NotesServices {
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'notes',
  );
  Future addNotes(String note) async {
    try {
      return notes.add({"notes": note, "time": Timestamp.now()});
    } catch (e) {
      throw Exception(e);
    }
  }

  Stream<QuerySnapshot> getNoteStream() {
    final noteStreamNote = notes.orderBy("time", descending: true).snapshots();
    log(noteStreamNote.toString());
    return noteStreamNote;
  }

  Future updateData(String docId, String newnote) async {
    try {
      return notes.doc(docId).update({
        "notes": newnote,
        "time": Timestamp.now(),
      });
    } catch (e) {
      throw Exception('error on data updating  === $e');
    }
  }

  Future deleteData(String docId) async {
    try {
      return notes.doc(docId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
