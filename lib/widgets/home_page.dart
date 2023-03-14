import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/catalog.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/home_page.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums/enums.dart';
import 'package:aves/services/analysis_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/global_search.dart';
import 'package:aves/services/intent_service.dart';
import 'package:aves/services/widget_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/settings/home_widget_settings_page.dart';
import 'package:aves/widgets/settings/screen_saver_settings_page.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:aves/widgets/viewer/screen_saver_page.dart';
import 'package:aves/widgets/wallpaper_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  // untyped map as it is coming from the platform
  final Map? intentData;

  const HomePage({
    super.key,
    this.intentData,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AvesEntry? _viewerEntry;
  int? _widgetId;
  String? _initialRouteName, _initialSearchQuery;
  Set<CollectionFilter>? _initialFilters;

  static const actionPickItems = 'pick_items';
  static const actionPickCollectionFilters = 'pick_collection_filters';
  static const actionScreenSaver = 'screen_saver';
  static const actionScreenSaverSettings = 'screen_saver_settings';
  static const actionSearch = 'search';
  static const actionSetWallpaper = 'set_wallpaper';
  static const actionView = 'view';
  static const actionWidgetOpen = 'widget_open';
  static const actionWidgetSettings = 'widget_settings';

  static const intentDataKeyAction = 'action';
  static const intentDataKeyAllowMultiple = 'allowMultiple';
  static const intentDataKeyFilters = 'filters';
  static const intentDataKeyMimeType = 'mimeType';
  static const intentDataKeyPage = 'page';
  static const intentDataKeyQuery = 'query';
  static const intentDataKeyUri = 'uri';
  static const intentDataKeyWidgetId = 'widgetId';

  static const allowedShortcutRoutes = [
    CollectionPage.routeName,
    AlbumListPage.routeName,
    SearchPage.routeName,
  ];

  @override
  void initState() {
    super.initState();
    _setup();
    imageCache.maximumSizeBytes = 512 * (1 << 20);
  }

  @override
  Widget build(BuildContext context) => const AvesScaffold();

  Future<void> _setup() async {
    final stopwatch = Stopwatch()..start();
    if (await windowService.isActivity()) {
      // do not check whether permission was granted, because some app stores
      // hide in some countries apps that force quit on permission denial
      await [
        ...Constants.storagePermissions,
        // to access media with unredacted metadata with scoped storage (Android >=10)
        Permission.accessMediaLocation,
      ].request();
    }

    var appMode = AppMode.main;
    final intentData = widget.intentData ?? await IntentService.getIntentData();
    final intentAction = intentData[intentDataKeyAction];
    _initialFilters = null;

    await androidFileUtils.init();
    if (!{actionScreenSaver, actionSetWallpaper}.contains(intentAction) && settings.isInstalledAppAccessAllowed) {
      unawaited(androidFileUtils.initAppNames());
    }

    if (intentData.isNotEmpty) {
      await reportService.log('Intent data=$intentData');
      switch (intentAction) {
        case actionView:
        case actionWidgetOpen:
          String? uri, mimeType;
          final widgetId = intentData[intentDataKeyWidgetId];
          if (widgetId != null) {
            // widget settings may be modified in a different process after channel setup
            await settings.reload();
            final page = settings.getWidgetOpenPage(widgetId);
            switch (page) {
              case WidgetOpenPage.home:
                break;
              case WidgetOpenPage.collection:
                _initialFilters = settings.getWidgetCollectionFilters(widgetId);
                break;
              case WidgetOpenPage.viewer:
                uri = settings.getWidgetUri(widgetId);
                break;
            }
            unawaited(WidgetService.update(widgetId));
          } else {
            uri = intentData[intentDataKeyUri];
            mimeType = intentData[intentDataKeyMimeType];
          }
          if (uri != null) {
            _viewerEntry = await _initViewerEntry(
              uri: uri,
              mimeType: mimeType,
            );
            if (_viewerEntry != null) {
              appMode = AppMode.view;
            }
          }
          break;
        case actionPickItems:
          // TODO TLAD apply pick mimetype(s)
          // some apps define multiple types, separated by a space (maybe other signs too, like `,` `;`?)
          String? pickMimeTypes = intentData[intentDataKeyMimeType];
          final multiple = intentData[intentDataKeyAllowMultiple] ?? false;
          debugPrint('pick mimeType=$pickMimeTypes multiple=$multiple');
          appMode = multiple ? AppMode.pickMultipleMediaExternal : AppMode.pickSingleMediaExternal;
          break;
        case actionPickCollectionFilters:
          appMode = AppMode.pickCollectionFiltersExternal;
          break;
        case actionScreenSaver:
          appMode = AppMode.screenSaver;
          _initialRouteName = ScreenSaverPage.routeName;
          break;
        case actionScreenSaverSettings:
          _initialRouteName = ScreenSaverSettingsPage.routeName;
          break;
        case actionSearch:
          _initialRouteName = SearchPage.routeName;
          _initialSearchQuery = intentData[intentDataKeyQuery];
          break;
        case actionSetWallpaper:
          appMode = AppMode.setWallpaper;
          _viewerEntry = await _initViewerEntry(
            uri: intentData[intentDataKeyUri],
            mimeType: intentData[intentDataKeyMimeType],
          );
          break;
        case actionWidgetSettings:
          _initialRouteName = HomeWidgetSettingsPage.routeName;
          _widgetId = intentData[intentDataKeyWidgetId] ?? 0;
          break;
        default:
          // do not use 'route' as extra key, as the Flutter framework acts on it
          final extraRoute = intentData[intentDataKeyPage];
          if (allowedShortcutRoutes.contains(extraRoute)) {
            _initialRouteName = extraRoute;
          }
      }
      if (_initialFilters == null) {
        final extraFilters = intentData[intentDataKeyFilters];
        _initialFilters = extraFilters != null ? (extraFilters as List).cast<String>().map(CollectionFilter.fromJson).whereNotNull().toSet() : null;
      }
    }
    context.read<ValueNotifier<AppMode>>().value = appMode;
    unawaited(reportService.setCustomKey('app_mode', appMode.toString()));
    debugPrint('Storage check complete in ${stopwatch.elapsed.inMilliseconds}ms');

    switch (appMode) {
      case AppMode.main:
      case AppMode.pickCollectionFiltersExternal:
      case AppMode.pickSingleMediaExternal:
      case AppMode.pickMultipleMediaExternal:
        unawaited(GlobalSearch.registerCallback());
        unawaited(AnalysisService.registerCallback());
        final source = context.read<CollectionSource>();
        await source.init(
          loadTopEntriesFirst: settings.homePage == HomePageSetting.collection,
        );
        break;
      case AppMode.screenSaver:
        final source = context.read<CollectionSource>();
        await source.init(
          canAnalyze: false,
        );
        break;
      case AppMode.view:
        if (_isViewerSourceable(_viewerEntry)) {
          final directory = _viewerEntry?.directory;
          if (directory != null) {
            unawaited(AnalysisService.registerCallback());
            final source = context.read<CollectionSource>();
            await source.init(
              directory: directory,
              canAnalyze: false,
            );
          }
        }
        break;
      case AppMode.setWallpaper:
        // for video playback storage
        await metadataDb.init();
        break;
      case AppMode.pickMediaInternal:
      case AppMode.pickFilterInternal:
      case AppMode.slideshow:
        break;
    }

    // `pushReplacement` is not enough in some edge cases
    // e.g. when opening the viewer in `view` mode should replace a viewer in `main` mode
    unawaited(Navigator.maybeOf(context)?.pushAndRemoveUntil(
      await _getRedirectRoute(appMode),
      (route) => false,
    ));
  }

  bool _isViewerSourceable(AvesEntry? viewerEntry) {
    return viewerEntry != null && viewerEntry.directory != null && !settings.hiddenFilters.any((filter) => filter.test(viewerEntry));
  }

  Future<AvesEntry?> _initViewerEntry({required String uri, required String? mimeType}) async {
    if (uri.startsWith('/')) {
      // convert this file path to a proper URI
      uri = Uri.file(uri).toString();
    }
    final entry = await mediaFetchService.getEntry(uri, mimeType);
    if (entry != null) {
      // cataloguing is essential for coordinates and video rotation
      await entry.catalog(background: false, force: false, persist: false);
    }
    return entry;
  }

  Future<Route> _getRedirectRoute(AppMode appMode) async {
    if (appMode == AppMode.setWallpaper) {
      return DirectMaterialPageRoute(
        settings: const RouteSettings(name: WallpaperPage.routeName),
        builder: (_) {
          return WallpaperPage(
            entry: _viewerEntry,
          );
        },
      );
    }

    if (appMode == AppMode.view) {
      AvesEntry viewerEntry = _viewerEntry!;
      CollectionLens? collection;

      final source = context.read<CollectionSource>();
      if (source.initState != SourceInitializationState.none) {
        final album = viewerEntry.directory;
        if (album != null) {
          // wait for collection to pass the `loading` state
          final completer = Completer();
          void _onSourceStateChanged() {
            if (source.state != SourceState.loading) {
              source.stateNotifier.removeListener(_onSourceStateChanged);
              completer.complete();
            }
          }

          source.stateNotifier.addListener(_onSourceStateChanged);
          await completer.future;

          collection = CollectionLens(
            source: source,
            filters: {AlbumFilter(album, source.getAlbumDisplayName(context, album))},
            listenToSource: false,
            // if we group bursts, opening a burst sub-entry should:
            // - identify and select the containing main entry,
            // - select the sub-entry in the Viewer page.
            groupBursts: false,
          );
          final viewerEntryPath = viewerEntry.path;
          final collectionEntry = collection.sortedEntries.firstWhereOrNull((entry) => entry.path == viewerEntryPath);
          if (collectionEntry != null) {
            viewerEntry = collectionEntry;
          } else {
            debugPrint('collection does not contain viewerEntry=$viewerEntry');
            collection = null;
          }
        }
      }

      return DirectMaterialPageRoute(
        settings: const RouteSettings(name: EntryViewerPage.routeName),
        builder: (_) {
          return EntryViewerPage(
            collection: collection,
            initialEntry: viewerEntry,
          );
        },
      );
    }

    String routeName;
    Set<CollectionFilter?>? filters;
    switch (appMode) {
      case AppMode.pickSingleMediaExternal:
      case AppMode.pickMultipleMediaExternal:
        routeName = CollectionPage.routeName;
        break;
      default:
        routeName = _initialRouteName ?? settings.homePage.routeName;
        filters = _initialFilters ?? {};
        break;
    }
    final source = context.read<CollectionSource>();
    switch (routeName) {
      case AlbumListPage.routeName:
        return DirectMaterialPageRoute(
          settings: RouteSettings(name: routeName),
          builder: (context) => const AlbumListPage(),
        );
      case ScreenSaverPage.routeName:
        return DirectMaterialPageRoute(
          settings: RouteSettings(name: routeName),
          builder: (context) => ScreenSaverPage(
            source: source,
          ),
        );
      case ScreenSaverSettingsPage.routeName:
        return DirectMaterialPageRoute(
          settings: RouteSettings(name: routeName),
          builder: (context) => const ScreenSaverSettingsPage(),
        );
      case HomeWidgetSettingsPage.routeName:
        return DirectMaterialPageRoute(
          settings: RouteSettings(name: routeName),
          builder: (context) => HomeWidgetSettingsPage(
            widgetId: _widgetId!,
          ),
        );
      case SearchPage.routeName:
        return SearchPageRoute(
          delegate: CollectionSearchDelegate(
            searchFieldLabel: context.l10n.searchCollectionFieldHint,
            source: source,
            canPop: false,
            initialQuery: _initialSearchQuery,
          ),
        );
      case CollectionPage.routeName:
      default:
        return DirectMaterialPageRoute(
          settings: RouteSettings(name: routeName),
          builder: (context) => CollectionPage(
            source: source,
            filters: filters,
          ),
        );
    }
  }
}
