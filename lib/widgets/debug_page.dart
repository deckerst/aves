import 'dart:collection';

import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class DebugPage extends StatefulWidget {
  static const routeName = '/debug';

  final CollectionSource source;

  const DebugPage({this.source});

  @override
  State<StatefulWidget> createState() => DebugPageState();
}

class DebugPageState extends State<DebugPage> {
  Future<int> _dbFileSizeLoader;
  Future<List<ImageEntry>> _dbEntryLoader;
  Future<List<DateMetadata>> _dbDateLoader;
  Future<List<CatalogMetadata>> _dbMetadataLoader;
  Future<List<AddressDetails>> _dbAddressLoader;
  Future<List<FavouriteRow>> _dbFavouritesLoader;
  Future<Map> _envLoader;

  List<ImageEntry> get entries => widget.source.rawEntries;

  @override
  void initState() {
    super.initState();
    _startDbReport();
    _envLoader = AndroidAppService.getEnv();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Debug'),
            bottom: TabBar(
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
      padding: EdgeInsets.all(16),
      children: [
        Text('Time dilation'),
        Slider(
          value: timeDilation,
          onChanged: (v) => setState(() => timeDilation = v),
          min: 1.0,
          max: 10.0,
          divisions: 9,
          label: '$timeDilation',
        ),
        Divider(),
        Row(
          children: [
            Expanded(
              child: Text('Crashlytics'),
            ),
            SizedBox(width: 8),
            RaisedButton(
              onPressed: FirebaseCrashlytics.instance.crash,
              child: Text('Crash'),
            ),
          ],
        ),
        Text('Firebase data collection: ${Firebase.app().isAutomaticDataCollectionEnabled ? 'enabled' : 'disabled'}'),
        Text('Crashlytics collection: ${FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled ? 'enabled' : 'disabled'}'),
        Divider(),
        Text('Entries: ${entries.length}'),
        Text('Catalogued: ${catalogued.length}'),
        Text('With GPS: ${withGps.length}'),
        Text('With address: ${located.length}'),
        Divider(),
        Row(
          children: [
            Expanded(
              child: Text('Image cache:\n\t${imageCache.currentSize}/${imageCache.maximumSize} items\n\t${formatFilesize(imageCache.currentSizeBytes)}/${formatFilesize(imageCache.maximumSizeBytes)}'),
            ),
            SizedBox(width: 8),
            RaisedButton(
              onPressed: () {
                imageCache.clear();
                setState(() {});
              },
              child: Text('Clear'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text('SVG cache: ${PictureProvider.cacheCount} items'),
            ),
            SizedBox(width: 8),
            RaisedButton(
              onPressed: () {
                PictureProvider.clearCache();
                setState(() {});
              },
              child: Text('Clear'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text('Glide disk cache: ?'),
            ),
            SizedBox(width: 8),
            RaisedButton(
              onPressed: ImageFileService.clearSizedThumbnailDiskCache,
              child: Text('Clear'),
            ),
          ],
        ),
        Divider(),
        FutureBuilder<int>(
          future: _dbFileSizeLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB file size: ${formatFilesize(snapshot.data)}'),
                ),
                SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => metadataDb.reset().then((_) => _startDbReport()),
                  child: Text('Reset'),
                ),
              ],
            );
          },
        ),
        FutureBuilder<List>(
          future: _dbEntryLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB entry rows: ${snapshot.data.length}'),
                ),
                SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => metadataDb.clearEntries().then((_) => _startDbReport()),
                  child: Text('Clear'),
                ),
              ],
            );
          },
        ),
        FutureBuilder<List>(
          future: _dbDateLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB date rows: ${snapshot.data.length}'),
                ),
                SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => metadataDb.clearDates().then((_) => _startDbReport()),
                  child: Text('Clear'),
                ),
              ],
            );
          },
        ),
        FutureBuilder<List>(
          future: _dbMetadataLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB metadata rows: ${snapshot.data.length}'),
                ),
                SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => metadataDb.clearMetadataEntries().then((_) => _startDbReport()),
                  child: Text('Clear'),
                ),
              ],
            );
          },
        ),
        FutureBuilder<List>(
          future: _dbAddressLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB address rows: ${snapshot.data.length}'),
                ),
                SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => metadataDb.clearAddresses().then((_) => _startDbReport()),
                  child: Text('Clear'),
                ),
              ],
            );
          },
        ),
        FutureBuilder<List>(
          future: _dbFavouritesLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: Text('DB favourite rows: ${snapshot.data.length} (${favourites.count} in memory)'),
                ),
                SizedBox(width: 8),
                RaisedButton(
                  onPressed: () => favourites.clear().then((_) => _startDbReport()),
                  child: Text('Clear'),
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
      padding: EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Settings'),
            ),
            SizedBox(width: 8),
            RaisedButton(
              onPressed: () => settings.reset().then((_) => setState(() {})),
              child: Text('Reset'),
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
      padding: EdgeInsets.all(16),
      children: [
        ...androidFileUtils.storageVolumes.expand((v) => [
              Text(v.path),
              InfoRowGroup({
                'description': '${v.description}',
                'isEmulated': '${v.isEmulated}',
                'isPrimary': '${v.isPrimary}',
                'isRemovable': '${v.isRemovable}',
                'state': '${v.state}',
              }),
              Divider(),
            ])
      ],
    );
  }

  Widget _buildEnvTabView() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        FutureBuilder<Map>(
          future: _envLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            final data = SplayTreeMap.of(snapshot.data.map((k, v) => MapEntry(k.toString(), v?.toString() ?? 'null')));
            return InfoRowGroup(data);
          },
        ),
      ],
    );
  }

  void _startDbReport() {
    _dbFileSizeLoader = metadataDb.dbFileSize();
    _dbEntryLoader = metadataDb.loadEntries();
    _dbDateLoader = metadataDb.loadDates();
    _dbMetadataLoader = metadataDb.loadMetadataEntries();
    _dbAddressLoader = metadataDb.loadAddresses();
    _dbFavouritesLoader = metadataDb.loadFavourites();
    setState(() {});
  }
}
