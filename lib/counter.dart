import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';

class Counter extends StatefulWidget {
  Counter({ required Key key, required this.title, required this.dateString, required this.deleteCounterCallback }) : super(key: key);

  final String title;
  final String dateString;
  final Function deleteCounterCallback;

  @override
  _CounterState createState() => _CounterState(title, dateString, deleteCounterCallback);
}

class _CounterState extends State<Counter> {
  _CounterState(this._title, this._dateString, this._deleteCounterCallback);

  final String _title;
  final String _dateString;
  final Function _deleteCounterCallback;

  int _currentValue = 0;

  void _setCounterState(int newValue) {
    setState(() {
      _currentValue = newValue;
    });
  }

  void _saveCounterState(int newValue) async {
    _setCounterState(newValue);

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setInt(Util.buildCounterKey(_title, dateString: _dateString), newValue);
    build(context);
  }

  void _setCounterStateToStoredValue(String key) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    _setCounterState(localStorage.getInt(key) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    _setCounterStateToStoredValue(Util.buildCounterKey(_title, dateString: _dateString));

    return SingleChildScrollView(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(_title, style: Theme.of(context).textTheme.headline5)
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteCounterCallback(context, _title)
            )
          ]
        ),
        NumberPicker (
          value: _currentValue,
          minValue: 0,
          maxValue: Ints.maxCounterValue,
          onChanged: (newValue) => _saveCounterState(newValue.toInt()),
        ),
      ]
    ));
  }
}
