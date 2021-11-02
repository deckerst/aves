import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/home_page.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  // untyped map as it is coming from the platform
  final Map? intentData;

  const HomePage({
    Key? key,
    this.intentData,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AvesEntry? _viewerEntry;
  String? _shortcutRouteName, _shortcutSearchQuery;
  List<String>? _shortcutFilters;

  static const allowedShortcutRoutes = [CollectionPage.routeName, AlbumListPage.routeName, SearchPage.routeName];

  @override
  void initState() {
    super.initState();
    _setup();
    imageCache!.maximumSizeBytes = 512 * (1 << 20);
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
      unawaited(androidFileUtils.initAppNames());
    }

    var appMode = AppMode.main;
    final intentData = widget.intentData ?? await ViewerService.getIntentData();
    if (intentData.isNotEmpty) {
      final action = intentData['action'];
      await reportService.log('Intent action=$action');
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
          appMode = AppMode.pickExternal;
          // TODO TLAD apply pick mimetype(s)
          // some apps define multiple types, separated by a space (maybe other signs too, like `,` `;`?)
          String? pickMimeTypes = intentData['mimeType'];
          debugPrint('pick mimeType=$pickMimeTypes');
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
          _shortcutFilters = extraFilters != null ? (extraFilters as List).cast<String>() : null;
      }
    }
    context.read<ValueNotifier<AppMode>>().value = appMode;
    unawaited(reportService.setCustomKey('app_mode', appMode.toString()));

    if (appMode != AppMode.view) {
      debugPrint('Storage check complete in ${stopwatch.elapsed.inMilliseconds}ms');
      unawaited(GlobalSearch.registerCallback());
      unawaited(AnalysisService.registerCallback());
      final source = context.read<CollectionSource>();
      await source.init();
      unawaited(source.refresh());
    }

    // `pushReplacement` is not enough in some edge cases
    // e.g. when opening the viewer in `view` mode should replace a viewer in `main` mode
    unawaited(Navigator.pushAndRemoveUntil(
      context,
      _getRedirectRoute(appMode),
      (route) => false,
    ));
  }

  Future<AvesEntry?> _initViewerEntry({required String uri, required String? mimeType}) async {
    final entry = await mediaFileService.getEntry(uri, mimeType);
    if (entry != null) {
      // cataloguing is essential for coordinates and video rotation
      await entry.catalog(background: false, persist: false, force: false);
    }
    return entry;
  }

  Route _getRedirectRoute(AppMode appMode) {
    if (appMode == AppMode.view) {
      return DirectMaterialPageRoute(
        settings: const RouteSettings(name: EntryViewerPage.routeName),
        builder: (_) => EntryViewerPage(
          initialEntry: _viewerEntry!,
        ),
      );
    }

    String routeName;
    Iterable<CollectionFilter?>? filters;
    if (appMode == AppMode.pickExternal) {
      routeName = CollectionPage.routeName;
    } else {
      routeName = _shortcutRouteName ?? settings.homePage.routeName;
      filters = (_shortcutFilters ?? []).map(CollectionFilter.fromJson);
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
            collection: CollectionLens(
              source: source,
              filters: filters,
            ),
          ),
        );
    }
  }
}
