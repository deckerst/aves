import 'package:aves/model/image_decode_service.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/widgets/album/all_collection_page.dart';
import 'package:aves/widgets/common/fake_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
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

  @override
  void initState() {
    super.initState();
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    setup();
  }

  setup() async {
    await metadataDb.init();

    eventChannel.receiveBroadcastStream().cast<Map>().listen(
          (entryMap) => entries.add(ImageEntry.fromMap(entryMap)),
          onDone: () async {
            debugPrint('mediastore stream done');
            await loadCatalogMetadata();
            setState(() {});
            await catalogEntries();
            setState(() {});
            await loadAddresses();
            await locateEntries();
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
      body: AllCollectionPage(entries: entries),
      resizeToAvoidBottomInset: false,
    );
  }

  loadCatalogMetadata() async {
    debugPrint('$runtimeType loadCatalogMetadata start');
    final start = DateTime.now();
    final saved = await metadataDb.loadMetadataEntries();
    entries.forEach((entry) {
      final contentId = entry.contentId;
      if (contentId != null) {
        entry.catalogMetadata = saved.firstWhere((metadata) => metadata.contentId == contentId, orElse: () => null);
      }
    });
    debugPrint('$runtimeType loadCatalogMetadata complete in ${DateTime.now().difference(start).inSeconds}s with ${saved.length} saved entries');
  }

  loadAddresses() async {
    debugPrint('$runtimeType loadAddresses start');
    final start = DateTime.now();
    final saved = await metadataDb.loadAddresses();
    entries.forEach((entry) {
      final contentId = entry.contentId;
      if (contentId != null) {
        entry.addressDetails = saved.firstWhere((address) => address.contentId == contentId, orElse: () => null);
      }
    });
    debugPrint('$runtimeType loadAddresses complete in ${DateTime.now().difference(start).inSeconds}s with ${saved.length} saved entries');
  }

  catalogEntries() async {
    debugPrint('$runtimeType catalogEntries start');
    final start = DateTime.now();
    final uncataloguedEntries = entries.where((entry) => !entry.isCatalogued);
    final newMetadata = List<CatalogMetadata>();
    await Future.forEach<ImageEntry>(uncataloguedEntries, (entry) async {
      await entry.catalog();
      newMetadata.add(entry.catalogMetadata);
    });
    debugPrint('$runtimeType catalogEntries complete in ${DateTime.now().difference(start).inSeconds}s with ${newMetadata.length} new entries');

    // sort with more accurate date
    entries.sort((a, b) => b.bestDate.compareTo(a.bestDate));

    metadataDb.saveMetadata(List.unmodifiable(newMetadata));
  }

  locateEntries() async {
    debugPrint('$runtimeType locateEntries start');
    final start = DateTime.now();
    final unlocatedEntries = entries.where((entry) => !entry.isLocated);
    final newAddresses = List<AddressDetails>();
    await Future.forEach<ImageEntry>(unlocatedEntries, (entry) async {
      await entry.locate();
      newAddresses.add(entry.addressDetails);
      if (newAddresses.length >= 50) {
        metadataDb.saveAddresses(List.unmodifiable(newAddresses));
        newAddresses.clear();
      }
    });
    debugPrint('$runtimeType locateEntries complete in ${DateTime.now().difference(start).inSeconds}s');
  }
}
