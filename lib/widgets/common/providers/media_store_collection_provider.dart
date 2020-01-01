import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_file_service.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';

class MediaStoreCollectionProvider extends StatefulWidget {
  final Widget child;

  const MediaStoreCollectionProvider({@required this.child});

  @override
  _MediaStoreCollectionProviderState createState() => _MediaStoreCollectionProviderState();
}

class _MediaStoreCollectionProviderState extends State<MediaStoreCollectionProvider> {
  Future<ImageCollection> collectionFuture;

  static const EventChannel eventChannel = EventChannel('deckers.thibault/aves/mediastore');

  @override
  void initState() {
    super.initState();
    collectionFuture = _create();
  }

  Future<ImageCollection> _create() async {
    final stopwatch = Stopwatch()..start();
    final mediaStoreCollection = ImageCollection(entries: []);
    mediaStoreCollection.groupFactor = settings.collectionGroupFactor;
    mediaStoreCollection.sortFactor = settings.collectionSortFactor;

    await metadataDb.init(); // <20ms
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone(); // <20ms
    final catalogTimeZone = settings.catalogTimeZone;
    if (currentTimeZone != catalogTimeZone) {
      // clear catalog metadata to get correct date/times when moving to a different time zone
      debugPrint('$runtimeType clear catalog metadata to get correct date/times');
      await metadataDb.clearMetadataEntries();
      settings.catalogTimeZone = currentTimeZone;
    }

    eventChannel.receiveBroadcastStream().cast<Map>().listen(
          (entryMap) => mediaStoreCollection.add(ImageEntry.fromMap(entryMap)),
          onDone: () async {
            debugPrint('$runtimeType stream complete in ${stopwatch.elapsed.inMilliseconds}ms');
            mediaStoreCollection.updateSections(); // <50ms
            // TODO reduce setup time until here
            mediaStoreCollection.updateAlbums(); // <50ms
            await mediaStoreCollection.loadCatalogMetadata(); // 650ms
            await mediaStoreCollection.catalogEntries(); // <50ms
            await mediaStoreCollection.loadAddresses(); // 350ms
            await mediaStoreCollection.locateEntries(); // <50ms
            debugPrint('$runtimeType setup end, elapsed=${stopwatch.elapsed}');
          },
          onError: (error) => debugPrint('$runtimeType mediastore stream error=$error'),
        );

    // TODO split image fetch AND/OR cache fetch across sessions
    await ImageFileService.getImageEntries(); // 460ms

    return mediaStoreCollection;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: collectionFuture,
      builder: (futureContext, AsyncSnapshot<ImageCollection> snapshot) {
        final collection = (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) ? snapshot.data : ImageCollection(entries: []);
        return ChangeNotifierProvider<ImageCollection>.value(
          value: collection,
          child: widget.child,
        );
      },
    );
  }
}
