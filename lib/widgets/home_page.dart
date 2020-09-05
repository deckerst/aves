import 'package:aves/main.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/home_page.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/viewer_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/data_providers/media_store_collection_provider.dart';
import 'package:aves/widgets/common/routes.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/fullscreen/fullscreen_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen/screen.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MediaStoreSource _mediaStore;
  ImageEntry _viewerEntry;

  @override
  void initState() {
    super.initState();
    _setup();
    imageCache.maximumSizeBytes = 512 * (1 << 20);
    Screen.keepOn(true);
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

    final intentData = await ViewerService.getIntentData();
    if (intentData != null) {
      final action = intentData['action'];
      switch (action) {
        case 'view':
          AvesApp.mode = AppMode.view;
          _viewerEntry = await _initViewerEntry(
            uri: intentData['uri'],
            mimeType: intentData['mimeType'],
          );
          if (_viewerEntry == null) {
            // fallback to default mode when we fail to retrieve the entry
            AvesApp.mode = AppMode.main;
          }
          break;
        case 'pick':
          AvesApp.mode = AppMode.pick;
          // TODO TLAD apply pick mimetype(s)
          // some apps define multiple types, separated by a space (maybe other signs too, like `,` `;`?)
          String pickMimeTypes = intentData['mimeType'];
          debugPrint('pick mimeType=$pickMimeTypes');
          break;
      }
    }

    if (AvesApp.mode != AppMode.view) {
      _mediaStore = MediaStoreSource();
      await _mediaStore.init();
      unawaited(_mediaStore.refresh());
    }

    unawaited(Navigator.pushReplacement(context, _getRedirectRoute()));
  }

  Future<ImageEntry> _initViewerEntry({@required String uri, @required String mimeType}) async {
    final entry = await ImageFileService.getImageEntry(uri, mimeType);
    if (entry != null) {
      // cataloguing is essential for geolocation and video rotation
      await entry.catalog();
      unawaited(entry.locate());
    }
    return entry;
  }

  Route _getRedirectRoute() {
    switch (AvesApp.mode) {
      case AppMode.view:
        return DirectMaterialPageRoute(
          settings: RouteSettings(name: SingleFullscreenPage.routeName),
          builder: (_) => SingleFullscreenPage(entry: _viewerEntry),
        );
      case AppMode.main:
      case AppMode.pick:
        if (_mediaStore != null) {
          switch (settings.homePage) {
            case HomePageSetting.albums:
              return DirectMaterialPageRoute(
                settings: RouteSettings(name: AlbumListPage.routeName),
                builder: (_) => AlbumListPage(source: _mediaStore),
              );
            case HomePageSetting.collection:
              return DirectMaterialPageRoute(
                settings: RouteSettings(name: CollectionPage.routeName),
                builder: (_) => CollectionPage(
                  CollectionLens(
                    source: _mediaStore,
                    groupFactor: settings.collectionGroupFactor,
                    sortFactor: settings.collectionSortFactor,
                  ),
                ),
              );
          }
        }
    }
    return null;
  }
}
