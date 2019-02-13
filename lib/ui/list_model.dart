import 'package:daily_expense/model/note.dart';
import 'package:daily_expense/ui/note_row.dart';
import 'package:flutter/material.dart';

class ListModel {
  ListModel(this.listKey, items) : this.items = new List.of(items);

  final GlobalKey<AnimatedListState> listKey;
  final List<Note> items;

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, Note item) {
    items.insert(index, item);
    _animatedList.insertItem(index, duration: new Duration(milliseconds: 150));
  }

  Note removeAt(int index) {
    final Note removedItem = items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(
        index,
        (context, animation) => new NoteRow(
              aNote: removedItem,
              animation: animation,
            ),
        duration: new Duration(milliseconds: (150 + 200*(index/length)).toInt())
      );
    }
    return removedItem;
  }

  int get length => items.length;

  Note operator [](int index) => items[index];

  int indexOf(Note item) => items.indexOf(item);
}
