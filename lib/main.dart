import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/viewer_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/album/collection_page.dart';
import 'package:aves/widgets/common/data_providers/media_store_collection_provider.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/fullscreen_page.dart';
import 'package:aves/widgets/welcome.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen/screen.dart';

void main() {
//  HttpClient.enableTimelineLogging = true; // enable network traffic logging
//  debugPrintGestureArenaDiagnostics = true;
  Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(AvesApp());
}

enum AppMode { main, pick, view }

class AvesApp extends StatefulWidget {
  static AppMode mode = AppMode.main;

  @override
  _AvesAppState createState() => _AvesAppState();
}

class _AvesAppState extends State<AvesApp> {
  Future<void> _appSetup;

  @override
  void initState() {
    super.initState();
    _appSetup = settings.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aves',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.indigoAccent,
        scaffoldBackgroundColor: Colors.grey[900],
        tooltipTheme: const TooltipThemeData(
          verticalOffset: 32,
        ),
        appBarTheme: const AppBarTheme(
          textTheme: TextTheme(
            headline6: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Concourse Caps',
            ),
          ),
        ),
      ),
      home: FutureBuilder(
        future: _appSetup,
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) return const Icon(AIcons.error);
          if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
          return settings.hasAcceptedTerms ? const HomePage() : const WelcomePage();
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MediaStoreSource _mediaStore;
  ImageEntry _viewerEntry;
  Future<void> _appSetup;

  @override
  void initState() {
    super.initState();
    _appSetup = _setup();
    imageCache.maximumSizeBytes = 512 * (1 << 20);
    Screen.keepOn(true);
  }

  Future<void> _setup() async {
    debugPrint('$runtimeType _setup');

    // TODO reduce permission check time
    final permissions = await [
      Permission.storage,
      // to access media with unredacted metadata with scoped storage (Android 10+)
      Permission.accessMediaLocation,
    ].request(); // 350ms
    if (permissions[Permission.storage] != PermissionStatus.granted) {
      unawaited(SystemNavigator.pop());
      return;
    }

    // TODO notify when icons are ready for drawer and section header refresh
    await androidFileUtils.init(); // 170ms

    final intentData = await ViewerService.getIntentData();
    if (intentData != null) {
      final action = intentData['action'];
      switch (action) {
        case 'view':
          AvesApp.mode = AppMode.view;
          await _initViewerEntry(
            uri: intentData['uri'],
            mimeType: intentData['mimeType'],
          );
          break;
        case 'pick':
          AvesApp.mode = AppMode.pick;
          break;
      }
    }

    if (AvesApp.mode != AppMode.view) {
      _mediaStore = MediaStoreSource();
      unawaited(_mediaStore.fetch());
    }
  }

  Future<void> _initViewerEntry({@required String uri, @required String mimeType}) async {
    _viewerEntry = await ImageFileService.getImageEntry(uri, mimeType);
    // cataloguing is essential for geolocation and video rotation
    await _viewerEntry.catalog();
    unawaited(_viewerEntry.locate());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _appSetup,
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) return const Icon(AIcons.error);
          if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
          debugPrint('$runtimeType app setup future complete');
          if (AvesApp.mode == AppMode.view) {
            return SingleFullscreenPage(entry: _viewerEntry);
          }
          if (_mediaStore != null) {
            return CollectionPage(CollectionLens(
              source: _mediaStore.source,
              groupFactor: settings.collectionGroupFactor,
              sortFactor: settings.collectionSortFactor,
            ));
          }
          return const SizedBox.shrink();
        });
  }
}
