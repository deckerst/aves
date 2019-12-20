import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_file_service.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/album/all_collection_drawer.dart';
import 'package:aves/widgets/album/all_collection_page.dart';
import 'package:aves/widgets/common/fake_app_bar.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen/screen.dart';

final stopwatch = Stopwatch()..start();

void main() {
  debugPrint('main start, elapsed=${stopwatch.elapsed}');
  // initialize binding/plugins to configure Skia before `runApp`
  WidgetsFlutterBinding.ensureInitialized(); // 220ms
//  debugPrint('main WidgetsFlutterBinding.ensureInitialized done, elapsed=${stopwatch.elapsed}');
  // configure Skia cache to prevent zoomed images becoming black, cf https://github.com/flutter/flutter/issues/36191
  SystemChannels.skia.invokeMethod('Skia.setResourceCacheMaxBytes', 512 * (1 << 20)); // <20ms
//  debugPrint('main Skia.setResourceCacheMaxBytes done, elapsed=${stopwatch.elapsed}');
  runApp(AvesApp());
}

class AvesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aves',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.indigoAccent,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          textTheme: TextTheme(
            title: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Concourse Caps',
            ),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const EventChannel eventChannel = EventChannel('deckers.thibault/aves/mediastore');

  ImageCollection localMediaCollection = ImageCollection(entries: List());

  @override
  void initState() {
    super.initState();
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    setup();
    Screen.keepOn(true);
  }

  Future<void> setup() async {
    debugPrint('$runtimeType setup start, elapsed=${stopwatch.elapsed}');
    // TODO reduce permission check time
    final permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]); // 350ms
    if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
      unawaited(SystemNavigator.pop());
      return;
    }
//    debugPrint('$runtimeType setup permission check done, elapsed=${stopwatch.elapsed}');

    androidFileUtils.init();
//    debugPrint('$runtimeType setup androidFileUtils.init done, elapsed=${stopwatch.elapsed}');
    // TODO notify when icons are ready for drawer and section header refresh
    unawaited(IconUtils.init()); // 170ms
//    debugPrint('$runtimeType setup IconUtils.init done, elapsed=${stopwatch.elapsed}');
    await settings.init(); // <20ms
    localMediaCollection.groupFactor = settings.collectionGroupFactor;
    localMediaCollection.sortFactor = settings.collectionSortFactor;
    debugPrint('$runtimeType setup settings.init done, elapsed=${stopwatch.elapsed}');

    await metadataDb.init(); // <20ms
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone(); // <20ms
    final catalogTimeZone = settings.catalogTimeZone;
    if (currentTimeZone != catalogTimeZone) {
      // clear catalog metadata to get correct date/times when moving to a different time zone
      debugPrint('$runtimeType clear catalog metadata to get correct date/times');
      await metadataDb.clearMetadataEntries();
      settings.catalogTimeZone = currentTimeZone;
    }
//    debugPrint('$runtimeType setup metadataDb.init done, elapsed=${stopwatch.elapsed}');

    eventChannel.receiveBroadcastStream().cast<Map>().listen(
          (entryMap) => localMediaCollection.add(ImageEntry.fromMap(entryMap)),
          onDone: () async {
            debugPrint('$runtimeType mediastore stream done, elapsed=${stopwatch.elapsed}');
            localMediaCollection.updateSections(); // <50ms
            // TODO reduce setup time until here
            localMediaCollection.updateAlbums(); // <50ms
            await localMediaCollection.loadCatalogMetadata(); // 650ms
            await localMediaCollection.catalogEntries(); // <50ms
            await localMediaCollection.loadAddresses(); // 350ms
            await localMediaCollection.locateEntries(); // <50ms
            debugPrint('$runtimeType setup end, elapsed=${stopwatch.elapsed}');
          },
          onError: (error) => debugPrint('$runtimeType mediastore stream error=$error'),
        );
//    debugPrint('$runtimeType setup fetch images, elapsed=${stopwatch.elapsed}');
    // TODO split image fetch AND/OR cache fetch across sessions
    await ImageFileService.getImageEntries(); // 460ms
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // fake app bar so that content is safe from status bar, even though we use a SliverAppBar
      appBar: FakeAppBar(),
      body: AllCollectionPage(collection: localMediaCollection),
      drawer: AllCollectionDrawer(collection: localMediaCollection),
      resizeToAvoidBottomInset: false,
    );
  }
}
