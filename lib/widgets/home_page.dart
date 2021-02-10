import 'package:aves/main.dart';
import 'package:aves/model/availability.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/home_page.dart';
import 'package:aves/model/settings/screen_on.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/viewer_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/search/search_page.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  // untyped map as it is coming from the platform
  final Map intentData;

  const HomePage({this.intentData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AvesEntry _viewerEntry;
  String _shortcutRouteName;
  List<String> _shortcutFilters;

  static const allowedShortcutRoutes = [CollectionPage.routeName, AlbumListPage.routeName, SearchPage.routeName];

  @override
  void initState() {
    super.initState();
    _setup();
    imageCache.maximumSizeBytes = 512 * (1 << 20);
    settings.keepScreenOn.apply();
  }

  @override
  Widget build(BuildContext context) => Scaffold();

  Future<void> _setup() async {
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
    unawaited(androidFileUtils.initAppNames());

    AvesApp.mode = AppMode.main;
    final intentData = widget.intentData ?? await ViewerService.getIntentData();
    if (intentData?.isNotEmpty == true) {
      final action = intentData['action'];
      switch (action) {
        case 'view':
          _viewerEntry = await _initViewerEntry(
            uri: intentData['uri'],
            mimeType: intentData['mimeType'],
          );
          if (_viewerEntry != null) {
            AvesApp.mode = AppMode.view;
          }
          break;
        case 'pick':
          AvesApp.mode = AppMode.pick;
          // TODO TLAD apply pick mimetype(s)
          // some apps define multiple types, separated by a space (maybe other signs too, like `,` `;`?)
          String pickMimeTypes = intentData['mimeType'];
          debugPrint('pick mimeType=$pickMimeTypes');
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
    unawaited(FirebaseCrashlytics.instance.setCustomKey('app_mode', AvesApp.mode.toString()));

    if (AvesApp.mode != AppMode.view) {
      final source = context.read<CollectionSource>();
      await source.init();
      unawaited(source.refresh());
    }

    unawaited(Navigator.pushReplacement(context, _getRedirectRoute()));
  }

  Future<AvesEntry> _initViewerEntry({@required String uri, @required String mimeType}) async {
    final entry = await ImageFileService.getEntry(uri, mimeType);
    if (entry != null) {
      // cataloguing is essential for coordinates and video rotation
      await entry.catalog();
      // locating is fine in the background
      unawaited(availability.canGeolocate.then((connected) {
        if (connected) {
          entry.locate();
        }
      }));
    }
    return entry;
  }

  Route _getRedirectRoute() {
    if (AvesApp.mode == AppMode.view) {
      return DirectMaterialPageRoute(
        settings: RouteSettings(name: EntryViewerPage.routeName),
        builder: (_) => EntryViewerPage(
          initialEntry: _viewerEntry,
        ),
      );
    }

    String routeName;
    Iterable<CollectionFilter> filters;
    if (AvesApp.mode == AppMode.pick) {
      routeName = CollectionPage.routeName;
    } else {
      routeName = _shortcutRouteName ?? settings.homePage.routeName;
      filters = (_shortcutFilters ?? []).map(CollectionFilter.fromJson);
    }
    final source = context.read<CollectionSource>();
    switch (routeName) {
      case AlbumListPage.routeName:
        return DirectMaterialPageRoute(
          settings: RouteSettings(name: AlbumListPage.routeName),
          builder: (_) => AlbumListPage(source: source),
        );
      case SearchPage.routeName:
        return SearchPageRoute(
          delegate: CollectionSearchDelegate(source: source),
        );
      case CollectionPage.routeName:
      default:
        return DirectMaterialPageRoute(
          settings: RouteSettings(name: CollectionPage.routeName),
          builder: (_) => CollectionPage(
            CollectionLens(
              source: source,
              filters: filters,
            ),
          ),
        );
    }
  }
}
