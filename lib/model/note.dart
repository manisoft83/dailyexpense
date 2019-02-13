class Note {
  String _id;
  DateTime _spentDate;
  String _title;
  String _description;
  double _amount;
  Note(this._id,this._spentDate, this._title, this._description, this._amount);

  Note.map(dynamic obj) {
    this._id = obj['id'];
    this._spentDate = obj['spentDate'];
    this._title = obj['title'];
    this._description = obj['description'];
    this._amount = obj['amount'];
  }

  String get id => _id;
  DateTime get spentDate => _spentDate;
  String get title => _title;
  String get description => _description;
  double get amount => _amount;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['spentDate'] = _spentDate;
    map['title'] = _title;
    map['description'] = _description;
    map['amount'] = _amount;
    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._spentDate= map['spentDate'];
    this._title = map['title'];
    this._description = map['description'];
    this._amount = map['amount'];
  }
}
