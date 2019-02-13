import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daily_expense/model/note.dart';
import 'package:daily_expense/ui/note_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:daily_expense/service/firebase_firestore_service.dart';
class TaskRowNoAnim extends StatefulWidget {
  final Note note;
  final double dotSize = 12.0;

  const TaskRowNoAnim({Key key, this.note}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new TaskRowNoAnimState();
  }
}

class TaskRowNoAnimState extends State<TaskRowNoAnim> {
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  @override
  Widget build(BuildContext context) {
    String strSpentDate = widget.note.spentDate!=null?new DateFormat('dd-MMM-yyyy').format(widget.note.spentDate)+": ":"";
    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: new Row(
        children: <Widget>[
          new Container(
              width: 35.0,
              child: IconButton(
                icon: Icon(Icons.edit),
                iconSize: 20,
                color: Colors.blue,
                tooltip: 'Edit',
                onPressed: (){_navigateToNote(context,widget.note);},
              ),
          ),
          new Container(
            width: 80.0,
            child:  new Text(
              strSpentDate,
              style: new TextStyle(fontSize: 12.0),
            ),
          ),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  widget.note.title,
                  style: new TextStyle(fontSize: 18.0),
                ),
                new Text(
                  widget.note.description,
                  style: new TextStyle(fontSize: 12.0, color: Colors.grey),
                )
              ],
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: new Text(
              "Rs."+widget.note.amount.toString(),
              style: new TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ),
          new Container(
            width: 35.0,
            child: IconButton(
              icon: Icon(Icons.delete),
              iconSize: 20,
              color: Colors.blue,
              tooltip: 'Edit',
              onPressed: (){_deleteNote(context,widget.note);},
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToNote(BuildContext context, Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteScreen(note)),
    );
  }

  void _deleteNote(BuildContext context, Note note) async {
    db.deleteNote(note.id).then((notes) {
      setState(() {
        //items.removeAt(position);
      });
    });
  }
}
