import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:daily_expense/model/note.dart';
import 'package:daily_expense/service/firebase_firestore_service.dart';
import 'package:daily_expense/ui/list_model.dart';
import 'package:daily_expense/ui/note_row_no_anim.dart';
import 'package:daily_expense/ui/note_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

enum Answer{YES, NO, MAYBE}
class ListViewNote extends StatefulWidget {

  @override
  _ListViewNoteState createState() => new _ListViewNoteState();
}
class _ListViewNoteState extends State<ListViewNote> {
  DateTime _date=new DateTime.now();
  List<String> _types = <String>['', 'Cable','Electricity','Water','Rent','Cloth','Grocery', 'Milk','Fruits','Vegetables','Resturant','Transport','Mobile','School Fees',
  'Medicine','Petrol','Entertainment', 'Others'];
  String _selectedFilterType = "";
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  ListModel listModel;
  Widget appBarTitle = new Text("Spent Notes");
  final TextEditingController _searchQuery = new TextEditingController();
  TextEditingController _dateController = new TextEditingController();
  TextEditingController _toDateController = new TextEditingController();
  final GlobalKey<AnimatedListState> _listKey =
  new GlobalKey<AnimatedListState>();
  List<Note> items=[new Note("1",null,"test","test",100),new Note("2",null,"test","test",100)];
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  Note aNote=new Note("1",null,"test","test",100);
  StreamSubscription<QuerySnapshot> noteSub;
  TextEditingController _totalTextController  = new TextEditingController();

  @override
  void initState() {
    super.initState();

    //items = new List();

    items.add(aNote);
    noteSub?.cancel();
    var now = new DateTime.now();
    var formatter = new DateFormat('MMM');
    String month = formatter.format(now);
    formatter = new DateFormat('yyyy');
    String year = formatter.format(now);
    String initFromDate ="01-"+month+"-"+year;
    noteSub = db.getNoteList(fromDate: initFromDate).listen((QuerySnapshot snapshot) {
      final List<Note> notes = snapshot.documents
          .map((documentSnapshot) => Note.fromMap(documentSnapshot.data))
          .toList();
      listModel = new ListModel(_listKey, items);
      setState(() {
        this.items = notes;
        calculateTotal();
      });
    });
    _dropDownMenuItems = getDropDownMenuItems();
  }

