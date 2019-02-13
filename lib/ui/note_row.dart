import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daily_expense/model/note.dart';

class NoteRow extends StatelessWidget {
  final Note aNote;
  final double dotSize = 12.0;
  final Animation<double> animation;

  const NoteRow({Key key, this.aNote, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String strSpentDate = aNote.spentDate!=null?new DateFormat('dd-MMM-yyyy').format(aNote.spentDate)+": ":"";
    return new FadeTransition(
      opacity: animation,
      child: new SizeTransition(
        sizeFactor: animation,
        child: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: new Row(
            children: <Widget>[
              new Padding(
                padding:
                    new EdgeInsets.symmetric(horizontal: 32.0 - dotSize / 2),
                child: new Container(
                  height: dotSize,
                  width: dotSize,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle, color: Colors.red),
                ),
              ),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      aNote.title,
                      style: new TextStyle(fontSize: 18.0),
                    ),
                    new Text(
                      aNote.description,
                      style: new TextStyle(fontSize: 12.0, color: Colors.grey),
                    )
                  ],
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: new Text(
                  strSpentDate,
                  style: new TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
