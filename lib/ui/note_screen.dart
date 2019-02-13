import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:daily_expense/model/note.dart';
import 'package:daily_expense/service/firebase_firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NoteScreen extends StatefulWidget {
  final Note note;
  NoteScreen(this.note);

  @override
  State<StatefulWidget> createState() => new _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  FirebaseFirestoreService db = new FirebaseFirestoreService();

  //TextEditingController _titleController;
  TextEditingController _descriptionController;
  TextEditingController _dateController;
  TextEditingController _amountController;
  DateTime _date=new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();
  DateTime selected;
  List<DropdownMenuItem<String>> types = [];
  List<String> values= new List<String>();
  List<String> _types = <String>['', 'Cable','Electricity','Water','Rent','Cloth','Grocery', 'Milk','Fruits','Vegetables','Resturant','Transport','Mobile','School Fees',
  'Medicine','Petrol','Entertainment', 'Others'];
  String selectedType = '';

  Future<Null> _selectDate(BuildContext context) async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2017),
        lastDate: new DateTime(2020));
    if(picked!=null && picked != _date){
      print('Date selected: ${_date.toString()}');
      selected = picked;
      _dateController.text = new DateFormat('dd-MMM-yyyy').format(picked);
      setState(() {
        _date = picked;
      });
    }
  }
  void initTypes(){
    values.addAll(['Cable','Electricity','Water','Rent','Cloth','Grocery', 'Milk','Fruits','Vegetables','Resturant','Transport','Mobile','School Fees',
    'Medicine','Petrol', 'Others']);

  }

  @override
  void initState() {
    super.initState();

    //_titleController = new TextEditingController(text: widget.note.title);
    _descriptionController = new TextEditingController(text: widget.note.description);
    String strDate = widget.note.spentDate!=null?new DateFormat('dd-MMM-yyyy').format(widget.note.spentDate):"";
    _dateController = new TextEditingController(text: strDate);
    _amountController = new TextEditingController(text: widget.note.amount!=null? widget.note.amount.toString():"");
    selectedType = widget.note.title;
    initTypes();
  }

  @override
  Widget build(BuildContext context) {
    var dateFormat_1 = new Column(
      children: <Widget>[
        new SizedBox(
          height:30.0,
        ),
        selected !=null?new Text(
          new DateFormat('dd-MM-yyyy').format(selected),
          style: new TextStyle(
            color: Colors.blue,
            fontSize: 20.0,
          ),
        )
            :new SizedBox(
          width: 0.0,
          height: 0.0,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('Spent Note')),
      body: Container(

        margin: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child:  new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  new Flexible(
                      child: new TextField(
                        controller: _dateController,
                        decoration: InputDecoration(labelText: 'Spent Date',
                          icon: const Icon(Icons.calendar_today),
                        ),
                      )
                  ),
                  new OutlineButton(
                    child: new Text('Select Date'),
                    onPressed: (){_selectDate(context);},
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  new FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.business),
                          labelText: 'Type',
                          errorText: state.hasError ? state.errorText : null,
                        ),
                        isEmpty: selectedType == '',
                        child: new DropdownButtonHideUnderline(
                          child: new DropdownButton<String>(
                            value: selectedType,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                //newContact.favoriteColor = newValue;
                                selectedType = newValue;
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
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description',
                      icon: const Icon(Icons.comment),),
                  ),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Amount',icon: const Icon(Icons.storage)),
                  ),

                  Padding(padding: new EdgeInsets.all(5.0)),

                  RaisedButton(
                    child: (widget.note.id != null) ? Text('Update') : Text('Add'),
                    onPressed: () {
                      DateFormat format = new DateFormat("dd-MMM-yyyy");
                      DateTime spentDate = format.parse(_dateController.text);
                      if("0.0" == _amountController.text || _amountController.text.isEmpty){
                        Fluttertoast.showToast(
                            msg: "Amount cannot be empty!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.lightBlue,
                            textColor: Colors.white
                        );
                        return;
                      }

                      double amount= _amountController.text.isNotEmpty?double.tryParse(_amountController.text):0;
                      if (widget.note.id != null) {
                        db
                            .updateNote(
                            Note(widget.note.id, spentDate, selectedType, _descriptionController.text, amount))
                            .then((_) {
                          Navigator.pop(context);
                        });
                      } else {
                        db.createNote(spentDate, selectedType, _descriptionController.text, amount).then((_) {
                          Navigator.pop(context);
                        });
                      }
                    },
                  ),
                ],
              ),
            ]),
      ),
    );
  }

  String dropdown1Value = 'Free';
  String dropdown2Value;
  String dropdown3Value = 'Four';

  Widget buildDropdownButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: const Text('Simple dropdown:'),
            trailing: DropdownButton<String>(
              value: dropdown1Value,
              onChanged: (String newValue) {
                setState(() {
                  dropdown1Value = newValue;
                });
              },
              items: <String>['One', 'Two', 'Free', 'Four'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          ListTile(
            title: const Text('Dropdown with a hint:'),
            trailing: DropdownButton<String>(
              value: dropdown2Value,
              hint: const Text('Choose'),
              onChanged: (String newValue) {
                setState(() {
                  dropdown2Value = newValue;
                });
              },
              items: <String>['One', 'Two', 'Free', 'Four'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          ListTile(
            title: const Text('Scrollable dropdown:'),
            trailing: DropdownButton<String>(
              value: dropdown3Value,
              onChanged: (String newValue) {
                setState(() {
                  dropdown3Value = newValue;
                });
              },
              items: <String>[
                'One', 'Two', 'Free', 'Four', 'Can', 'I', 'Have', 'A', 'Little',
                'Bit', 'More', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten'
              ]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              })
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

}

