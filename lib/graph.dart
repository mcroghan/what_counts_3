import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';

class Graph extends StatefulWidget {
  Graph({ required Key key, required this.title, required this.switchToCountersTabCallback }) : super(key: key);

  final String title;
  final Function switchToCountersTabCallback;

  @override
  _GraphState createState() => _GraphState(title, switchToCountersTabCallback);
}

class CounterData {
  final String counterName;
  final int value;
  final int maxValue;
  final charts.Color color;

  CounterData(this.counterName, this.value, this.maxValue, Color color)
      : this.color = new charts.Color(
      r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class _GraphState extends State<Graph> {
  _GraphState(this._title, this._switchToCountersTabCallback);

  final String _title;
  final Function _switchToCountersTabCallback;
  final Counters _counters = Counters();

  final Map<int, List<int>> _barColors = { // lovingly handcrafted for contrast
    1: [500],
    2: [100, 900],
    3: [100, 500, 900],
    4: [100, 300, 600, 900],
    5: [100, 200, 400, 600, 900],
    6: [100, 200, 300, 500, 700, 900],
    7: [100, 200, 300, 400, 500, 700, 900],
    8: [100, 200, 300, 400, 500, 600, 700, 900],
    9: [100, 200, 300, 400, 500, 600, 700, 800, 900],
    10: [50, 100, 200, 300, 400, 500, 600, 700, 800, 900],
  };

  Future<int> _getCounter(String counterKey) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getInt(counterKey) ?? 0;
  }



  @override
  Widget build(BuildContext context) {
    var data = List.generate(_counters.list.length, (index) {
      String counterName = _counters.list[index];
      String counterKey = Util.buildCounterKey(counterName, dateString: _title);
      //Future<int> counterValue = _getCounter(counterKey);
      return CounterData(
          counterName,
          0, //counterValue,
          Ints.maxCounterValue,
          Hues.primarySwatch[_barColors[_counters.list.length]![index]] ?? Color(0)
      );
    });

    var series = [
      charts.Series(
        domainFn: (CounterData counterData, _) => counterData.counterName,
        measureFn: (CounterData counterData, _) => counterData.value,
        measureUpperBoundFn: (CounterData counterData, _) => counterData.maxValue,
        labelAccessorFn: (CounterData counterData, _) => counterData.value.toString()
            + " "
            + counterData.counterName,
        colorFn: (CounterData counterData, _) => counterData.color,
        id: 'Counters',
        data: data,
      ),
    ];

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Text(Util.formatDateStringForHumans(_title),
                style: Theme.of(context).textTheme.headline5
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _switchToCountersTabCallback(context, _title),
            )
          ]
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            height: _counters.list.length * 30.0,
            child: charts.BarChart(
              series,
              animate: true,
              vertical: false,
              barRendererDecorator: new charts.BarLabelDecorator<String>(),
              domainAxis: new charts.OrdinalAxisSpec(
                showAxisLine: true,
                renderSpec: new charts.NoneRenderSpec()
              ),
              primaryMeasureAxis: charts.NumericAxisSpec(
                showAxisLine: true,
                renderSpec: new charts.NoneRenderSpec(),
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  dataIsInWholeNumbers: true,
                  desiredTickCount: Ints.maxCounterValue + 1,
                ),
              ),
            ),
          ),
        ),
      ]
    );
  }
}


