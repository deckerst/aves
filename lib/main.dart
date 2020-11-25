import 'dart:isolate';
import 'dart:ui';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/behaviour/route_tracker.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/providers/settings_provider.dart';
import 'package:aves/widgets/home_page.dart';
import 'package:aves/widgets/welcome_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
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
  static AppMode mode;

  @override
  _AvesAppState createState() => _AvesAppState();
}

class _AvesAppState extends State<AvesApp> {
  Future<void> _appSetup;

  // observers are not registered when using the same list object with different items
  // the list itself needs to be reassigned
  List<NavigatorObserver> _navigatorObservers = [];
  final _newIntentChannel = EventChannel('deckers.thibault/aves/intent');
  final _navigatorKey = GlobalKey<NavigatorState>();

  static const accentColor = Colors.indigoAccent;

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    accentColor: accentColor,
    scaffoldBackgroundColor: Colors.grey[900],
    buttonColor: accentColor,
    dialogBackgroundColor: Colors.grey[850],
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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: accentColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        primary: accentColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.white,
      ),
    ),
  );

  Widget getFirstPage({Map intentData}) => settings.hasAcceptedTerms ? HomePage(intentData: intentData) : WelcomePage();

  @override
  void initState() {
    super.initState();
    _appSetup = _setup();
    _newIntentChannel.receiveBroadcastStream().listen((event) => _onNewIntent(event as Map));
  }

  Future<void> _setup() async {
    await Firebase.initializeApp().then((app) {
      final crashlytics = FirebaseCrashlytics.instance;
      FlutterError.onError = crashlytics.recordFlutterError;
      crashlytics.setCustomKey('locales', window.locales.join(', '));
      final now = DateTime.now();
      crashlytics.setCustomKey('timezone', '${now.timeZoneName} (${now.timeZoneOffset})');
      crashlytics.setCustomKey(
          'build_mode',
          kReleaseMode
              ? 'release'
              : kProfileMode
                  ? 'profile'
                  : 'debug');
    });
    await settings.init();
    await settings.initFirebase();
    _navigatorObservers = [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
      CrashlyticsRouteTracker(),
    ];
  }

  void _onNewIntent(Map intentData) {
    debugPrint('$runtimeType onNewIntent with intentData=$intentData');

    // do not reset when relaunching the app
    if (AvesApp.mode == AppMode.main && (intentData == null || intentData.isEmpty == true)) return;

    FirebaseCrashlytics.instance.log('New intent');
    _navigatorKey.currentState.pushReplacement(DirectMaterialPageRoute(
      settings: RouteSettings(name: HomePage.routeName),
      builder: (_) => getFirstPage(intentData: intentData),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // place the settings provider above `MaterialApp`
    // so it can be used during navigation transitions
    return SettingsProvider(
      child: OverlaySupport(
        child: FutureBuilder<void>(
          future: _appSetup,
          builder: (context, snapshot) {
            final home = (!snapshot.hasError && snapshot.connectionState == ConnectionState.done)
                ? getFirstPage()
                : Scaffold(
                    body: snapshot.hasError ? _buildError(snapshot.error) : SizedBox.shrink(),
                  );
            return MaterialApp(
              navigatorKey: _navigatorKey,
              home: home,
              navigatorObservers: _navigatorObservers,
              title: 'Aves',
              darkTheme: darkTheme,
              themeMode: ThemeMode.dark,
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AIcons.error),
          SizedBox(height: 16),
          Text(error.toString()),
        ],
      ),
    );
  }
}
