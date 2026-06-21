import 'dart:async';
import 'dart:math';

import 'package:aves/app_flavor.dart';
import 'package:aves/app_mode.dart';
import 'package:aves/geo/uri.dart';
import 'package:aves/l10n/l10n.dart';
import 'package:aves/model/app/intent.dart';
import 'package:aves/model/app_inventory.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/filters/recent.dart';
import 'package:aves/model/settings/defaults.dart';
import 'package:aves/model/settings/enums/display_refresh_rate_mode.dart';
import 'package:aves/model/settings/enums/screen_on.dart';
import 'package:aves/model/settings/enums/theme_brightness.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/media_store_source.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/accessibility_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/about/app_ref.dart';
import 'package:aves/widgets/collection/collection_grid.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/basic/derived_material_localization.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/behaviour/route_tracker.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/durations_provider.dart';
import 'package:aves/widgets/common/providers/highlight_info_provider.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/providers/viewer_entry_provider.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_location_dialog.dart';
import 'package:aves/widgets/home/home_page.dart';
import 'package:aves/widgets/navigation/tv_page_transitions.dart';
import 'package:aves/widgets/navigation/tv_rail.dart';
import 'package:aves/widgets/settings/app_export/items.dart';
import 'package:aves/widgets/settings/settings_action_delegate.dart';
import 'package:aves/widgets/welcome_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:collection/collection.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:equatable/equatable.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class AvesApp extends StatefulWidget {
  final AppFlavor flavor;
  final Map<String, Object?>? debugIntentData;

  // temporary exclude locales not ready yet for prime time
  // `ckb`: add `flutter_ckb_localization` and necessary app localization delegates when ready
  static final _unsupportedLocales = {
    'az', // Azerbaijani
    'bn', // Bengali
    'ckb', // Kurdish (Sorani, Central)
    'he', // Hebrew
    'hi', // Hindi
    'hr', // Croatian
    'ml', // Malayalam
    'my', // Burmese
    'ne', // Nepali
    'or', // Odia
    'sat', // Santali
    'sl', // Slovenian
    'sr', // Serbian
    'th', // Thai
    'ur', // Urdu
  }.map(Locale.new).toSet();
  static final List<Locale> supportedLocales = AppLocalizations.supportedLocales.where((v) => !_unsupportedLocales.contains(v)).toList();
  static final ValueNotifier<bool> canGestureToOtherApps = ValueNotifier(false);
  static final ValueNotifier<bool> isInPictureInPictureMode = ValueNotifier(false);
  static final ValueNotifier<EdgeInsets> cutoutInsetsNotifier = ValueNotifier(EdgeInsets.zero);

  // children widgets registering as `WidgetsBinding` observers and implementing `didChangeAppLifecycleState`
  // do not receive events fast enough for time sensitive actions (like PiP when leaving by gesture to home)
  // so we use this notifier to propagate events as soon as received by the top widget `AvesApp`
  static final ValueNotifier<AppLifecycleState> lifecycleStateNotifier = ValueNotifier(AppLifecycleState.detached);

  // do not monitor all `ModalRoute`s, which would include popup menus,
  // so that we can react to fullscreen `PageRoute`s only
  static final RouteObserver<PageRoute> pageRouteObserver = RouteObserver<PageRoute>();

  static ScreenBrightness? get screenBrightness => _AvesAppState._screenBrightness;

  static EventBus get intentEventBus => _AvesAppState._intentEventBus;

  const AvesApp({
    super.key,
    required this.flavor,
    this.debugIntentData,
  });

  @override
  State<AvesApp> createState() => _AvesAppState();

  static void setSystemUIStyle(ThemeData theme) {
    final style = systemUIStyleForBrightness(theme.brightness, theme.colorScheme.surfaceContainer);
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  static SystemUiOverlayStyle systemUIStyleForBrightness(Brightness themeBrightness, Color backgroundColor) {
    final barBrightness = themeBrightness == Brightness.dark ? Brightness.light : Brightness.dark;
    const statusBarColor = Colors.transparent;
    // as of Flutter v3.3.0-0.2.pre, setting `SystemUiOverlayStyle` (whether manually or automatically because of `AppBar`)
    // prevents the canvas from drawing behind the nav bar on Android <10 (API <29),
    // so the nav bar is opaque, even when requesting `SystemUiMode.edgeToEdge` from Flutter
    // or setting `android:windowTranslucentNavigation` in Android themes.
    final navBarColor = device.supportEdgeToEdgeUIMode ? Colors.transparent : backgroundColor;

    // on Android >=15 (API >=35), setting colors here has no effect
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
  final Set<StreamSubscription> _subscriptions = {};
  late final Future<void> _appSetup;
  final TvRailController _tvRailController = TvRailController();
  final MediaStoreSource _mediaStoreSource = MediaStoreSource();
  Size? _screenSize;

  final ValueNotifier<AppMode> _appModeNotifier = ValueNotifier(AppMode.initialization);

  // observers are not registered when using the same list object with different items
  // the list itself needs to be reassigned
  List<NavigatorObserver> _navigatorObservers = [AvesApp.pageRouteObserver];
  final EventChannel _mediaStoreChangeChannel = const OptionalEventChannel('deckers.thibault/aves/media_store_change');
  final EventChannel _newIntentChannel = const OptionalEventChannel('deckers.thibault/aves/new_intent_stream');
  final EventChannel _analysisCompletionChannel = const OptionalEventChannel('deckers.thibault/aves/analysis_events');
  final EventChannel _errorChannel = const OptionalEventChannel('deckers.thibault/aves/error');
  final EventChannel _platformWindowChangeChannel = const OptionalEventChannel('deckers.thibault/aves/window_change');

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: 'app-navigator');
  static ScreenBrightness? _screenBrightness;
  static bool _exitedMainByPop = false;
  static final EventBus _intentEventBus = EventBus();

  @override
  void initState() {
    super.initState();
    EquatableConfig.stringify = true;
    _appSetup = _setup();
    _subscriptions.add(_mediaStoreChangeChannel.receiveBroadcastStream().cast<String?>().listen(_mediaStoreSource.onStoreChanged));
    _subscriptions.add(_newIntentChannel.receiveBroadcastStream().cast<Map?>().listen(_onNewIntent));
    _subscriptions.add(_analysisCompletionChannel.receiveBroadcastStream().listen((_) => _onAnalysisCompletion()));
    _subscriptions.add(_errorChannel.receiveBroadcastStream().cast<String>().listen(_onError));
    _subscriptions.add(_platformWindowChangeChannel.receiveBroadcastStream().cast<String>().listen(_onWindowChange));
    _updateCutoutInsets();
    _updateWindowMode();
    _appModeNotifier.addListener(_onAppModeChanged);

    debugPrint('start listening to app lifecycle');
    WidgetsBinding.instance.addObserver(this);
    AvesApp.lifecycleStateNotifier.value = WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.detached;
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();

    debugPrint('stop listening to app lifecycle');
    WidgetsBinding.instance.removeObserver(this);

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
        ViewerEntryProvider(),
      ],
      child: NotificationListener<PopExitNotification>(
        onNotification: (notification) {
          if (_appModeNotifier.value == AppMode.main) {
            _exitedMainByPop = true;
          }
          return true;
        },
        child: OverlaySupport(
          child: FutureBuilder<void>(
            future: _appSetup,
            builder: (context, snapshot) {
              final initialized = !snapshot.hasError && snapshot.connectionState == ConnectionState.done;
              if (initialized) {
                windowService.showSystemUI(true);
              }
              final home = initialized
                  ? getFirstPage(intentData: widget.debugIntentData)
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
                              // depending on `MediaQuery` as an `InheritedWidget` means that the whole `MaterialApp`
                              // will rebuild on any change, including on `viewInsets` transient changes,
                              // when focusing on a text field and the keyboard pops in and out.
                              data: MediaQuery.of(context).copyWith(
                                // disable accessible navigation, as it impacts snack bar action timer
                                // for all users of apps registered as accessibility services,
                                // even though they are not for accessibility purposes (like TalkBack is)
                                accessibleNavigation: false,
                                // disabling animations at the framework level is problematic (e.g. GIF playback)
                                // so we handle it through the app settings and more fine-grained behaviour
                                disableAnimations: false,
                              ),
                              child: MaterialApp(
                                navigatorKey: navigatorKey,
                                home: home,
                                onUnknownRoute: (settings) {
                                  // as of Flutter v3.44.2, using `$settings` in exception message yields `Instance of 'RouteSettings'` in reports,
                                  // so we explicitly stringify variable outside
                                  final settingsString = '${settings.runtimeType}(${settings.name == null ? 'none' : '"${settings.name}"'}, ${settings.arguments})';
                                  reportService.recordError(Exception('Could not find a generator for route settings=$settingsString in the $runtimeType.'));
                                  return null;
                                },
                                navigatorObservers: _navigatorObservers,
                                builder: (context, child) => AvesAppContentDecorator(
                                  initialized: initialized,
                                  source: _mediaStoreSource,
                                  child: child,
                                ),
                                onGenerateTitle: (context) => context.l10n.appName,
                                theme: lightTheme,
                                darkTheme: darkTheme,
                                themeMode: themeBrightness.appThemeMode,
                                locale: settingsLocale,
                                localizationsDelegates: const [
                                  // order matters for resolution of sublocales (e.g. `en_Shaw` before `en`)
                                  ...LocalizationsEnShaw.delegates,
                                  ...LocalizationsKmr.delegates,
                                  ...LocalizationsNn.delegates,
                                  ...AppLocalizations.localizationsDelegates,
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
      ),
    );
  }

  Widget _buildError(Object error) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: .min,
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
      case .inactive:
        switch (_appModeNotifier.value) {
          case .main:
          case .pickSingleMediaExternal:
          case .pickMultipleMediaExternal:
            _saveTopEntries();
          default:
            break;
        }
      case .resumed:
        availability.onResume();
        RecentlyAddedFilter.updateNow();
        _mediaStoreSource.checkForChanges();
      default:
        break;
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) => _applyLocale();

  Future<void> _onWindowChange(String? code) async {
    if (code == null) return;
    switch (code) {
      case 'cutout_insets':
        await _updateCutoutInsets();
        break;
      case 'window_mode':
        await _updateWindowMode();
        break;
    }
  }

  Future<void> _updateCutoutInsets() async {
    AvesApp.cutoutInsetsNotifier.value = await windowService.getCutoutInsets();
  }

  Future<void> _updateWindowMode() async {
    final isInPipMode = await windowService.isInPictureInPictureMode();
    AvesApp.isInPictureInPictureMode.value = isInPipMode;
    AvesApp.canGestureToOtherApps.value = await windowService.isInMultiWindowMode() && !isInPipMode;
  }

  void _applyLocale() {
    settings.resetAppliedLocale();

    final appliedLocale = settings.appliedLocale;
    AStyles.updateStylesForLocale(appliedLocale);

    Locale? countrifiedLocale;
    if (appliedLocale.countryCode == null) {
      final languageCode = appliedLocale.languageCode;
      countrifiedLocale = WidgetsBinding.instance.platformDispatcher.locales.firstWhereOrNull((v) => v.languageCode == languageCode);
    }

    final useNativeDigits = !settings.forceWesternArabicNumerals && shouldUseNativeDigits(countrifiedLocale);
    DateFormat.useNativeDigitsByDefaultFor(appliedLocale.toString(), useNativeDigits);
    DateFormat.useNativeDigitsByDefaultFor(countrifiedLocale.toString(), useNativeDigits);
  }

  static Widget getFirstPage({Map<String, Object?>? intentData}) => settings.hasAcceptedTerms ? HomePage(intentData: intentData) : const WelcomePage();

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
    await settings.init(monitorPlatformSettings: true, shouldSanitize: true);
    settings.isRotationLocked = await windowService.isRotationLocked();
    settings.longPressTimeoutMillis = await AccessibilityService.getLongPressTimeout();
    settings.areAnimationsRemoved = await AccessibilityService.areAnimationsRemoved();
    _monitorSettings();
    videoControllerFactory.init();
    videoMetadataFetcher.init();

    unawaited(deviceService.setLocaleConfig(AvesApp.supportedLocales));
    unawaited(storageService.deleteTempDirectory());
    unawaited(_setupErrorReporting());

    debugPrint('App setup in ${stopwatch.elapsed.inMilliseconds}ms');
  }

  void _monitorSettings() {
    void _applyIsInstalledAppAccessAllowed() {
      if (settings.isInstalledAppAccessAllowed) {
        appInventory.initAppNames();
      } else {
        appInventory.resetAppNames();
      }
    }

    void _applyDisplayRefreshRateMode() => settings.displayRefreshRateMode.apply();

    void _applyMaxBrightness() {
      try {
        switch (settings.maxBrightness) {
          case .never:
          case .viewerOnly:
            AvesApp.screenBrightness?.resetApplicationScreenBrightness();
          case .always:
            AvesApp.screenBrightness?.setApplicationScreenBrightness(1);
        }
      } on PlatformException catch (e, stack) {
        // `screen_brightness` plugin may fail
        reportService.recordError(e, stack);
      }
    }

    void _applyKeepScreenOn() => settings.keepScreenOn.apply();

    void _applyIsRotationLocked() {
      if (!settings.isRotationLocked && !settings.useTvLayout) {
        windowService.requestOrientation();
      }
    }

    final settingStream = settings.updateStream;
    // app
    settingStream.where((event) => event.key == SettingKeys.isInstalledAppAccessAllowedKey).listen((_) => _applyIsInstalledAppAccessAllowed());
    settingStream.where((event) => event.key == SettingKeys.localeKey || event.key == SettingKeys.forceWesternArabicNumeralsKey).listen((_) => _applyLocale());
    // display
    settingStream.where((event) => event.key == SettingKeys.displayRefreshRateModeKey).listen((_) => _applyDisplayRefreshRateMode());
    settingStream.where((event) => event.key == SettingKeys.maxBrightnessKey).listen((_) => _applyMaxBrightness());
    // navigation
    settingStream.where((event) => event.key == SettingKeys.keepScreenOnKey).listen((_) => _applyKeepScreenOn());
    // platform settings
    settingStream.where((event) => event.key == SettingKeys.platformAccelerometerRotationKey).listen((_) => _applyIsRotationLocked());

    _applyLocale();
    _applyDisplayRefreshRateMode();
    _applyMaxBrightness();
    _applyKeepScreenOn();
    _applyIsRotationLocked();
  }

  Future<void> _setupErrorReporting() async {
    await reportService.init();
    settings.updateStream
        .where((event) => event.key == SettingKeys.isErrorReportingAllowedKey)
        .listen(
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
          : kDebugMode
          ? 'debug'
          : 'unknown',
      'has_mobile_services': mobileServices.isServiceAvailable,
      'is_television': device.isTelevision,
      'locales': WidgetsBinding.instance.platformDispatcher.locales.join(', '),
      'time_zone': '${now.timeZoneName} (${now.timeZoneOffset})',
    });
    await reportService.log('Launch');
    setState(
      () => _navigatorObservers = [
        AvesApp.pageRouteObserver,
        ReportingRouteTracker(),
      ],
    );
  }

  // at this level `ModalRoute.of(context)` is null,
  // so we use the global navigator as a workaround
  String? getCurrentRouteName() {
    String? currentRoute;
    navigatorKey.currentState?.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });
    return currentRoute;
  }

  void _onNewIntent(Map? intentData) {
    reportService.log('New intent data=$intentData');

    if (_appModeNotifier.value == AppMode.main) {
      // do not reset when relaunching the app, except when exiting by pop
      final shouldReset = _exitedMainByPop;
      _exitedMainByPop = false;

      if (!shouldReset && (intentData ?? {}).values.nonNulls.isEmpty) {
        reportService.log('Relaunch');
        return;
      }
    }

    if (intentData != null) {
      final intentAction = intentData[IntentDataKeys.action] as String?;
      if (intentAction == IntentActions.viewGeo) {
        final locationZoom = parseGeoUri(intentData[IntentDataKeys.uri] as String?);
        if (locationZoom != null && getCurrentRouteName() == EditEntryLocationDialog.routeName) {
          // do not push a new route but pass the provided location to the dialog
          final location = locationZoom.$1;
          debugPrint('Use received location $location for input');
          _intentEventBus.fire(LocationReceivedEvent(location));
          return;
        }
      }
    }

    navigatorKey.currentState!.pushReplacement(
      DirectMaterialPageRoute(
        settings: const RouteSettings(name: HomePage.routeName),
        builder: (_) => getFirstPage(intentData: intentData?.cast<String, Object?>()),
      ),
    );
  }

  Future<void> _onAnalysisCompletion() async {
    debugPrint('Analysis completed');
    await _mediaStoreSource.loadCatalogMetadata();
    await _mediaStoreSource.loadAddresses();
    _mediaStoreSource.updateDerivedFilters();
  }

  void _onError(String error) => reportService.recordError(error);

  void _onAppModeChanged() {
    final appMode = _appModeNotifier.value;
    debugPrint('App mode set to $appMode');
    switch (appMode) {
      case .screenSaver:
        // we cannot modify brightness without access to the activity
        _screenBrightness = null;
      default:
        _screenBrightness = ScreenBrightness();
    }
  }
}

