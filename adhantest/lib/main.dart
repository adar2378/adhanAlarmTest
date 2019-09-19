import 'dart:typed_data';

import 'package:adhantest/alarm_management_model.dart';
import 'package:adhantest/alarm_status_bloc.dart';
import 'package:adhantest/alarm_time_bloc.dart';
import 'package:adhantest/api_provider.dart';
import 'package:adhantest/resources.dart';
import 'package:adhantest/time_saver.dart';
import 'package:adhantest/timing_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// var initializationSettingsAndroid =
//     AndroidInitializationSettings('ic_launcher');
// var initializationSettingsIOS = IOSInitializationSettings(
//     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
// var initializationSettings = InitializationSettings(
//     initializationSettingsAndroid, initializationSettingsIOS);
// flutterLocalNotificationsPlugin.initialize(initializationSettings,
//     onSelectNotification: onSelectNotification);
int mainAlarmId = 22;
void main() async {
  await AndroidAlarmManager.initialize();
  DateTime midNight = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 58);
  print(midNight.toString());
  runApp(MyApp());
  AndroidAlarmManager.periodic(
    Duration(hours: 24),
    mainAlarmId,
    _mainAlarm,
    startAt: midNight,
    rescheduleOnReboot: true,
  );
  alarmManagementBloc.outputter.listen((value) async {
    print("in the alarmmangement bloc");
    TimeSaver timeSaver = TimeSaver();
    var listOftiming = await timeSaver.getTiming(DateTime.now().month);

    if (value.alarmEvent == AlarmEvent.SET) {
      print("setting almost");
      bool setOneShot = false;
      int hour, minute;
      var todaysTimingForAllAdhan = listOftiming[DateTime.now().day].timings;
      var spllitedBySpace;
      var i = value.data['id'];
      if (i == 0) {
        spllitedBySpace = todaysTimingForAllAdhan.fajr.split(" ");
      } else if (i == 1) {
        spllitedBySpace = todaysTimingForAllAdhan.dhuhr.split(" ");
      } else if (i == 2) {
        spllitedBySpace = todaysTimingForAllAdhan.asr.split(" ");
      } else if (i == 3) {
        spllitedBySpace = todaysTimingForAllAdhan.maghrib.split(" ");
      } else {
        spllitedBySpace = todaysTimingForAllAdhan.isha.split(" ");
      }
      print("going to show notificaiton");

      var spllitedByColon = spllitedBySpace[0].split(":");
      hour = int.parse(spllitedByColon[0]);
      minute = int.parse(spllitedByColon[1]);
      print("${DateTime.now().hour} : ${DateTime.now().minute}");
      print("$hour : $minute");
      print(i);
      if (hour > DateTime.now().hour) {
        setOneShot = true;
      } else if (hour == DateTime.now().hour) {
        if (minute >= DateTime.now().minute) {
          setOneShot = true;
        }
      }
      if (setOneShot) {
        print("inside oneshot");

        DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, hour, minute, 00);
        await AndroidAlarmManager.oneShotAt(dateTime, i, _showNotification,
                allowWhileIdle: true)
            .then((v) {
          if (v) {
            print("set oneshot properly");
          }
        });
      }
    } else if (value.alarmEvent == AlarmEvent.CANCEL) {
      try {
        await AndroidAlarmManager.cancel(value.data['id']);
        // flutterLocalNotificationsPlugin.cancel(value.data['id']);
      } catch (e) {
        print(e);
      }
    }
  });
}

Future<List<bool>> retrieveAlarmStatusList() async {
  var list = <bool>[];
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  for (int i = 0; i < listOfAlarmIds.length; i++) {
    if (!sharedPreferences.containsKey(getAdhanName(i))) {
      await sharedPreferences.setBool(getAdhanName(i), false);
      list.add(false);
    } else {
      var value = sharedPreferences.getBool(getAdhanName(i));
      print("$i ${value.toString()}");
      list.add(value);
    }
  }
  return list;
}

_test(int i) {
  print("Testing $i");
}

