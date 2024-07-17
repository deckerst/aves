import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/app/permissions.dart';
import 'package:aves/model/apps.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/catalog.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/enums/home_page.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/analysis_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/global_search.dart';
import 'package:aves/services/intent_service.dart';
import 'package:aves/services/widget_service.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/editor/entry_editor_page.dart';
import 'package:aves/widgets/explorer/explorer_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/intent.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/settings/home_widget_settings_page.dart';
import 'package:aves/widgets/settings/screen_saver_settings_page.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:aves/widgets/viewer/screen_saver_page.dart';
import 'package:aves/widgets/wallpaper_page.dart';
import 'package:aves_model/aves_model.dart';
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
  String? _initialExplorerPath;
  List<String>? _secureUris;

  static const allowedShortcutRoutes = [
    AlbumListPage.routeName,
    CollectionPage.routeName,
    ExplorerPage.routeName,
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
      await Permissions.mediaAccess.request();
    }

    var appMode = AppMode.main;
    final intentData = widget.intentData ?? await IntentService.getIntentData();
    final safeMode = intentData[IntentDataKeys.safeMode] ?? false;
    final intentAction = intentData[IntentDataKeys.action];
    _initialFilters = null;
    _initialExplorerPath = null;
    _secureUris = null;

    await androidFileUtils.init();
    if (!{
          IntentActions.edit,
          IntentActions.screenSaver,
          IntentActions.setWallpaper,
        }.contains(intentAction) &&
        settings.isInstalledAppAccessAllowed) {
      unawaited(appInventory.initAppNames());
    }

    if (intentData.isNotEmpty) {
      await reportService.log('Intent data=$intentData');
      switch (intentAction) {
        case IntentActions.view:
        case IntentActions.widgetOpen:
          String? uri, mimeType;
          final widgetId = intentData[IntentDataKeys.widgetId];
          if (widgetId != null) {
            // widget settings may be modified in a different process after channel setup
            await settings.reload();
            final page = settings.getWidgetOpenPage(widgetId);
            switch (page) {
              case WidgetOpenPage.home:
              case WidgetOpenPage.updateWidget:
                break;
              case WidgetOpenPage.collection:
                _initialFilters = settings.getWidgetCollectionFilters(widgetId);
              case WidgetOpenPage.viewer:
                uri = settings.getWidgetUri(widgetId);
            }
            unawaited(WidgetService.update(widgetId));
          } else {
            uri = intentData[IntentDataKeys.uri];
            mimeType = intentData[IntentDataKeys.mimeType];
          }
          _secureUris = intentData[IntentDataKeys.secureUris];
          if (uri != null) {
            _viewerEntry = await _initViewerEntry(
              uri: uri,
              mimeType: mimeType,
            );
            if (_viewerEntry != null) {
              appMode = AppMode.view;
            }
          }
        case IntentActions.edit:
          _viewerEntry = await _initViewerEntry(
            uri: intentData[IntentDataKeys.uri],
            mimeType: intentData[IntentDataKeys.mimeType],
          );
          if (_viewerEntry != null) {
            appMode = AppMode.edit;
          }
        case IntentActions.setWallpaper:
          _viewerEntry = await _initViewerEntry(
            uri: intentData[IntentDataKeys.uri],
            mimeType: intentData[IntentDataKeys.mimeType],
          );
          if (_viewerEntry != null) {
            appMode = AppMode.setWallpaper;
          }
        case IntentActions.pickItems:
          // TODO TLAD apply pick mimetype(s)
          // some apps define multiple types, separated by a space (maybe other signs too, like `,` `;`?)
          String? pickMimeTypes = intentData[IntentDataKeys.mimeType];
          final multiple = intentData[IntentDataKeys.allowMultiple] ?? false;
          debugPrint('pick mimeType=$pickMimeTypes multiple=$multiple');
          appMode = multiple ? AppMode.pickMultipleMediaExternal : AppMode.pickSingleMediaExternal;
        case IntentActions.pickCollectionFilters:
          appMode = AppMode.pickCollectionFiltersExternal;
        case IntentActions.screenSaver:
          appMode = AppMode.screenSaver;
          _initialRouteName = ScreenSaverPage.routeName;
        case IntentActions.screenSaverSettings:
          _initialRouteName = ScreenSaverSettingsPage.routeName;
        case IntentActions.search:
          _initialRouteName = SearchPage.routeName;
          _initialSearchQuery = intentData[IntentDataKeys.query];
        case IntentActions.widgetSettings:
          _initialRouteName = HomeWidgetSettingsPage.routeName;
          _widgetId = intentData[IntentDataKeys.widgetId] ?? 0;
        default:
          // do not use 'route' as extra key, as the Flutter framework acts on it
          final extraRoute = intentData[IntentDataKeys.page];
          if (allowedShortcutRoutes.contains(extraRoute)) {
            _initialRouteName = extraRoute;
          }
      }
      if (_initialFilters == null) {
        final extraFilters = intentData[IntentDataKeys.filters];
        _initialFilters = extraFilters != null ? (extraFilters as List).cast<String>().map(CollectionFilter.fromJson).whereNotNull().toSet() : null;
      }
      _initialExplorerPath = intentData[IntentDataKeys.explorerPath];
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
        source.safeMode = safeMode;
        if (source.initState != SourceInitializationState.full) {
          await source.init(
            loadTopEntriesFirst: settings.homePage == HomePageSetting.collection && settings.homeCustomCollection.isEmpty,
          );
        }
      case AppMode.screenSaver:
        final source = context.read<CollectionSource>();
        await source.init(
          canAnalyze: false,
        );
      case AppMode.view:
        if (_isViewerSourceable(_viewerEntry) && _secureUris == null) {
          final directory = _viewerEntry?.directory;
          if (directory != null) {
            unawaited(AnalysisService.registerCallback());
            final source = context.read<CollectionSource>();
            await source.init(
              directory: directory,
              canAnalyze: false,
            );
          }
        } else {
          await _initViewerEssentials();
        }
      case AppMode.edit:
      case AppMode.setWallpaper:
        await _initViewerEssentials();
      default:
        break;
    }

    // `pushReplacement` is not enough in some edge cases
    // e.g. when opening the viewer in `view` mode should replace a viewer in `main` mode
    unawaited(Navigator.maybeOf(context)?.pushAndRemoveUntil(
      await _getRedirectRoute(appMode),
      (route) => false,
    ));
  }

  Future<void> _initViewerEssentials() async {
    // for video playback storage
    await metadataDb.init();
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
    String routeName;
    Set<CollectionFilter?>? filters;
    switch (appMode) {
      case AppMode.pickSingleMediaExternal:
      case AppMode.pickMultipleMediaExternal:
        routeName = CollectionPage.routeName;
      case AppMode.setWallpaper:
        return DirectMaterialPageRoute(
          settings: const RouteSettings(name: WallpaperPage.routeName),
          builder: (_) {
            return WallpaperPage(
              entry: _viewerEntry,
            );
          },
        );
      case AppMode.view:
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
              stackBursts: false,
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
      case AppMode.edit:
        return DirectMaterialPageRoute(
          settings: const RouteSettings(name: EntryViewerPage.routeName),
          builder: (_) {
            return ImageEditorPage(
              entry: _viewerEntry!,
            );
          },
        );
      default:
        routeName = _initialRouteName ?? settings.homePage.routeName;
        filters = _initialFilters ?? (settings.homePage == HomePageSetting.collection ? settings.homeCustomCollection : {});
    }
    Route buildRoute(WidgetBuilder builder) => DirectMaterialPageRoute(
          settings: RouteSettings(name: routeName),
          builder: builder,
        );

    final source = context.read<CollectionSource>();
    switch (routeName) {
      case AlbumListPage.routeName:
        return buildRoute((context) => const AlbumListPage());
      case TagListPage.routeName:
        return buildRoute((context) => const TagListPage());
      case ExplorerPage.routeName:
        final path = _initialExplorerPath ?? settings.homeCustomExplorerPath;
        return buildRoute((context) => ExplorerPage(path: path));
      case HomeWidgetSettingsPage.routeName:
        return buildRoute((context) => HomeWidgetSettingsPage(widgetId: _widgetId!));
      case ScreenSaverPage.routeName:
        return buildRoute((context) => ScreenSaverPage(source: source));
      case ScreenSaverSettingsPage.routeName:
        return buildRoute((context) => const ScreenSaverSettingsPage());
      case SearchPage.routeName:
        return SearchPageRoute(
          delegate: CollectionSearchDelegate(
            searchFieldLabel: context.l10n.searchCollectionFieldHint,
            searchFieldStyle: Themes.searchFieldStyle(context),
            source: source,
            canPop: false,
            initialQuery: _initialSearchQuery,
          ),
        );
      case CollectionPage.routeName:
      default:
        return buildRoute((context) => CollectionPage(source: source, filters: filters));
    }
  }
}
