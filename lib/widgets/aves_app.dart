import 'dart:ui';

import 'package:aves/app_mode.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/media_store_source.dart';
import 'package:aves/services/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/behaviour/route_tracker.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/highlight_info_provider.dart';
import 'package:aves/widgets/home_page.dart';
import 'package:aves/widgets/welcome_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

class AvesApp extends StatefulWidget {
  @override
  _AvesAppState createState() => _AvesAppState();
}

class _AvesAppState extends State<AvesApp> {
  final ValueNotifier<AppMode> appModeNotifier = ValueNotifier(AppMode.main);
  late Future<void> _appSetup;
  final _mediaStoreSource = MediaStoreSource();
  final Debouncer _contentChangeDebouncer = Debouncer(delay: Durations.contentChangeDebounceDelay);
  final Set<String> changedUris = {};

  // observers are not registered when using the same list object with different items
  // the list itself needs to be reassigned
  List<NavigatorObserver> _navigatorObservers = [];
  final EventChannel _contentChangeChannel = EventChannel('deckers.thibault/aves/contentchange');
  final EventChannel _newIntentChannel = EventChannel('deckers.thibault/aves/intent');
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey(debugLabel: 'app-navigator');

  Widget getFirstPage({Map? intentData}) => settings.hasAcceptedTerms ? HomePage(intentData: intentData) : WelcomePage();

  @override
  void initState() {
    super.initState();
    initPlatformServices();
    _appSetup = _setup();
    _contentChangeChannel.receiveBroadcastStream().listen((event) => _onContentChange(event as String?));
    _newIntentChannel.receiveBroadcastStream().listen((event) => _onNewIntent(event as Map?));
  }

  @override
  Widget build(BuildContext context) {
    // place the settings provider above `MaterialApp`
    // so it can be used during navigation transitions
    return ChangeNotifierProvider<Settings>.value(
      value: settings,
      child: ListenableProvider<ValueNotifier<AppMode>>.value(
        value: appModeNotifier,
        child: Provider<CollectionSource>.value(
          value: _mediaStoreSource,
          child: HighlightInfoProvider(
            child: OverlaySupport(
              child: FutureBuilder<void>(
                future: _appSetup,
                builder: (context, snapshot) {
                  final initialized = !snapshot.hasError && snapshot.connectionState == ConnectionState.done;
                  final home = initialized
                      ? getFirstPage()
                      : Scaffold(
                          body: snapshot.hasError ? _buildError(snapshot.error!) : SizedBox(),
                        );
                  return Selector<Settings, Locale?>(
                      selector: (context, s) => s.locale,
                      builder: (context, settingsLocale, child) {
                        return MaterialApp(
                          navigatorKey: _navigatorKey,
                          home: home,
                          navigatorObservers: _navigatorObservers,
                          onGenerateTitle: (context) => context.l10n.appName,
                          darkTheme: Themes.darkTheme,
                          themeMode: ThemeMode.dark,
                          locale: settingsLocale,
                          localizationsDelegates: [
                            ...AppLocalizations.localizationsDelegates,
                          ],
                          supportedLocales: AppLocalizations.supportedLocales,
                          // checkerboardRasterCacheImages: true,
                          // checkerboardOffscreenLayers: true,
                        );
                      });
                },
              ),
            ),
          ),
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

  void _onNewIntent(Map? intentData) {
    debugPrint('$runtimeType onNewIntent with intentData=$intentData');

    // do not reset when relaunching the app
    if (appModeNotifier.value == AppMode.main && (intentData == null || intentData.isEmpty == true)) return;

    FirebaseCrashlytics.instance.log('New intent');
    _navigatorKey.currentState!.pushReplacement(DirectMaterialPageRoute(
      settings: RouteSettings(name: HomePage.routeName),
      builder: (_) => getFirstPage(intentData: intentData),
    ));
  }

  void _onContentChange(String? uri) {
    if (uri != null) changedUris.add(uri);
    if (changedUris.isNotEmpty) {
      _contentChangeDebouncer(() async {
        final todo = changedUris.toSet();
        changedUris.clear();
        final tempUris = await _mediaStoreSource.refreshUris(todo);
        if (tempUris.isNotEmpty) {
          changedUris.addAll(tempUris);
          _onContentChange(null);
        }
      });
    }
  }
}
