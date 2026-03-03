import 'dart:async';
import 'dart:ui';
import 'package:intl/intl.dart';

import '../config/client.dart';

class ClickUtils {
  static bool _isClicked = false;

  static Future<void> debounce(VoidCallback onClick,
      {Duration duration = const Duration(seconds: 1)}) async {
    if (_isClicked) {
      return;
    }

    _isClicked = true;
    onClick();

    await Future.delayed(duration);

    _isClicked = false;
  }
}

String getTimeFormat(String timeInEpoch) {
  DateTime datetime = getDateFromTimeStamp(int.parse(timeInEpoch));
  DateTime now = DateTime.now();
  int difference = DateTime(datetime.year, datetime.month, datetime.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;

  if (difference == 0) {
    return DateFormat('hh:mm a', appPreference.preferredLanguage)
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timeInEpoch)));
  } else {
    return DateFormat('dd/MM/yy', appPreference.preferredLanguage)
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timeInEpoch)));
  }
}

DateTime getDateFromTimeStamp(int timeStamp) {
  var date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
  return date;
}