_mainAlarm() async {
  print("inside the callback");

  var list = await retrieveAlarmStatusList();
  var sharedpref = await SharedPreferences.getInstance();
  var timings = "";

  if (sharedpref.containsKey(DateTime.now().month.toString())) {
    timings = sharedpref.getString(DateTime.now().month.toString());
    var listofTiming = timingFromJson(timings);
    for (int i = 0; i < list.length; i++) {
      if (list[i]) {
        var time = listofTiming[DateTime.now().day].date.gregorian;
        var todaysTimingForAllAdhan = listofTiming[DateTime.now().day].timings;
        int year = DateTime.now().year;
        int month = time.month.number;
        int day = int.parse(time.day);
        int hour, minute;
        var spllitedBySpace;
        if (i == 0) {
          spllitedBySpace = todaysTimingForAllAdhan.fajr.split(" ");
        } else if (i == 1) {
          spllitedBySpace = todaysTimingForAllAdhan.dhuhr.split(" ");
        } else if (i == 2) {
          spllitedBySpace = todaysTimingForAllAdhan.asr.split(" ");
        } else if (i == 3) {
          spllitedBySpace = todaysTimingForAllAdhan.maghrib.split(" ");
        } else {
          spllitedBySpace = todaysTimingForAllAdhan.isha.split(" ");
        }
        print("going to show notificaiton");

        var spllitedByColon = spllitedBySpace[0].split(":");
        hour = int.parse(spllitedByColon[0]);
        minute = int.parse(spllitedByColon[1]);
        print({
          "i": i,
          "year": year,
          "month": month,
          "day": day,
          "hour": hour,
          "minute": minute
        });
        // _scheduleNotification(DateTime(year, month, day, hour, minute, 00));
        DateTime dateTime = DateTime(year, month, day, hour, minute, 00);
        AndroidAlarmManager.oneShotAt(
          dateTime,
          i,
          _showNotification,
          allowWhileIdle: true,
        );
        // await _showNotification();
      }
    }
  }
}

void callback() {
  print("callback");
}

Future<void> _showNotification(int i) async {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'adhan', 'Adhan Channel', 'Rings on Adhan',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(i, '${getAdhanName(i)} Adhan',
      'Time to get ready for prayer', platformChannelSpecifics,
      payload: 'item x');
}

Future<void> onSelectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: ' + payload);
  }

  // await Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => Container()),
  // );
}

Future<void> onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  // await showDialog(
  //   context: context,
  //   builder: (BuildContext context) => CupertinoAlertDialog(
  //     title: Text(title),
  //     content: Text(body),
  //     actions: [
  //       CupertinoDialogAction(
  //         isDefaultAction: true,
  //         child: Text('Ok'),
  //         onPressed: () async {
  //           Navigator.of(context, rootNavigator: true).pop();
  //           await Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => Container(),
  //             ),
  //           );
  //         },
  //       )
  //     ],
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdhanPage(),
    );
  }
}

class AdhanPage extends StatefulWidget {
  @override
  _AdhanPageState createState() => _AdhanPageState();
}

class _AdhanPageState extends State<AdhanPage> {
  ApiProvider _apiProvider;
  TimeSaver _saver;

  AdhanStatusBloc _adhanStatusBloc;

  var timings = <Timing>[];
  @override
  void initState() {
    _apiProvider = ApiProvider();
    _saver = TimeSaver();
    _adhanStatusBloc = AdhanStatusBloc();
    // _saver.getTiming(0);

    // getValues();
    super.initState();
  }

  @override
  void dispose() {
    _adhanStatusBloc.dispose();
    super.dispose();
  }

  // Future<void> onSelectNotification(String payload) async {
  //   if (payload != null) {
  //     debugPrint('notification payload: ' + payload);
  //   }

  //   await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => Container()),
  //   );
  // }

  // Future<void> onDidReceiveLocalNotification(
  //     int id, String title, String body, String payload) async {
  //   // display a dialog with the notification details, tap ok to go to another page
  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) => CupertinoAlertDialog(
  //       title: Text(title),
  //       content: Text(body),
  //       actions: [
  //         CupertinoDialogAction(
  //           isDefaultAction: true,
  //           child: Text('Ok'),
  //           onPressed: () async {
  //             Navigator.of(context, rootNavigator: true).pop();
  //             await Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => Container(),
  //               ),
  //             );
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }

  // getValues() async {
  //   var values = await _saver.getTiming(0);
  //   print("lalla");
  //   setState(() {
  //     timings = values;
  //     print(timings[0].timings.sunrise);
  //   });
  // }

  Future<List<Timing>> getTiming() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String result = prefs.getString("0");
      return timingFromJson(result);
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<bool>>(
          stream: _adhanStatusBloc.outputtr,
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data.length > 0) {
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return SwitchListTile(
                      onChanged: (bool value) async {
                        print("pressed swtich");
                        await _adhanStatusBloc.updateValue(index);
                      },
                      value: snapshot.data[index],
                      title: Text(
                        getAdhanName(index),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          }),
    );
  }
}