// Flutter has various overscroll indicator implementations for Android:
// - `StretchingOverscrollIndicator`, default when using Material 3
// - `GlowingOverscrollIndicator`, default when not using Material 3
class AvesScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    final animate = context.select<Settings, bool>((v) => v.animate);
    return animate
        ? StretchingOverscrollIndicator(
            axisDirection: details.direction,
            child: child,
          )
        : child;
  }
}

typedef TvMediaQueryModifier = MediaQueryData Function(MediaQueryData);

class LocationReceivedEvent {
  final LatLng location;

  const LocationReceivedEvent(this.location);
}

class AvesAppContentDecorator extends StatefulWidget {
  final bool initialized;
  final CollectionSource source;
  final Widget? child;

  const AvesAppContentDecorator({
    super.key,
    required this.initialized,
    required this.source,
    required this.child,
  });

  @override
  State<AvesAppContentDecorator> createState() => _AvesAppContentDecoratorState();
}

class _AvesAppContentDecoratorState extends State<AvesAppContentDecorator> with FeedbackMixin {
  late final Future<bool> _shouldUseBoldFontLoader;
  final ValueNotifier<PageTransitionsBuilder> _pageTransitionsBuilderNotifier = ValueNotifier(_defaultPageTransitionsBuilder);
  final ValueNotifier<TvMediaQueryModifier?> _tvMediaQueryModifierNotifier = ValueNotifier(null);
  final Set<StreamSubscription> _subscriptions = {};

