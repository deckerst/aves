import 'package:aves/model/image_decode_service.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_storage_service.dart';
import 'package:aves/widgets/album/thumbnail_collection.dart';
import 'package:aves/widgets/common/fake_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aves',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.amberAccent,
        scaffoldBackgroundColor: Colors.grey[900],
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

  List<ImageEntry> entries = List();
  bool done = false;

  @override
  void initState() {
    super.initState();
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    setup();
  }

  setup() async {
    await metadataDb.init();

    eventChannel.receiveBroadcastStream().cast<Map>().listen(
          (entryMap) => setState(() => entries.add(ImageEntry.fromMap(entryMap))),
      onDone: () {
        debugPrint('mediastore stream done');
        setState(() => done = true);
      },
      onError: (error) => debugPrint('mediastore stream error=$error'),
    );
    await ImageDecodeService.getImageEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // fake app bar so that content is safe from status bar, even though we use a SliverAppBar
      appBar: FakeAppBar(),
      body: ThumbnailCollection(
        entries: entries,
        done: done,
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
