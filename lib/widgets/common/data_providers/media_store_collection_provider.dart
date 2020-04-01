import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/model/favourite_repo.dart';
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
  Future<CollectionLens> collectionFuture;

  static const EventChannel eventChannel = EventChannel('deckers.thibault/aves/mediastore');

  @override
  void initState() {
    super.initState();
    collectionFuture = _create();
  }

  Future<CollectionLens> _create() async {
    final stopwatch = Stopwatch()..start();
    final mediaStoreSource = CollectionSource();
    final mediaStoreBaseLens = CollectionLens(
      source: mediaStoreSource,
      groupFactor: settings.collectionGroupFactor,
      sortFactor: settings.collectionSortFactor,
    );

    await metadataDb.init(); // <20ms
    await favourites.init();
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone(); // <20ms
    final catalogTimeZone = settings.catalogTimeZone;
    if (currentTimeZone != catalogTimeZone) {
      // clear catalog metadata to get correct date/times when moving to a different time zone
      debugPrint('$runtimeType clear catalog metadata to get correct date/times');
      await metadataDb.clearMetadataEntries();
      settings.catalogTimeZone = currentTimeZone;
    }

    final allEntries = <ImageEntry>[];
    eventChannel.receiveBroadcastStream().cast<Map>().listen(
          (entryMap) => allEntries.add(ImageEntry.fromMap(entryMap)),
          onDone: () async {
            debugPrint('$runtimeType stream complete in ${stopwatch.elapsed.inMilliseconds}ms');
            mediaStoreSource.addAll(allEntries);
            // TODO reduce setup time until here
            mediaStoreSource.updateAlbums(); // <50ms
            await mediaStoreSource.loadCatalogMetadata(); // 650ms
            await mediaStoreSource.catalogEntries(); // <50ms
            await mediaStoreSource.loadAddresses(); // 350ms
            await mediaStoreSource.locateEntries(); // <50ms
            debugPrint('$runtimeType setup end, elapsed=${stopwatch.elapsed}');
          },
          onError: (error) => debugPrint('$runtimeType mediastore stream error=$error'),
        );

    // TODO split image fetch AND/OR cache fetch across sessions
    await ImageFileService.getImageEntries(); // 460ms

    return mediaStoreBaseLens;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: collectionFuture,
      builder: (futureContext, AsyncSnapshot<CollectionLens> snapshot) {
        final collection = (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) ? snapshot.data : CollectionLens.empty();
        return ChangeNotifierProvider<CollectionLens>.value(
          value: collection,
          child: widget.child,
        );
      },
    );
  }
}