  CollectionSource get source => widget.source;

  static const _defaultPageTransitionsBuilder = PredictiveBackPageTransitionsBuilder();

  @override
  void initState() {
    super.initState();
    _shouldUseBoldFontLoader = AccessibilityService.shouldUseBoldFont();
    source.stateNotifier.addListener(_onSourceStateChanged);
    _subscriptions.add(settings.updateStream.where((event) => event.key == SettingKeys.forceTvLayoutKey).listen((_) => _applyForceTvLayout()));
  }

  @override
  void didUpdateWidget(covariant AvesAppContentDecorator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.initialized && widget.initialized) {
      AvesApp.setSystemUIStyle(Theme.of(context));
      WidgetsBinding.instance.addPostFrameCallback((_) => _onTvLayoutChanged());
    }
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _pageTransitionsBuilderNotifier.dispose();
    _tvMediaQueryModifierNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialLocalizationsRegionalizer(
      child: FutureBuilder<bool>(
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
                      final theme = Theme.of(context);
                      final animate = context.select<Settings, bool>((s) => s.initialized ? s.animate : true);
                      return Theme(
                        data: theme.copyWith(
                          pageTransitionsTheme: animate
                              ? PageTransitionsTheme(builders: {TargetPlatform.android: pageTransitionsBuilder})
                              // strip page transitions used by `MaterialPageRoute`
                              : const DirectPageTransitionsTheme(),
                          splashFactory: animate ? theme.splashFactory : NoSplash.splashFactory,
                        ),
                        child: MediaQueryDataProvider(child: child!),
                      );
                    },
                    child: child,
                  ),
                ),
              );
            },
            child: widget.child,
          );
        },
      ),
    );
  }

  Future<void> _onSourceStateChanged() async {
    final appMode = context.read<ValueNotifier<AppMode>>().value;
    if (appMode == .main) {
      if (source.isReady) {
        final dirPath = settings.autoExportPath;
        if (dirPath != null) {
          final content = SettingsActionDelegate.getExportContent(
            source: source,
            toExport: AppExportItem.values.toSet(),
          );
          const mimeType = MimeTypes.json;
          const suffix = kProfileMode
              ? '-profile'
              : kDebugMode
              ? '-debug'
              : '';
          final success = await storageService.createFile(
            dirPath: dirPath,
            basename: 'aves$suffix-settings-auto',
            mimeType: mimeType,
            bytes: content,
          );

          if (success != null) {
            if (success) {
              await reportService.log('Exported settings to dirPath=$dirPath');
            } else {
              final l10n = context.l10n;
              showFeedback(
                context,
                FeedbackType.warn,
                '${l10n.genericFailureFeedback}${AText.separator}${l10n.settingsAutoExportSettings}',
                SnackBarAction(
                  label: 'FAQ',
                  onPressed: () => AvesApp.launchUrl('${AppReference.avesFaq}#why-is-auto-settings-export-failing'),
                ),
              );
            }
          }
        }
        source.stateNotifier.removeListener(_onSourceStateChanged);
      }
    }
  }

  Future<void> _applyForceTvLayout() async {
    await _onTvLayoutChanged();
    unawaited(
      _AvesAppState.navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          settings: const RouteSettings(name: HomePage.routeName),
          builder: (_) => _AvesAppState.getFirstPage(),
        ),
        (route) => false,
      ),
    );
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
      _pageTransitionsBuilderNotifier.value = _defaultPageTransitionsBuilder;
      _tvMediaQueryModifierNotifier.value = null;
      await windowService.requestOrientation(null);
    }
  }
}
