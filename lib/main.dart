import 'dart:isolate';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/data_providers/settings_provider.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/home_page.dart';
import 'package:aves/widgets/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
//  HttpClient.enableTimelineLogging = true; // enable network traffic logging
//  debugPrintGestureArenaDiagnostics = true;

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);

  runApp(AvesApp());
}

enum AppMode { main, pick, view }

class AvesApp extends StatefulWidget {
  static AppMode mode = AppMode.main;

  @override
  _AvesAppState createState() => _AvesAppState();
}

class _AvesAppState extends State<AvesApp> {
  Future<void> _appSetup;

  static const accentColor = Colors.indigoAccent;

  @override
  void initState() {
    super.initState();
    _appSetup = _setup();
  }

  Future<void> _setup() async {
    await Firebase.initializeApp().then((app) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      FirebaseCrashlytics.instance.setCustomKey(
          'build_mode',
          kReleaseMode
              ? 'release'
              : kProfileMode
                  ? 'profile'
                  : 'debug');
    });
    await settings.init();
  }

  @override
  Widget build(BuildContext context) {
    // place the settings provider above `MaterialApp`
    // so it can be used during navigation transitions
    return SettingsProvider(
      child: OverlaySupport(
        child: MaterialApp(
          title: 'Aves',
          theme: ThemeData(
            brightness: Brightness.dark,
            accentColor: accentColor,
            scaffoldBackgroundColor: Colors.grey[900],
            buttonColor: accentColor,
            toggleableActiveColor: accentColor,
            tooltipTheme: TooltipThemeData(
              verticalOffset: 32,
            ),
            appBarTheme: AppBarTheme(
              textTheme: TextTheme(
                headline6: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Concourse Caps',
                ),
              ),
            ),
          ),
          home: FutureBuilder<void>(
            future: _appSetup,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Column(
                  children: [
                    Icon(AIcons.error),
                    Text(snapshot.error),
                  ],
                );
              }
              if (snapshot.connectionState != ConnectionState.done) return Scaffold();
              return settings.hasAcceptedTerms ? HomePage() : WelcomePage();
            },
          ),
        ),
      ),
    );
  }
}
