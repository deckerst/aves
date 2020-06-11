import 'dart:collection';

import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/android_file_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:tuple/tuple.dart';

class DebugPage extends StatefulWidget {
  final CollectionSource source;

  const DebugPage({this.source});

  @override
  State<StatefulWidget> createState() => DebugPageState();
}

class DebugPageState extends State<DebugPage> {
  Future<int> _dbFileSizeLoader;
  Future<List<DateMetadata>> _dbDateLoader;
  Future<List<CatalogMetadata>> _dbMetadataLoader;
  Future<List<AddressDetails>> _dbAddressLoader;
  Future<List<FavouriteRow>> _dbFavouritesLoader;
  Future<List<Tuple2<String, bool>>> _volumePermissionLoader;
  Future<Map> _envLoader;

  List<ImageEntry> get entries => widget.source.rawEntries;

  @override
  void initState() {
    super.initState();
    _startDbReport();
    _volumePermissionLoader = Future.wait<Tuple2<String, bool>>(
      androidFileUtils.storageVolumes.map(
        (volume) => AndroidFileService.hasGrantedPermissionToVolumeRoot(volume.path).then(
          (value) => Tuple2(volume.path, value),
        ),
      ),
    );
    _envLoader = AndroidAppService.getEnv();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Debug'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(OMIcons.whatshot)),
                Tab(icon: Icon(OMIcons.settings)),
                Tab(icon: Icon(OMIcons.sdStorage)),
                Tab(icon: Icon(OMIcons.android)),
              ],
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              children: [
                _buildGeneralTabView(),
                _buildSettingsTabView(),
                _buildStorageTabView(),
                _buildEnvTabView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTabView() {
    final catalogued = entries.where((entry) => entry.isCatalogued);
    final withGps = catalogued.where((entry) => entry.hasGps);
    final located = withGps.where((entry) => entry.isLocated);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Time dilation'),
        Slider(
          value: timeDilation,
          onChanged: (v) => setState(() => timeDilation = v),
          min: 1.0,
          max: 10.0,
          divisions: 9,
          label: '$timeDilation',
        ),
        const Divider(),
        Text('Entries: ${entries.length}'),
        Text('Catalogued: ${catalogued.length}'),
        Text('With GPS: ${withGps.length}'),
        Text('With address: ${located.length}'),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Text('Image cache:\n\t${imageCache.currentSize}/${imageCache.maximumSize} items\n\t${formatFilesize(imageCache.currentSizeBytes)}/${formatFilesize(imageCache.maximumSizeBytes)}'),
            ),
            const SizedBox(width: 8),
            RaisedButton(
              onPressed: () {
                imageCache.clear();
                setState(() {});
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text('SVG cache: ${PictureProvider.cacheCount} items'),
            ),
            const SizedBox(width: 8),
            RaisedButton(
              onPressed: () {
                PictureProvider.clearCache();
                setState(() {});
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              child: Text('Glide disk cache: ?'),
            ),
            const SizedBox(width: 8),
            RaisedButton(
              onPressed: () => ImageFileService.clearSizedThumbnailDiskCache(),
              child: const Text('Clear'),
            ),
          ],
        ),
        const Divider(),
        FutureBuilder(
          future: _dbFileSizeLoader,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB file size: ${formatFilesize(snapshot.data)}'),
                ),
                const SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => metadataDb.reset().then((_) => _startDbReport()),
                  child: const Text('Reset'),
                ),
              ],
            );
          },
        ),
        FutureBuilder(
          future: _dbDateLoader,
          builder: (context, AsyncSnapshot<List<DateMetadata>> snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB date rows: ${snapshot.data.length}'),
                ),
                const SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => metadataDb.clearDates().then((_) => _startDbReport()),
                  child: const Text('Clear'),
                ),
              ],
            );
          },
        ),
        FutureBuilder(
          future: _dbMetadataLoader,
          builder: (context, AsyncSnapshot<List<CatalogMetadata>> snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB metadata rows: ${snapshot.data.length}'),
                ),
                const SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => metadataDb.clearMetadataEntries().then((_) => _startDbReport()),
                  child: const Text('Clear'),
                ),
              ],
            );
          },
        ),
        FutureBuilder(
          future: _dbAddressLoader,
          builder: (context, AsyncSnapshot<List<AddressDetails>> snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB address rows: ${snapshot.data.length}'),
                ),
                const SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => metadataDb.clearAddresses().then((_) => _startDbReport()),
                  child: const Text('Clear'),
                ),
              ],
            );
          },
        ),
        FutureBuilder(
          future: _dbFavouritesLoader,
          builder: (context, AsyncSnapshot<List<FavouriteRow>> snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB favourite rows: ${snapshot.data.length} (${favourites.count} in memory)'),
                ),
                const SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => favourites.clear().then((_) => _startDbReport()),
                  child: const Text('Clear'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTabView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Settings'),
            ),
            const SizedBox(width: 8),
            RaisedButton(
              onPressed: () => settings.reset().then((_) => setState(() {})),
              child: const Text('Reset'),
            ),
          ],
        ),
        InfoRowGroup({
          'collectionGroupFactor': '${settings.collectionGroupFactor}',
          'collectionSortFactor': '${settings.collectionSortFactor}',
          'collectionTileExtent': '${settings.collectionTileExtent}',
          'infoMapZoom': '${settings.infoMapZoom}',
        }),
      ],
    );
  }

  Widget _buildStorageTabView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FutureBuilder(
          future: _volumePermissionLoader,
          builder: (context, AsyncSnapshot<List<Tuple2<String, bool>>> snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
            final permissions = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...androidFileUtils.storageVolumes.expand((v) => [
                      Text(v.path),
                      InfoRowGroup({
                        'description': '${v.description}',
                        'isEmulated': '${v.isEmulated}',
                        'isPrimary': '${v.isPrimary}',
                        'isRemovable': '${v.isRemovable}',
                        'state': '${v.state}',
                        'permission': '${permissions.firstWhere((t) => t.item1 == v.path, orElse: () => null)?.item2 ?? false}',
                      }),
                      const Divider(),
                    ])
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEnvTabView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FutureBuilder(
          future: _envLoader,
          builder: (context, AsyncSnapshot<Map> snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
            final data = SplayTreeMap.of(snapshot.data.map((k, v) => MapEntry(k.toString(), v?.toString() ?? 'null')));
            return InfoRowGroup(data);
          },
        ),
      ],
    );
  }

  void _startDbReport() {
    _dbFileSizeLoader = metadataDb.dbFileSize();
    _dbDateLoader = metadataDb.loadDates();
    _dbMetadataLoader = metadataDb.loadMetadataEntries();
    _dbAddressLoader = metadataDb.loadAddresses();
    _dbFavouritesLoader = metadataDb.loadFavourites();
    setState(() {});
  }
}
