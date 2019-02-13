import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_expense/model/note.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

final CollectionReference noteCollection = Firestore.instance.collection('notes');

class FirebaseFirestoreService {

  static final FirebaseFirestoreService _instance = new FirebaseFirestoreService.internal();

  factory FirebaseFirestoreService() => _instance;

  FirebaseFirestoreService.internal();

  Future<Note> createNote(DateTime spentDate, String title, String description, double amount) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(noteCollection.document());

      final Note note = new Note(ds.documentID, spentDate, title, description, amount);
      final Map<String, dynamic> data = note.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return Note.fromMap(mapData);
    }).catchError((error) {
      Fluttertoast.showToast(
          msg: error,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      print('error: $error');
      return null;
    });
  }

  Stream<QuerySnapshot> getNoteList({int offset, int limit, String fromDate,String toDate, String type}) {
    Query noteQuery = noteCollection.orderBy("spentDate",descending: true);
    if(fromDate!=null && fromDate.isNotEmpty){
      DateFormat dateFormat = new DateFormat().addPattern('dd-MMM-yyyy');
      DateTime providedDate = dateFormat.parse(fromDate);
      noteQuery = noteQuery.where("spentDate",isGreaterThanOrEqualTo: providedDate );
    }
    if(toDate!=null && toDate.isNotEmpty){
      DateFormat dateFormat = new DateFormat().addPattern('dd-MMM-yyyy');
      DateTime providedDate = dateFormat.parse(toDate);
      noteQuery = noteQuery.where("spentDate",isLessThanOrEqualTo: providedDate );
    }
    if(type != null && type.isNotEmpty){
      noteQuery = noteQuery.where("title",isEqualTo: type );
    }
    Stream<QuerySnapshot> snapshots = noteQuery.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Future<dynamic> updateNote(Note note) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(noteCollection.document(note.id));

      await tx.update(ds.reference, note.toMap());
      return {'updated': true};
    };

    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  Future<dynamic> deleteNote(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(noteCollection.document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }
}
