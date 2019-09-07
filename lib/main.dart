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
import 'package:permission_handler/permission_handler.dart';

void main() async {
  await settings.init();
  await androidFileUtils.init();
  await IconUtils.init();
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

  ImageCollection localMediaCollection = ImageCollection(
    entries: List(),
    groupFactor: settings.collectionGroupFactor,
    sortFactor: settings.collectionSortFactor,
  );

  @override
  void initState() {
    super.initState();
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    setup();
  }

  setup() async {
    final permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
      SystemNavigator.pop();
      return;
    }

    await metadataDb.init();

    eventChannel.receiveBroadcastStream().cast<Map>().listen(
          (entryMap) => localMediaCollection.add(ImageEntry.fromMap(entryMap)),
          onDone: () async {
            debugPrint('mediastore stream done');
            localMediaCollection.updateSections();
            localMediaCollection.updateAlbums();
            await localMediaCollection.loadCatalogMetadata();
            await localMediaCollection.catalogEntries();
            await localMediaCollection.loadAddresses();
            await localMediaCollection.locateEntries();
          },
          onError: (error) => debugPrint('mediastore stream error=$error'),
        );
    await ImageFileService.getImageEntries();
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
