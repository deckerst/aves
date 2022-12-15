import 'dart:async';
import 'dart:ui';

import 'package:aves/app_flavor.dart';
import 'package:aves/app_mode.dart';
import 'package:aves/l10n/l10n.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/filters/recent.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/enums/display_refresh_rate_mode.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/screen_on.dart';
import 'package:aves/model/settings/enums/theme_brightness.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/media_store_source.dart';
import 'package:aves/services/accessibility_service.dart';
import 'package:aves/services/common/optional_event_channel.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/collection/collection_grid.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/behaviour/route_tracker.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/highlight_info_provider.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/home_page.dart';
import 'package:aves/widgets/navigation/tv_page_transitions.dart';
import 'package:aves/widgets/navigation/tv_rail.dart';
import 'package:aves/widgets/welcome_page.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:equatable/equatable.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class AvesApp extends StatefulWidget {
  final AppFlavor flavor;

  // temporary exclude locales not ready yet for prime time
  static final _unsupportedLocales = {'ar', 'fa', 'gl', 'nn', 'pl', 'th', 'uk'}.map(Locale.new).toSet();
  static final List<Locale> supportedLocales = AppLocalizations.supportedLocales.where((v) => !_unsupportedLocales.contains(v)).toList();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: 'app-navigator');

  // do not monitor all `ModalRoute`s, which would include popup menus,
  // so that we can react to fullscreen `PageRoute`s only
  static final RouteObserver<PageRoute> pageRouteObserver = RouteObserver<PageRoute>();

  const AvesApp({
    super.key,
    required this.flavor,
  });

  @override
  State<AvesApp> createState() => _AvesAppState();

  static void setSystemUIStyle(BuildContext context) {
    final theme = Theme.of(context);
    final style = systemUIStyleForBrightness(theme.brightness, theme.scaffoldBackgroundColor);
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  static SystemUiOverlayStyle systemUIStyleForBrightness(Brightness themeBrightness, Color scaffoldBackgroundColor) {
    final barBrightness = themeBrightness == Brightness.light ? Brightness.dark : Brightness.light;
    const statusBarColor = Colors.transparent;
    // as of Flutter v3.3.0-0.2.pre, setting `SystemUiOverlayStyle` (whether manually or automatically because of `AppBar`)
    // prevents the canvas from drawing behind the nav bar on Android <10 (API <29),
    // so the nav bar is opaque, even when requesting `SystemUiMode.edgeToEdge` from Flutter
    // or setting `android:windowTranslucentNavigation` in Android themes.
    final navBarColor = device.supportEdgeToEdgeUIMode ? Colors.transparent : scaffoldBackgroundColor;
    return SystemUiOverlayStyle(
      systemNavigationBarColor: navBarColor,
      systemNavigationBarDividerColor: navBarColor,
      systemNavigationBarIconBrightness: barBrightness,
      // shows background scrim when using navigation buttons, but not when using gesture navigation
      systemNavigationBarContrastEnforced: true,
      statusBarColor: statusBarColor,
      statusBarBrightness: barBrightness,
      statusBarIconBrightness: barBrightness,
      systemStatusBarContrastEnforced: false,
    );
  }

  static Future<void> showSystemUI() async {
    if (device.supportEdgeToEdgeUIMode) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
  }

  static Future<void> hideSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  static Future<void> launchUrl(String? urlString) async {
    if (urlString != null) {
      final url = Uri.parse(urlString);
      if (await ul.canLaunchUrl(url)) {
        try {
          await ul.launchUrl(url, mode: device.isTelevision ? ul.LaunchMode.inAppWebView : ul.LaunchMode.externalApplication);
        } catch (error, stack) {
          debugPrint('failed to open url=$urlString with error=$error\n$stack');
        }
      }
    }
  }
}

class _AvesAppState extends State<AvesApp> with WidgetsBindingObserver {
  final List<StreamSubscription> _subscriptions = [];
  late final Future<void> _appSetup;
  late final Future<bool> _shouldUseBoldFontLoader;
  late final Future<CorePalette?> _dynamicColorPaletteLoader;
  final TvRailController _tvRailController = TvRailController();
  final CollectionSource _mediaStoreSource = MediaStoreSource();
  final Debouncer _mediaStoreChangeDebouncer = Debouncer(delay: Durations.mediaContentChangeDebounceDelay);
  final Set<String> _changedUris = {};
  Size? _screenSize;

