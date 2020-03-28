import 'package:aves/model/collection_source.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DebugPage extends StatefulWidget {
  final CollectionSource source;

  const DebugPage({this.source});

  @override
  State<StatefulWidget> createState() => DebugPageState();
}

class DebugPageState extends State<DebugPage> {
  Future<int> _dbFileSizeLoader;
  Future<List<CatalogMetadata>> _dbMetadataLoader;
  Future<List<AddressDetails>> _dbAddressLoader;
  Future<List<FavouriteRow>> _dbFavouritesLoader;

  List<ImageEntry> get entries => widget.source.entries;

  @override
  void initState() {
    super.initState();
    _startDbReport();
  }

  @override
  Widget build(BuildContext context) {
    final catalogued = entries.where((entry) => entry.isCatalogued);
    final withGps = catalogued.where((entry) => entry.hasGps);
    final located = withGps.where((entry) => entry.isLocated);
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debug'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              const Text('Settings'),
              Text('collectionGroupFactor: ${settings.collectionGroupFactor}'),
              Text('collectionSortFactor: ${settings.collectionSortFactor}'),
              Text('infoMapZoom: ${settings.infoMapZoom}'),
              const Divider(),
              Text('Entries: ${entries.length}'),
              Text('Catalogued: ${catalogued.length}'),
              Text('With GPS: ${withGps.length}'),
              Text('With address: ${located.length}'),
              const Divider(),
              RaisedButton(
                onPressed: () async {
                  await metadataDb.reset();
                  _startDbReport();
                },
                child: const Text('Reset DB'),
              ),
              FutureBuilder(
                future: _dbFileSizeLoader,
                builder: (context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());
                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
                  return Text('DB file size: ${formatFilesize(snapshot.data)}');
                },
              ),
              FutureBuilder(
                future: _dbMetadataLoader,
                builder: (context, AsyncSnapshot<List<CatalogMetadata>> snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());
                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
                  return Text('DB metadata rows: ${snapshot.data.length}');
                },
              ),
              FutureBuilder(
                future: _dbAddressLoader,
                builder: (context, AsyncSnapshot<List<AddressDetails>> snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());
                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
                  return Text('DB address rows: ${snapshot.data.length}');
                },
              ),
              FutureBuilder(
                future: _dbFavouritesLoader,
                builder: (context, AsyncSnapshot<List<FavouriteRow>> snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());
                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
                  return Text('DB favourite rows: ${snapshot.data.length} (${favourites.count} in memory)');
                },
              ),
              const Divider(),
              Text('Image cache: ${imageCache.currentSize} items, ${formatFilesize(imageCache.currentSizeBytes)}'),
              Text('SVG cache: ${PictureProvider.cacheCount} items'),
              const Divider(),
              const Text('Time dilation'),
              Slider(
                value: timeDilation,
                onChanged: (v) => setState(() => timeDilation = v),
                min: 1.0,
                max: 10.0,
                divisions: 9,
                label: '$timeDilation',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startDbReport() {
    _dbFileSizeLoader = metadataDb.dbFileSize();
    _dbMetadataLoader = metadataDb.loadMetadataEntries();
    _dbAddressLoader = metadataDb.loadAddresses();
    _dbFavouritesLoader = metadataDb.loadFavourites();
    setState(() {});
  }
}