  @override
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  }

  String _answer = "";

  void setAnswer(String value){
    setState((){
      _answer = value;
    });
  }

  Future<Null> askuser() async{
    switch(
    await showDialog(
        context: context,
        builder: (_) => SimpleDialog(
          title: Text('Do you like flutter'),
          children: <Widget>[
            new SimpleDialogOption(
                onPressed: (){Navigator.pop(context,Answer.YES);},
                child: const Text('Yess!!!!')
            ),
            new SimpleDialogOption(
                onPressed: (){
                  //items.removeAt(0);
                  items.add(aNote);
                  setState(() {
                    //this.items = notes;
                  });
                  Fluttertoast.showToast(
                      msg: "This is Center Short Toast",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.lightBlue,
                      textColor: Colors.white
                  );
                },
                child: const Text('No!!!!')
            ),
            new SimpleDialogOption(
                onPressed: (){Navigator.pop(context,Answer.MAYBE);},
                child: const Text('May Be!!!!')
            )
          ],
        )
    ))
    {
      case Answer.YES:
        setAnswer('yes');
        break;
      case Answer.NO:
        setAnswer('no');
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    Icon actionIcon = new Icon(Icons.filter_list);
    return MaterialApp(
      title: 'Daily Notes',
      home: Scaffold(
        appBar: AppBar(
            title: Text('Daily Notes'),
            centerTitle: true,
            backgroundColor: Colors.blue,
            actions: <Widget>[
              new IconButton(icon: actionIcon,
                onPressed: () {_showDialog();
                //  setState(() {
                if (actionIcon.icon == Icons.filter_list) {
                  actionIcon = new Icon(Icons.close, color: Colors.white,);
                  this.appBarTitle = new TextField(
                    controller: _searchQuery,
                    style: new TextStyle(
                      color: Colors.white,

                    ),
                    decoration: new InputDecoration(
                        prefixIcon: new Icon(Icons.search, color: Colors.white),
                        hintText: "Search...",
                        hintStyle: new TextStyle(color: Colors.white)
                    ),
                  );
                  //_handleSearchStart();
                }
                },),
            ]
        ),
        body: Container(
          child: new Stack(
            children: <Widget>[

              _buildBottomPart(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _createNewNote(context),
        ),
      ),
    );
  }

  Widget _buildBottomPart() {
    return new Padding(
      padding: new EdgeInsets.only(top: 8),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTasksList(),
          new TextField(
            controller: _totalTextController,
            decoration: InputDecoration(labelText: 'Total: ',
              icon: const Icon(Icons.attach_money),
            ),
          )
        ],
      ),
    );
  }
  Widget _buildTasksList() {
    return new Expanded(
      child: new ListView(
        children: items.map((task) => new TaskRowNoAnim(note: task)).toList(),
      ),
    );
  }
  void _deleteNote(BuildContext context, Note note, int position) async {
    db.deleteNote(note.id).then((notes) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _navigateToNote(BuildContext context, Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteScreen(note)),
    );
  }

  void _createNewNote(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteScreen(Note(null,DateTime.now(), '', '', 0))),
    );
  }

  Future<Null> _selectDate(BuildContext context, TextEditingController _controller) async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2017),
        lastDate: new DateTime(2020));
    if(picked!=null && picked != _date){
      print('Date selected: ${_date.toString()}');
      Fluttertoast.showToast(
          msg: "${new DateFormat('dd-MMM-yyyy').format(picked)}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white
      );
      // selected = picked;
      _controller.text = new DateFormat('dd-MMM-yyyy').format(picked);
      /*setState(() {
        _date = picked;
      });*/
    }
  }

  calculateTotal(){
    double total = 0;
    for (Note aNote in items) {
      total = total + aNote.amount;
    }
    _totalTextController.text = total.toString();
  }
  _showDialog() async {


    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          title:  new Center(
              child: new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new Flexible(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                              "Filter Rows by selecting date and type...")
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.blue,),
                      tooltip: 'Close',
                      onPressed: () {  Navigator.pop(context);
                      },
                    ),
                  ])
          ),
          content:
          new Container(
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: const Color(0xFFFFFF),
              borderRadius: new BorderRadius.all(new Radius.circular(64.0)),
            ),
            child:   SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Container(
                        width: 35.0,
                        child: IconButton(
                          icon: Icon(Icons.calendar_today),
                          iconSize: 20,
                          color: Colors.blue,
                          tooltip: 'From Date',
                          onPressed: (){_selectDate(context, _dateController);},
                        ),
                      ),
                      new Flexible(
                          child: new TextField(
                            controller: _dateController,
                            decoration: InputDecoration(labelText: 'From Date',

                            ),
                          )
                      ),
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Container(
                        width: 35.0,
                        child: IconButton(
                          icon: Icon(Icons.calendar_today),
                          iconSize: 20,
                          color: Colors.blue,
                          tooltip: 'To Date',
                          onPressed: (){_selectDate(context, _toDateController);},
                        ),
                      ),
                      new Flexible(
                          child: new TextField(
                            controller: _toDateController,
                            decoration: InputDecoration(labelText: 'To Date',

                            ),
                          )
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    child: new Center(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                new FormField<String>(
                                  builder: (FormFieldState<String> state) {
                                    return InputDecorator(
                                      decoration: InputDecoration(
                                        icon: const Icon(Icons.business,  color: Colors.blue,),
                                        labelText: 'Type',
                                        errorText: state.hasError ? state.errorText : null,
                                      ),
                                      isEmpty: _selectedFilterType == '',
                                      child: new DropdownButtonHideUnderline(

                                        child: new DropdownButton<String>(
                                          value: _selectedFilterType,
                                          isDense: true,
                                          onChanged: (String newValue) {
                                            setState(() {
                                              //newContact.favoriteColor = newValue;
                                              _selectedFilterType = newValue;
                                              state.didChange(newValue);
                                            });
                                          },
                                          items: _types.map((String value) {
                                            return new DropdownMenuItem<String>(
                                              value: value,
                                              child: new Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  },
                                  validator: (val) {
                                    return val != '' ? null : 'Please select a Type';
                                  },
                                ),
                                Padding(padding: new EdgeInsets.all(5.0)),
                              ],
                            ),
                          ],
                        )
                    ),),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('CLEAR'),
                onPressed: () {
                  _dateController.text="";
                  _toDateController.text = "";
                  _selectedFilterType = "";
                  Navigator.pop(context);
                }

            ),
            new InkWell(
              onTap: () {
                  Navigator.pop(context);
                  items.add(aNote);
                  noteSub = db.getNoteList(fromDate: _dateController.text,toDate: _toDateController.text, type: _selectedFilterType).listen((QuerySnapshot snapshot) {
                  final List<Note> notes = snapshot.documents
                      .map((documentSnapshot) => Note.fromMap(documentSnapshot.data))
                      .toList();
                  listModel = new ListModel(_listKey, items);
                  setState(() {
                    this.items = notes;
                    calculateTotal();
                  });
                  });
              },
              child: new Container(
                width: 80.0,
                height: 35.0,
                decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.blue, width: 2.0),
                  borderRadius: new BorderRadius.circular(10.0),
                ),
                child: new Center(child: new Text('FILTER', style: new TextStyle(fontSize: 14.0, color: Colors.blue),),),

              ),
            ),
          ],
        );
      },
    );
  }
  void changedDropDownItem(String selectedType) {
    setState(() {
      _selectedFilterType = selectedType;
    });
  }
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in _types) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(
          value: city,
          child: new Text(city)
      ));
    }

  }
}


class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}