  // Flutter has various page transition implementations for Android:
  // - `FadeUpwardsPageTransitionsBuilder` on Oreo / API 27 and below
  // - `OpenUpwardsPageTransitionsBuilder` on Pie / API 28
  // - `ZoomPageTransitionsBuilder` on Android 10 / API 29 and above (default in Flutter v3.0.0)
  final ValueNotifier<PageTransitionsBuilder> _pageTransitionsBuilderNotifier = ValueNotifier(const FadeUpwardsPageTransitionsBuilder());
  final ValueNotifier<NavigationMode> _navigationModeNotifier = ValueNotifier(NavigationMode.traditional);
  final ValueNotifier<AppMode> _appModeNotifier = ValueNotifier(AppMode.main);

  // observers are not registered when using the same list object with different items
  // the list itself needs to be reassigned
  List<NavigatorObserver> _navigatorObservers = [AvesApp.pageRouteObserver];
  final EventChannel _mediaStoreChangeChannel = const OptionalEventChannel('deckers.thibault/aves/media_store_change');
  final EventChannel _newIntentChannel = const OptionalEventChannel('deckers.thibault/aves/new_intent_stream');
  final EventChannel _analysisCompletionChannel = const OptionalEventChannel('deckers.thibault/aves/analysis_events');
  final EventChannel _errorChannel = const OptionalEventChannel('deckers.thibault/aves/error');

