import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Counters {
  static final Counters _singleton = Counters._internal();

  List<String> list = [];

  factory Counters() => _singleton;

  Counters._internal() {
    _getList();
  }

  _getList() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    list = localStorage.getStringList(Strings.counterDataKey) ?? [];
  }
}

class Util {
  static String formatDateTimeForMachines(DateTime dateTime) {
    return dateTime.toIso8601String().substring(0, 10);
  }

  static String formatDateTimeForHumans(DateTime dateTime) {
    var formatter = new DateFormat('EEE yyyy-MM-dd');
    return formatter.format(dateTime);
  }

  static String formatDateStringForHumans(String dateString) {
    return formatDateTimeForHumans(DateTime.parse(dateString));
  }

  static String buildCounterKey(String counterTitle, { required String dateString }) {
    return Strings.counterCountKey
        + "_"
        + counterTitle
        + "_"
        + dateString;
  }
}

class Strings {
  static const String appTitle = "What Counts";

  static const String counterDataKey = "counter_data";
  static const String counterCountKey = "counter_count";
  static const String countersDateKey = "counters_date";
}

class Ints {
  static const int maxCounters = 10; // currently baked into the bar color logic
  static const int maxCounterValue = 20;
}

class Hues {
  static const MaterialColor primarySwatch = Colors.deepPurple;
}
