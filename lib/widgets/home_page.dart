import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/home_page.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/analysis_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/global_search.dart';
import 'package:aves/services/viewer_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/search/search_page.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _shortcutRouteName, _shortcutSearchQuery;
  Set<String>? _shortcutFilters;

  static const allowedShortcutRoutes = [CollectionPage.routeName, AlbumListPage.routeName, SearchPage.routeName];

  @override
  void initState() {
    super.initState();
    _setup();
    imageCache.maximumSizeBytes = 512 * (1 << 20);
  }

  @override
  Widget build(BuildContext context) => const Scaffold();

  Future<void> _setup() async {
    final stopwatch = Stopwatch()..start();
    final permissions = await [
      Permission.storage,
      // to access media with unredacted metadata with scoped storage (Android 10+)
      Permission.accessMediaLocation,
    ].request();
    if (permissions[Permission.storage] != PermissionStatus.granted) {
      unawaited(SystemNavigator.pop());
      return;
    }

    await androidFileUtils.init();
    if (settings.isInstalledAppAccessAllowed) {
      // TODO TLAD transition code (it's unset in v1.5.4), remove in a later release
      settings.isInstalledAppAccessAllowed = settings.isInstalledAppAccessAllowed;

      unawaited(androidFileUtils.initAppNames());
    }

    var appMode = AppMode.main;
    final intentData = widget.intentData ?? await ViewerService.getIntentData();
    if (intentData.isNotEmpty) {
      final action = intentData['action'];
      await reportService.log('Intent data=$intentData');
      switch (action) {
        case 'view':
          _viewerEntry = await _initViewerEntry(
            uri: intentData['uri'],
            mimeType: intentData['mimeType'],
          );
          if (_viewerEntry != null) {
            appMode = AppMode.view;
          }
          break;
        case 'pick':
          // TODO TLAD apply pick mimetype(s)
          // some apps define multiple types, separated by a space (maybe other signs too, like `,` `;`?)
          String? pickMimeTypes = intentData['mimeType'];
          final multiple = intentData['allowMultiple'] ?? false;
          debugPrint('pick mimeType=$pickMimeTypes multiple=$multiple');
          appMode = multiple ? AppMode.pickMultipleMediaExternal : AppMode.pickSingleMediaExternal;
          break;
        case 'search':
          _shortcutRouteName = SearchPage.routeName;
          _shortcutSearchQuery = intentData['query'];
          break;
        default:
          // do not use 'route' as extra key, as the Flutter framework acts on it
          final extraRoute = intentData['page'];
          if (allowedShortcutRoutes.contains(extraRoute)) {
            _shortcutRouteName = extraRoute;
          }
          final extraFilters = intentData['filters'];
          _shortcutFilters = extraFilters != null ? (extraFilters as List).cast<String>().toSet() : null;
      }
    }
    context.read<ValueNotifier<AppMode>>().value = appMode;
    unawaited(reportService.setCustomKey('app_mode', appMode.toString()));
    debugPrint('Storage check complete in ${stopwatch.elapsed.inMilliseconds}ms');

    switch (appMode) {
      case AppMode.main:
      case AppMode.pickSingleMediaExternal:
      case AppMode.pickMultipleMediaExternal:
        unawaited(GlobalSearch.registerCallback());
        unawaited(AnalysisService.registerCallback());
        final source = context.read<CollectionSource>();
        await source.init(
          loadTopEntriesFirst: settings.homePage == HomePageSetting.collection,
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
            );
          }
        }
        break;
      case AppMode.pickMediaInternal:
      case AppMode.pickFilterInternal:
        break;
    }

    // `pushReplacement` is not enough in some edge cases
    // e.g. when opening the viewer in `view` mode should replace a viewer in `main` mode
    unawaited(Navigator.pushAndRemoveUntil(
      context,
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
    final entry = await mediaFileService.getEntry(uri, mimeType);
    if (entry != null) {
      // cataloguing is essential for coordinates and video rotation
      await entry.catalog(background: false, force: false, persist: false);
    }
    return entry;
  }

  Future<Route> _getRedirectRoute(AppMode appMode) async {
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
            if (source.stateNotifier.value != SourceState.loading) {
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
        routeName = _shortcutRouteName ?? settings.homePage.routeName;
        filters = (_shortcutFilters ?? {}).map(CollectionFilter.fromJson).toSet();
        break;
    }
    final source = context.read<CollectionSource>();
    switch (routeName) {
      case AlbumListPage.routeName:
        return DirectMaterialPageRoute(
          settings: const RouteSettings(name: AlbumListPage.routeName),
          builder: (_) => const AlbumListPage(),
        );
      case SearchPage.routeName:
        return SearchPageRoute(
          delegate: CollectionSearchDelegate(
            source: source,
            canPop: false,
            initialQuery: _shortcutSearchQuery,
          ),
        );
      case CollectionPage.routeName:
      default:
        return DirectMaterialPageRoute(
          settings: const RouteSettings(name: CollectionPage.routeName),
          builder: (_) => CollectionPage(
            source: source,
            filters: filters,
          ),
        );
    }
  }
}
