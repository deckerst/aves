import 'dart:isolate';
import 'dart:ui';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/route_tracker.dart';
import 'package:aves/widgets/common/data_providers/settings_provider.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/routes.dart';
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
  static AppMode mode;

  @override
  _AvesAppState createState() => _AvesAppState();
}

class _AvesAppState extends State<AvesApp> {
  Future<void> _appSetup;
  final NavigatorObserver _routeTracker = CrashlyticsRouteTracker();
  final _newIntentChannel = EventChannel('deckers.thibault/aves/intent');
  final _navigatorKey = GlobalKey<NavigatorState>();

  static const accentColor = Colors.indigoAccent;

  static final darkTheme = ThemeData(
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
  );

  Widget get firstPage => settings.hasAcceptedTerms ? HomePage() : WelcomePage();

  @override
  void initState() {
    super.initState();
    _appSetup = _setup();
    _newIntentChannel.receiveBroadcastStream().listen((_) => _onNewIntent());
  }

  Future<void> _setup() async {
    await Firebase.initializeApp().then((app) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      FirebaseCrashlytics.instance.setCustomKey('locales', window.locales.join(', '));
      final now = DateTime.now();
      FirebaseCrashlytics.instance.setCustomKey('timezone', '${now.timeZoneName} (${now.timeZoneOffset})');
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

  void _onNewIntent() {
    FirebaseCrashlytics.instance.log('New intent');
    _navigatorKey.currentState.pushReplacement(DirectMaterialPageRoute(
      settings: RouteSettings(name: HomePage.routeName),
      builder: (_) => firstPage,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // place the settings provider above `MaterialApp`
    // so it can be used during navigation transitions
    final home = FutureBuilder<void>(
      future: _appSetup,
      builder: (context, snapshot) {
        if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
          return firstPage;
        }
        return Scaffold(
          body: snapshot.hasError ? _buildError(snapshot.error) : SizedBox.shrink(),
        );
      },
    );
    return SettingsProvider(
      child: OverlaySupport(
        child: FutureBuilder<void>(
          future: _appSetup,
          builder: (context, snapshot) {
            return MaterialApp(
              navigatorKey: _navigatorKey,
              home: home,
              navigatorObservers: [
                if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done) _routeTracker,
              ],
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