  @override
  void initState() {
    super.initState();
    EquatableConfig.stringify = true;
    _appSetup = _setup();
    // remember screen size to use it later, when `context` and `window` are no longer reliable
    _screenSize = _getScreenSize();
    _shouldUseBoldFontLoader = AccessibilityService.shouldUseBoldFont();
    _dynamicColorPaletteLoader = DynamicColorPlugin.getCorePalette();
    _subscriptions.add(_mediaStoreChangeChannel.receiveBroadcastStream().listen((event) => _onMediaStoreChanged(event as String?)));
    _subscriptions.add(_newIntentChannel.receiveBroadcastStream().listen((event) => _onNewIntent(event as Map?)));
    _subscriptions.add(_analysisCompletionChannel.receiveBroadcastStream().listen((event) => _onAnalysisCompletion()));
    _subscriptions.add(_errorChannel.receiveBroadcastStream().listen((event) => _onError(event as String?)));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _pageTransitionsBuilderNotifier.dispose();
    _navigationModeNotifier.dispose();
    _appModeNotifier.dispose();
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // place the settings provider above `MaterialApp`
    // so it can be used during navigation transitions
    return Provider<AppFlavor>.value(
      value: widget.flavor,
      child: ChangeNotifierProvider<Settings>.value(
        value: settings,
        child: ListenableProvider<ValueNotifier<AppMode>>.value(
          value: _appModeNotifier,
          child: Provider<CollectionSource>.value(
            value: _mediaStoreSource,
            child: Provider<TvRailController>.value(
              value: _tvRailController,
              child: DurationsProvider(
                child: HighlightInfoProvider(
                  child: OverlaySupport(
                    child: FutureBuilder<void>(
                      future: _appSetup,
                      builder: (context, snapshot) {
                        final initialized = !snapshot.hasError && snapshot.connectionState == ConnectionState.done;
                        if (initialized) {
                          AvesApp.showSystemUI();
                        }
                        final home = initialized
                            ? _getFirstPage()
                            : Scaffold(
                                body: snapshot.hasError ? _buildError(snapshot.error!) : const SizedBox(),
                              );
                        return Selector<Settings, Tuple3<Locale?, AvesThemeBrightness, bool>>(
                          selector: (context, s) => Tuple3(
                            s.locale,
                            s.initialized ? s.themeBrightness : SettingsDefaults.themeBrightness,
                            s.initialized ? s.enableDynamicColor : SettingsDefaults.enableDynamicColor,
                          ),
                          builder: (context, s, child) {
                            final settingsLocale = s.item1;
                            final themeBrightness = s.item2;
                            final enableDynamicColor = s.item3;

                            Constants.updateStylesForLocale(settings.appliedLocale);

                            return FutureBuilder<CorePalette?>(
                              future: _dynamicColorPaletteLoader,
                              builder: (context, snapshot) {
                                const defaultAccent = Themes.defaultAccent;
                                Color lightAccent = defaultAccent, darkAccent = defaultAccent;
                                if (enableDynamicColor) {
                                  // `DynamicColorBuilder` from package `dynamic_color` provides light/dark
                                  // palettes with a primary color from tones too dark/light (40/80),
                                  // so we derive the color with adjusted tones (60/70)
                                  final tonalPalette = snapshot.data?.primary;
                                  lightAccent = Color(tonalPalette?.get(60) ?? defaultAccent.value);
                                  darkAccent = Color(tonalPalette?.get(70) ?? defaultAccent.value);
                                }
                                final lightTheme = Themes.lightTheme(lightAccent, initialized);
                                final darkTheme = themeBrightness == AvesThemeBrightness.black ? Themes.blackTheme(darkAccent, initialized) : Themes.darkTheme(darkAccent, initialized);
                                return Shortcuts(
                                  shortcuts: <LogicalKeySet, Intent>{
                                    // handle Android TV remote `select` button
                                    LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                                  },
                                  child: MaterialApp(
                                    navigatorKey: AvesApp.navigatorKey,
                                    home: home,
                                    navigatorObservers: _navigatorObservers,
                                    builder: (context, child) => _decorateAppChild(
                                      context: context,
                                      initialized: initialized,
                                      child: child,
                                    ),
                                    onGenerateTitle: (context) => context.l10n.appName,
                                    theme: lightTheme,
                                    darkTheme: darkTheme,
                                    themeMode: themeBrightness.appThemeMode,
                                    locale: settingsLocale,
                                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                                    supportedLocales: AvesApp.supportedLocales,
                                    // TODO TLAD remove custom scroll behavior when this is fixed: https://github.com/flutter/flutter/issues/82906
                                    scrollBehavior: StretchMaterialScrollBehavior(),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _decorateAppChild({
    required BuildContext context,
    required bool initialized,
    required Widget? child,
  }) {
    if (initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) => AvesApp.setSystemUIStyle(context));
    }
    return Selector<Settings, bool>(
      selector: (context, s) => s.initialized ? s.accessibilityAnimations.animate : true,
      builder: (context, areAnimationsEnabled, child) {
        return FutureBuilder<bool>(
          future: _shouldUseBoldFontLoader,
          builder: (context, snapshot) {
            // Flutter v3.4 already checks the system `Configuration.fontWeightAdjustment` to update `MediaQuery`
            // but we need to also check the non-standard Samsung field `bf` representing the bold font toggle
            final shouldUseBoldFont = snapshot.data ?? false;
            return ValueListenableBuilder<NavigationMode>(
              valueListenable: _navigationModeNotifier,
              builder: (context, navigationMode, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    boldText: shouldUseBoldFont,
                    navigationMode: navigationMode,
                  ),
                  child: AvesColorsProvider(
                    child: ValueListenableBuilder<PageTransitionsBuilder>(
                      valueListenable: _pageTransitionsBuilderNotifier,
                      builder: (context, pageTransitionsBuilder, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            pageTransitionsTheme: areAnimationsEnabled
                                ? PageTransitionsTheme(builders: {TargetPlatform.android: pageTransitionsBuilder})
                                // strip page transitions used by `MaterialPageRoute`
                                : const DirectPageTransitionsTheme(),
                          ),
                          child: MediaQueryDataProvider(child: child!),
                        );
                      },
                      child: child,
                    ),
                  ),
                );
              },
              child: child,
            );
          },
        );
      },
      child: child,
    );
  }

  Widget _buildError(Object error) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AIcons.error),
          const SizedBox(height: 16),
          Text(error.toString()),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('$runtimeType lifecycle ${state.name}');
    switch (state) {
      case AppLifecycleState.inactive:
        switch (_appModeNotifier.value) {
          case AppMode.main:
          case AppMode.pickSingleMediaExternal:
          case AppMode.pickMultipleMediaExternal:
            _saveTopEntries();
            break;
          case AppMode.pickCollectionFiltersExternal:
          case AppMode.pickMediaInternal:
          case AppMode.pickFilterInternal:
          case AppMode.screenSaver:
          case AppMode.setWallpaper:
          case AppMode.slideshow:
          case AppMode.view:
            break;
        }
        break;
      case AppLifecycleState.resumed:
        RecentlyAddedFilter.updateNow();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  Widget _getFirstPage({Map? intentData}) => settings.hasAcceptedTerms ? HomePage(intentData: intentData) : const WelcomePage();

  Size? _getScreenSize() {
    final physicalSize = window.physicalSize;
    final ratio = window.devicePixelRatio;
    return physicalSize > Size.zero && ratio > 0 ? physicalSize / ratio : null;
  }

  // save IDs of entries visible at the top of the collection page with current layout settings
  void _saveTopEntries() {
    if (!settings.initialized) return;

    final screenSize = _screenSize ?? _getScreenSize();
    if (screenSize == null) return;

    var tileExtent = settings.getTileExtent(CollectionPage.routeName);
    if (tileExtent == 0) {
      tileExtent = screenSize.shortestSide / CollectionGrid.columnCountDefault;
    }
    final rows = (screenSize.height / tileExtent).ceil();
    final columns = (screenSize.width / tileExtent).ceil();
    final count = rows * columns;
    final collection = CollectionLens(source: _mediaStoreSource, listenToSource: false);
    settings.topEntryIds = collection.sortedEntries.take(count).map((entry) => entry.id).toList();
    collection.dispose();
  }

  // setup before the first page is displayed. keep it short
  Future<void> _setup() async {
    final stopwatch = Stopwatch()..start();

    await device.init();
    if (device.isTelevision) {
      _pageTransitionsBuilderNotifier.value = const TvPageTransitionsBuilder();
      _navigationModeNotifier.value = NavigationMode.directional;
    }
    await mobileServices.init();
    await settings.init(monitorPlatformSettings: true);
    settings.isRotationLocked = await windowService.isRotationLocked();
    settings.areAnimationsRemoved = await AccessibilityService.areAnimationsRemoved();
    _monitorSettings();

    FijkLog.setLevel(FijkLogLevel.Warn);
    unawaited(_setupErrorReporting());

    debugPrint('App setup in ${stopwatch.elapsed.inMilliseconds}ms');
  }

  void _monitorSettings() {
    void applyIsInstalledAppAccessAllowed() {
      if (settings.isInstalledAppAccessAllowed) {
        androidFileUtils.initAppNames();
      } else {
        androidFileUtils.resetAppNames();
      }
    }

    void applyDisplayRefreshRateMode() => settings.displayRefreshRateMode.apply();
    void applyKeepScreenOn() => settings.keepScreenOn.apply();

    void applyIsRotationLocked() {
      if (!settings.isRotationLocked) {
        windowService.requestOrientation();
      }
    }

    settings.updateStream.where((event) => event.key == Settings.isInstalledAppAccessAllowedKey).listen((_) => applyIsInstalledAppAccessAllowed());
    settings.updateStream.where((event) => event.key == Settings.displayRefreshRateModeKey).listen((_) => applyDisplayRefreshRateMode());
    settings.updateStream.where((event) => event.key == Settings.keepScreenOnKey).listen((_) => applyKeepScreenOn());
    settings.updateStream.where((event) => event.key == Settings.platformAccelerometerRotationKey).listen((_) => applyIsRotationLocked());

    applyDisplayRefreshRateMode();
    applyKeepScreenOn();
    applyIsRotationLocked();
  }

  Future<void> _setupErrorReporting() async {
    await reportService.init();
    settings.updateStream.where((event) => event.key == Settings.isErrorReportingAllowedKey).listen(
          (_) => reportService.setCollectionEnabled(settings.isErrorReportingAllowed),
        );
    await reportService.setCollectionEnabled(settings.isErrorReportingAllowed);

    FlutterError.onError = reportService.recordFlutterError;
    final now = DateTime.now();
    await reportService.setCustomKeys({
      'build_mode': kReleaseMode
          ? 'release'
          : kProfileMode
              ? 'profile'
              : 'debug',
      'has_mobile_services': mobileServices.isServiceAvailable,
      'locales': WidgetsBinding.instance.window.locales.join(', '),
      'time_zone': '${now.timeZoneName} (${now.timeZoneOffset})',
    });
    setState(() => _navigatorObservers = [
          AvesApp.pageRouteObserver,
          ReportingRouteTracker(),
        ]);
  }

  void _onNewIntent(Map? intentData) {
    debugPrint('$runtimeType onNewIntent with intentData=$intentData');

    // do not reset when relaunching the app
    if (_appModeNotifier.value == AppMode.main && (intentData == null || intentData.isEmpty == true)) return;

    reportService.log('New intent');
    AvesApp.navigatorKey.currentState!.pushReplacement(DirectMaterialPageRoute(
      settings: const RouteSettings(name: HomePage.routeName),
      builder: (_) => _getFirstPage(intentData: intentData),
    ));
  }

  Future<void> _onAnalysisCompletion() async {
    debugPrint('Analysis completed');
    await _mediaStoreSource.loadCatalogMetadata();
    await _mediaStoreSource.loadAddresses();
    _mediaStoreSource.updateDerivedFilters();
  }

  void _onMediaStoreChanged(String? uri) {
    if (uri != null) _changedUris.add(uri);
    if (_changedUris.isNotEmpty) {
      _mediaStoreChangeDebouncer(() async {
        final todo = _changedUris.toSet();
        _changedUris.clear();
        final tempUris = await _mediaStoreSource.refreshUris(todo);
        if (tempUris.isNotEmpty) {
          _changedUris.addAll(tempUris);
          _onMediaStoreChanged(null);
        }
      });
    }
  }

  void _onError(String? error) => reportService.recordError(error, null);
}

class StretchMaterialScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}
