import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';
import 'counter.dart';
import 'graph.dart';

void main() => start();

Future start() async {
  runApp(WhatCounts(title: Strings.appTitle));
}

class WhatCounts extends StatelessWidget {
  WhatCounts({Key? key, required this.title}) : super(key: key);

  final String title;

  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        primarySwatch: Hues.primarySwatch,
        textTheme: TextTheme(
          headline5: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0
          )
        )
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  static const int historyDays = 14;

  static const int countersTab = 0;
  static const int graphsTab = 1;

  static RegExp _validationRegEx = RegExp(r"^[a-zA-Z0-9 ]{1,10}$");

  bool _isCounterNameValid = true;

  Counters _counters = Counters();
  String _countersDateString = Util.formatDateTimeForMachines(DateTime.now());
  bool _fabVisible = true;
  late TabController _tabController;
  ScrollController _graphScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(vsync: this, length: 2);
    
    _tabController.addListener(() {
      switch (_tabController.index) {
        case countersTab:
          setState(() {
            _fabVisible = true;
          });
          break;
        case graphsTab:
          setState(() {
            _fabVisible = false;
          });
          _graphScrollController.animateTo(
            _graphScrollController.position.maxScrollExtent,
            curve: Curves.bounceIn,
            duration: Duration(milliseconds: 500),
          );
          break;
        default:
      }

      build(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void deleteCounter(BuildContext context, String counterName) {
    setState(() {
      _counters.list.remove(counterName);
      _fabVisible = _counters.list.length < Ints.maxCounters;
    });

    _setCounter();
    build(context);
  }

  void addCounter(BuildContext context, String submittedCounterName) {
    setState(() {
      _isCounterNameValid =
          !_counters.list.contains(submittedCounterName)
          && _validationRegEx.hasMatch(submittedCounterName);
    });

    if (_isCounterNameValid) {
      Navigator.pop(context, submittedCounterName);

      setState(() {
        _counters.list.add(submittedCounterName);
        _fabVisible = _counters.list.length < Ints.maxCounters;
      });

      _setCounter();
      build(context);
    }
  }

  void _setCounter() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setStringList(Strings.counterDataKey, _counters.list);
  }

  void _setDate(String dateString) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString(Strings.countersDateKey, dateString);
  }

  void switchToCountersTab(BuildContext context, String countersDateString) {
    setState(() {
      _countersDateString = countersDateString;
    });

    _setDate(countersDateString);
    _tabController.animateTo(countersTab);
    build(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.plus_one)),
            Tab(icon: Icon(Icons.insert_chart)),
          ],
        ),
        title: Text(Strings.appTitle),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  Util.formatDateStringForHumans(_countersDateString),
                  style: Theme.of(context).textTheme.headline5
                )
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  children: List.generate(_counters.list.length, (index) {
                    String title = _counters.list[index];
                    return Counter(
                      title: title,
                      dateString: _countersDateString,
                      key: Key(title),
                      deleteCounterCallback: deleteCounter,
                    );
                  })
                )
              )
            ]
          ),
          ListView(
            controller: _graphScrollController,
            children: List.generate(historyDays, (index) {
              Duration days = Duration(days: -(historyDays - index - 1));
              String title = Util.formatDateTimeForMachines(DateTime.now().add(days));
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Graph(
                  title: title,
                  switchToCountersTabCallback: switchToCountersTab,
                  key: Key(title),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Offstage(
        offstage: !_fabVisible,
        child: FloatingActionButton(
          tooltip: 'Add a new counter',
          child: Icon(Icons.add),
          onPressed: () => showDialog<String>(
            context: context,
            builder: (context) => Dialog(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Please enter a counter name",
                  errorText: _isCounterNameValid
                      ? null
                      : "Names must be 1-10 letters/numbers/spaces, and unique",
                ),
                onSubmitted: (submittedCounterName) => addCounter(context, submittedCounterName),
              )
            ),
          ),
        ),
      ),
    );
  }
}
