import 'dart:async';
import 'dart:math';

import 'package:aves/app_flavor.dart';
import 'package:aves/app_mode.dart';
import 'package:aves/l10n/l10n.dart';
import 'package:aves/model/apps.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/filters/recent.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/enums/display_refresh_rate_mode.dart';
import 'package:aves/model/settings/enums/screen_on.dart';
import 'package:aves/model/settings/enums/theme_brightness.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/media_store_source.dart';
import 'package:aves/services/accessibility_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/collection/collection_grid.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/route_tracker.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/durations_provider.dart';
import 'package:aves/widgets/common/providers/highlight_info_provider.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/home_page.dart';
import 'package:aves/widgets/navigation/tv_page_transitions.dart';
import 'package:aves/widgets/navigation/tv_rail.dart';
import 'package:aves/widgets/welcome_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization_nn/flutter_localization_nn.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class AvesApp extends StatefulWidget {
  final AppFlavor flavor;
  final Map? debugIntentData;

  // temporary exclude locales not ready yet for prime time
  // `ckb`: add `flutter_ckb_localization` and necessary app localization delegates when ready
  static final _unsupportedLocales = {
    'bn', // Bengali
    'ckb', // Kurdish (Central)
    'da', // Danish
    'fa', // Persian
    'fi', // Finnish
    'gl', // Galician
    'he', // Hebrew
    'hi', // Hindi
    'kn', // Kannada
    'ml', // Malayalam
    'my', // Burmese
    'or', // Odia
    'sat', // Santali
    'sl', // Slovenian
    'sv', // Swedish
    'th', // Thai
  }.map(Locale.new).toSet();
  static final List<Locale> supportedLocales = AppLocalizations.supportedLocales.where((v) => !_unsupportedLocales.contains(v)).toList();
  static final ValueNotifier<EdgeInsets> cutoutInsetsNotifier = ValueNotifier(EdgeInsets.zero);

  // children widgets registering as `WidgetsBinding` observers and implementing `didChangeAppLifecycleState`
  // do not receive events fast enough for time sensitive actions (like PiP when leaving by gesture to home)
  // so we use this notifier to propagate events as soon as received by the top widget `AvesApp`
  static final ValueNotifier<AppLifecycleState> lifecycleStateNotifier = ValueNotifier(AppLifecycleState.detached);

  // do not monitor all `ModalRoute`s, which would include popup menus,
  // so that we can react to fullscreen `PageRoute`s only
  static final RouteObserver<PageRoute> pageRouteObserver = RouteObserver<PageRoute>();

  const AvesApp({
    super.key,
    required this.flavor,
    this.debugIntentData,
  });

  @override
  State<AvesApp> createState() => _AvesAppState();

  static void setSystemUIStyle(ThemeData theme) {
    final style = systemUIStyleForBrightness(theme.brightness, theme.colorScheme.background);
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  static SystemUiOverlayStyle systemUIStyleForBrightness(Brightness themeBrightness, Color backgroundColor) {
    final barBrightness = themeBrightness == Brightness.light ? Brightness.dark : Brightness.light;
    const statusBarColor = Colors.transparent;
    // as of Flutter v3.3.0-0.2.pre, setting `SystemUiOverlayStyle` (whether manually or automatically because of `AppBar`)
    // prevents the canvas from drawing behind the nav bar on Android <10 (API <29),
    // so the nav bar is opaque, even when requesting `SystemUiMode.edgeToEdge` from Flutter
    // or setting `android:windowTranslucentNavigation` in Android themes.
    final navBarColor = device.supportEdgeToEdgeUIMode ? Colors.transparent : backgroundColor;
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
        // address `TV-WB` requirement from https://developer.android.com/docs/quality-guidelines/tv-app-quality
        final mode = device.isTelevision ? ul.LaunchMode.inAppWebView : ul.LaunchMode.externalApplication;
        try {
          await ul.launchUrl(url, mode: mode);
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
  final TvRailController _tvRailController = TvRailController();
  final MediaStoreSource _mediaStoreSource = MediaStoreSource();
  Size? _screenSize;

  final ValueNotifier<PageTransitionsBuilder> _pageTransitionsBuilderNotifier = ValueNotifier(defaultPageTransitionsBuilder);
  final ValueNotifier<TvMediaQueryModifier?> _tvMediaQueryModifierNotifier = ValueNotifier(null);
  final ValueNotifier<AppMode> _appModeNotifier = ValueNotifier(AppMode.main);

  // observers are not registered when using the same list object with different items
  // the list itself needs to be reassigned
  List<NavigatorObserver> _navigatorObservers = [AvesApp.pageRouteObserver];
  final EventChannel _mediaStoreChangeChannel = const OptionalEventChannel('deckers.thibault/aves/media_store_change');
  final EventChannel _newIntentChannel = const OptionalEventChannel('deckers.thibault/aves/new_intent_stream');
  final EventChannel _analysisCompletionChannel = const OptionalEventChannel('deckers.thibault/aves/analysis_events');
  final EventChannel _errorChannel = const OptionalEventChannel('deckers.thibault/aves/error');

  // Flutter has various page transition implementations for Android:
  // - `FadeUpwardsPageTransitionsBuilder` on Oreo / API 27 and below
  // - `OpenUpwardsPageTransitionsBuilder` on Pie / API 28
  // - `ZoomPageTransitionsBuilder` on Android 10 / API 29 and above (default in Flutter v3.0.0)
  static const defaultPageTransitionsBuilder = FadeUpwardsPageTransitionsBuilder();
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey(debugLabel: 'app-navigator');

  @override
  void initState() {
    super.initState();
    EquatableConfig.stringify = true;
    _appSetup = _setup();
    _shouldUseBoldFontLoader = AccessibilityService.shouldUseBoldFont();
    _subscriptions.add(_mediaStoreChangeChannel.receiveBroadcastStream().listen((event) => _mediaStoreSource.onStoreChanged(event as String?)));
    _subscriptions.add(_newIntentChannel.receiveBroadcastStream().listen((event) => _onNewIntent(event as Map?)));
    _subscriptions.add(_analysisCompletionChannel.receiveBroadcastStream().listen((event) => _onAnalysisCompletion()));
    _subscriptions.add(_errorChannel.receiveBroadcastStream().listen((event) => _onError(event as String?)));
    _updateCutoutInsets();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    WidgetsBinding.instance.removeObserver(this);
    _pageTransitionsBuilderNotifier.dispose();
    _tvMediaQueryModifierNotifier.dispose();
    _appModeNotifier.dispose();
    _mediaStoreSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // remember screen size to use it later, when `context` and `window` are no longer reliable
    _screenSize ??= _getScreenSize(context);

    // place the settings provider above `MaterialApp`
    // so it can be used during navigation transitions
    return MultiProvider(
      providers: [
        Provider<AppFlavor>.value(value: widget.flavor),
        ChangeNotifierProvider<Settings>.value(value: settings),
        ListenableProvider<ValueNotifier<AppMode>>.value(value: _appModeNotifier),
        Provider<CollectionSource>.value(value: _mediaStoreSource),
        Provider<TvRailController>.value(value: _tvRailController),
        DurationsProvider(),
        HighlightInfoProvider(),
      ],
      child: OverlaySupport(
        child: FutureBuilder<void>(
          future: _appSetup,
          builder: (context, snapshot) {
            final initialized = !snapshot.hasError && snapshot.connectionState == ConnectionState.done;
            if (initialized) {
              AvesApp.showSystemUI();
            }
            final home = initialized
                ? _getFirstPage(intentData: widget.debugIntentData)
                : AvesScaffold(
                    body: snapshot.hasError ? _buildError(snapshot.error!) : const SizedBox(),
                  );
            return Selector<Settings, (Locale?, AvesThemeBrightness, bool)>(
              selector: (context, s) => (
                s.locale,
                s.initialized ? s.themeBrightness : SettingsDefaults.themeBrightness,
                s.initialized ? s.enableDynamicColor : SettingsDefaults.enableDynamicColor,
              ),
              builder: (context, s, child) {
                final (settingsLocale, themeBrightness, enableDynamicColor) = s;

                AStyles.updateStylesForLocale(settings.appliedLocale);

                return DynamicColorBuilder(
                  builder: (lightScheme, darkScheme) {
                    const defaultAccent = AvesColorsData.defaultAccent;
                    Color lightAccent = defaultAccent, darkAccent = defaultAccent;
                    if (enableDynamicColor) {
                      lightAccent = lightScheme?.primary ?? lightAccent;
                      darkAccent = darkScheme?.primary ?? darkAccent;
                    }
                    final lightTheme = Themes.lightTheme(lightAccent, initialized);
                    final darkTheme = themeBrightness == AvesThemeBrightness.black ? Themes.blackTheme(darkAccent, initialized) : Themes.darkTheme(darkAccent, initialized);
                    return Shortcuts(
                      shortcuts: {
                        // handle Android TV remote `select` button (KEYCODE_DPAD_CENTER)
                        // the following keys are already handled by default:
                        // KEYCODE_ENTER, KEYCODE_BUTTON_A, KEYCODE_NUMPAD_ENTER
                        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
                      },
                      child: Builder(
                        builder: (context) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              // disable accessible navigation, as it impacts snack bar action timer
                              // for all users of apps registered as accessibility services,
                              // even though they are not for accessibility purposes (like TalkBack is)
                              accessibleNavigation: false,
                            ),
                            child: MaterialApp(
                              navigatorKey: _navigatorKey,
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
                              localizationsDelegates: const [
                                ...AppLocalizations.localizationsDelegates,
                                ...LocalizationsNn.delegates,
                              ],
                              supportedLocales: AvesApp.supportedLocales,
                              scrollBehavior: AvesScrollBehavior(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
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
      WidgetsBinding.instance.addPostFrameCallback((_) => AvesApp.setSystemUIStyle(Theme.of(context)));
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
            final mq = MediaQuery.of(context).copyWith(
              boldText: shouldUseBoldFont,
            );
            return ValueListenableBuilder<TvMediaQueryModifier?>(
              valueListenable: _tvMediaQueryModifierNotifier,
              builder: (context, modifier, child) {
                return MediaQuery(
                  data: modifier?.call(mq) ?? mq,
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
    reportService.log('Lifecycle ${state.name}');
    AvesApp.lifecycleStateNotifier.value = state;
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
          case AppMode.edit:
            break;
        }
      case AppLifecycleState.resumed:
        RecentlyAddedFilter.updateNow();
        _mediaStoreSource.checkForChanges();
        break;
      default:
        break;
    }
  }

  @override
  void didChangeMetrics() => _updateCutoutInsets();

  Future<void> _updateCutoutInsets() async {
    if (await windowService.isCutoutAware()) {
      AvesApp.cutoutInsetsNotifier.value = await windowService.getCutoutInsets();
    }
  }

  Widget _getFirstPage({Map? intentData}) => settings.hasAcceptedTerms ? HomePage(intentData: intentData) : const WelcomePage();

  Size? _getScreenSize(BuildContext context) {
    final view = View.of(context);
    final physicalSize = view.physicalSize;
    final ratio = view.devicePixelRatio;
    return physicalSize > Size.zero && ratio > 0 ? physicalSize / ratio : null;
  }

  // save IDs of entries visible at the top of the collection page with current layout settings
  void _saveTopEntries() {
    if (!settings.initialized) return;

    final screenSize = _screenSize;
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
    await mobileServices.init();
    await settings.init(monitorPlatformSettings: true);
    settings.isRotationLocked = await windowService.isRotationLocked();
    settings.areAnimationsRemoved = await AccessibilityService.areAnimationsRemoved();
    await _onTvLayoutChanged();
    _monitorSettings();
    videoControllerFactory.init();

    unawaited(storageService.deleteTempDirectory());
    unawaited(_setupErrorReporting());

    debugPrint('App setup in ${stopwatch.elapsed.inMilliseconds}ms');
  }

  Future<void> _onTvLayoutChanged() async {
    if (settings.useTvLayout) {
      settings.applyTvSettings();

      _pageTransitionsBuilderNotifier.value = const TvPageTransitionsBuilder();
      _tvMediaQueryModifierNotifier.value = (mq) {
        // cf https://developer.android.com/training/tv/start/layouts.html#overscan
        final screenSize = mq.size;
        const overscanFactor = .05;
        final overscanInsets = EdgeInsets.symmetric(
          vertical: screenSize.shortestSide * overscanFactor,
          horizontal: screenSize.longestSide * overscanFactor,
        );
        final oldViewPadding = mq.viewPadding;
        final newViewPadding = EdgeInsets.only(
          top: max(oldViewPadding.top, overscanInsets.top),
          right: max(oldViewPadding.right, overscanInsets.right),
          bottom: max(oldViewPadding.bottom, overscanInsets.bottom),
          left: max(oldViewPadding.left, overscanInsets.left),
        );
        var newPadding = newViewPadding - mq.viewInsets;
        newPadding = EdgeInsets.only(
          top: max(0.0, newPadding.top),
          right: max(0.0, newPadding.right),
          bottom: max(0.0, newPadding.bottom),
          left: max(0.0, newPadding.left),
        );

        return mq.copyWith(
          textScaler: const TextScaler.linear(1.1),
          padding: newPadding,
          viewPadding: newViewPadding,
          navigationMode: NavigationMode.directional,
        );
      };
      if (settings.forceTvLayout) {
        await windowService.requestOrientation(Orientation.landscape);
      }
    } else {
      _pageTransitionsBuilderNotifier.value = defaultPageTransitionsBuilder;
      _tvMediaQueryModifierNotifier.value = null;
      await windowService.requestOrientation(null);
    }
  }

  void _monitorSettings() {
    void applyIsInstalledAppAccessAllowed() {
      if (settings.isInstalledAppAccessAllowed) {
        appInventory.initAppNames();
      } else {
        appInventory.resetAppNames();
      }
    }

    void applyDisplayRefreshRateMode() => settings.displayRefreshRateMode.apply();

    void applyMaxBrightness() {
      switch (settings.maxBrightness) {
        case MaxBrightness.never:
        case MaxBrightness.viewerOnly:
          ScreenBrightness().resetScreenBrightness();
        case MaxBrightness.always:
          ScreenBrightness().setScreenBrightness(1);
      }
    }

    void applyKeepScreenOn() => settings.keepScreenOn.apply();

    void applyIsRotationLocked() {
      if (!settings.isRotationLocked && !settings.useTvLayout) {
        windowService.requestOrientation();
      }
    }

    void applyForceTvLayout() {
      _onTvLayoutChanged();
      unawaited(_navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          settings: const RouteSettings(name: HomePage.routeName),
          builder: (_) => _getFirstPage(),
        ),
        (route) => false,
      ));
    }

    final settingStream = settings.updateStream;
    // app
    settingStream.where((event) => event.key == SettingKeys.isInstalledAppAccessAllowedKey).listen((_) => applyIsInstalledAppAccessAllowed());
    // display
    settingStream.where((event) => event.key == SettingKeys.displayRefreshRateModeKey).listen((_) => applyDisplayRefreshRateMode());
    settingStream.where((event) => event.key == SettingKeys.maxBrightnessKey).listen((_) => applyMaxBrightness());
    settingStream.where((event) => event.key == SettingKeys.forceTvLayoutKey).listen((_) => applyForceTvLayout());
    // navigation
    settingStream.where((event) => event.key == SettingKeys.keepScreenOnKey).listen((_) => applyKeepScreenOn());
    // platform settings
    settingStream.where((event) => event.key == SettingKeys.platformAccelerometerRotationKey).listen((_) => applyIsRotationLocked());

    applyDisplayRefreshRateMode();
    applyMaxBrightness();
    applyKeepScreenOn();
    applyIsRotationLocked();
  }

  Future<void> _setupErrorReporting() async {
    await reportService.init();
    settings.updateStream.where((event) => event.key == SettingKeys.isErrorReportingAllowedKey).listen(
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
      'is_television': device.isTelevision,
      'locales': WidgetsBinding.instance.platformDispatcher.locales.join(', '),
      'time_zone': '${now.timeZoneName} (${now.timeZoneOffset})',
    });
    await reportService.log('Launch');
    setState(() => _navigatorObservers = [
          AvesApp.pageRouteObserver,
          ReportingRouteTracker(),
        ]);
  }

  void _onNewIntent(Map? intentData) {
    debugPrint('$runtimeType onNewIntent with intentData=$intentData');

    // do not reset when relaunching the app
    if (_appModeNotifier.value == AppMode.main && (intentData == null || intentData.isEmpty == true)) {
      reportService.log('Relaunch');
      return;
    }

    reportService.log('New intent data=$intentData');
    _navigatorKey.currentState!.pushReplacement(DirectMaterialPageRoute(
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

  void _onError(String? error) => reportService.recordError(error, null);
}

class AvesScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    final animate = context.select<Settings, bool>((v) => v.accessibilityAnimations.animate);
    return animate
        ? StretchingOverscrollIndicator(
            axisDirection: details.direction,
            child: child,
          )
        : GlowingOverscrollIndicator(
            axisDirection: details.direction,
            color: Colors.white,
            child: child,
          );
  }
}

typedef TvMediaQueryModifier = MediaQueryData Function(MediaQueryData);
