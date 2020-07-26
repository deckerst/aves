import 'package:aves/model/settings.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/home_page.dart';
import 'package:aves/widgets/welcome_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
//  HttpClient.enableTimelineLogging = true; // enable network traffic logging
//  debugPrintGestureArenaDiagnostics = true;
  Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = Crashlytics.instance.recordFlutterError;
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
    _appSetup = settings.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          if (snapshot.hasError) return Icon(AIcons.error);
          if (snapshot.connectionState != ConnectionState.done) return Scaffold();
          return settings.hasAcceptedTerms ? HomePage() : WelcomePage();
        },
      ),
    );
  }
}
