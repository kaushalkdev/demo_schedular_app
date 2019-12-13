import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:background_fetch/background_fetch.dart';

void backgroundFetchHeadlessTask() async {
  print('[BackgroundFetch] Headless event received.');

  BackgroundFetch.finish();
}

void main() {
  runApp(new MaterialApp(
    home: MyApp(),
  ));

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int eventfiringDurationMinutes = 15;
  var selectedDate;
  @override
  void initState() {
    super.initState();
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
            BackgroundFetchConfig(
                minimumFetchInterval: eventfiringDurationMinutes,
                stopOnTerminate: false,
                startOnBoot: true,
                enableHeadless: true,
                requiresBatteryNotLow: false,
                requiresCharging: false,
                requiresStorageNotLow: false,
                requiresDeviceIdle: false,
                requiredNetworkType: BackgroundFetchConfig.NETWORK_TYPE_NONE),
            _onBackgroundFetch)
        .then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });

    if (!mounted) return;
  }

  void _onBackgroundFetch() async {
    print('[BackgroundFetch] Event received');

    BackgroundFetch.finish();
    Future.delayed(Duration(seconds: 20)).whenComplete(() {
      FlutterRingtonePlayer.stop();
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Scheduler App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onChanged: (date) {
                      print('change $date');
                    }, onConfirm: (date) {
                      if (DateTime.now().difference(date).inMinutes.abs() >
                          15) {
                        eventfiringDurationMinutes =
                            DateTime.now().difference(date).inMinutes.abs();
                        setState(() {});

                        initPlatformState();
                      } else {
                        return;
                      }

                      print(
                          "diff event firing in minutes: $eventfiringDurationMinutes");
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                  child: Text("Date Time Picker"))
            ],
          ),
        ));
  }
}
