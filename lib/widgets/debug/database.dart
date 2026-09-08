import 'package:aves/locale/aves_locale.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/model/vaults/details.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/model/viewer/video_playback.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class DebugAppDatabaseSection extends StatefulWidget {
  const new({super.key});

  @override
  State<DebugAppDatabaseSection> createState() => _DebugAppDatabaseSectionState();
}

class _DebugAppDatabaseSectionState extends State<DebugAppDatabaseSection> with AutomaticKeepAliveClientMixin {
  late Future<int> _fileSizeLoader;
  late Future<Iterable<AvesEntry>> _entryLoader;
  late Future<Map<int?, int?>> _dateLoader;
  late Future<Iterable<CatalogMetadata>> _metadataLoader;
  late Future<Iterable<AddressDetails>> _addressLoader;
  late Future<Iterable<TrashDetails>> _trashLoader;
  late Future<Iterable<VaultDetails>> _vaultLoader;
  late Future<Iterable<FavouriteRow>> _favouriteLoader;
  late Future<Iterable<CoverRow>> _coverLoader;
  late Future<Iterable<DynamicAlbumRow>> _dynamicAlbumLoader;
  late Future<Iterable<VideoPlaybackRow>> _videoPlaybackLoader;
  late Future<Iterable<String>> _debugLoader;

  @override
  void initState() {
    super.initState();
    _startDbReport();
  }

  @override
  void dispose() {
    _disposeLoadedContent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AvesExpansionTile(
      title: 'Database',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              FutureBuilder<int>(
                future: _fileSizeLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('DB file size: ${formatFileSize(AvesLocale.ascii, snapshot.data!)}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => localMediaDb.reset().then((_) => _reload()),
                        child: const Text('Reset'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Iterable<AvesEntry>>(
                future: _entryLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  final entries = snapshot.data!;
                  final byOrigin = groupBy<AvesEntry, int>(entries, (entry) => entry.origin);
                  return Row(
                    children: [
                      Expanded(
                        child: Text('entry rows: ${entries.length} (${byOrigin.entries.map((kv) => '${kv.key}: ${kv.value.length}').join(', ')})'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => localMediaDb.clearEntries().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Map<int?, int?>>(
                future: _dateLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('date rows: ${snapshot.data!.length}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => localMediaDb.clearDates().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Iterable>(
                future: _metadataLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('metadata rows: ${snapshot.data!.length}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => localMediaDb.clearCatalogMetadata().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Iterable>(
                future: _addressLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('address rows: ${snapshot.data!.length}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => localMediaDb.clearAddresses().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Iterable>(
                future: _trashLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('trash rows: ${snapshot.data!.length}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => localMediaDb.clearTrashDetails().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Iterable>(
                future: _vaultLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('vault rows: ${snapshot.data!.length} (${vaults.all.length} in memory)'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => vaults.clear().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Iterable>(
                future: _favouriteLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('favourite rows: ${snapshot.data!.length} (${favourites.count} in memory)'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => favourites.clear().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Iterable>(
                future: _coverLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('covers: ${snapshot.data!.length} rows\n(${covers.count} in memory)'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => localMediaDb.loadAllCovers().then((list) {
                          debugPrint('covers dump start');
                          list.forEach((v) => debugPrint('  $v'));
                          debugPrint('covers albums dump end');
                        }),
                        child: const Text('Dump'),
                      ),
                      ElevatedButton(
                        onPressed: () => covers.clear().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Iterable>(
                future: _dynamicAlbumLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('dynamic albums: ${snapshot.data!.length} rows\n(${dynamicAlbums.count} in memory)'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => localMediaDb.loadAllDynamicAlbums().then((list) {
                          debugPrint('dynamic albums dump start');
                          list.forEach((v) => debugPrint('  $v'));
                          debugPrint('dynamic albums dump end');
                        }),
                        child: const Text('Dump'),
                      ),
                      ElevatedButton(
                        onPressed: () => dynamicAlbums.clear().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Iterable>(
                future: _videoPlaybackLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('video playback rows: ${snapshot.data!.length}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => localMediaDb.clearVideoPlayback().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Iterable>(
                future: _debugLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('debug log rows: ${snapshot.data!.length}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => localMediaDb.clearDebugLog().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _reload() async {
    await _disposeLoadedContent();
    _startDbReport();
  }

  void _startDbReport() {
    _fileSizeLoader = localMediaDb.dbFileSize();
    _entryLoader = localMediaDb.loadEntries();
    _dateLoader = localMediaDb.loadDates();
    _metadataLoader = localMediaDb.loadCatalogMetadata();
    _addressLoader = localMediaDb.loadAddresses();
    _trashLoader = localMediaDb.loadAllTrashDetails();
    _vaultLoader = localMediaDb.loadAllVaults();
    _favouriteLoader = localMediaDb.loadAllFavourites();
    _coverLoader = localMediaDb.loadAllCovers();
    _dynamicAlbumLoader = localMediaDb.loadAllDynamicAlbums();
    _videoPlaybackLoader = localMediaDb.loadAllVideoPlayback();
    _debugLoader = localMediaDb.loadAllDebugLog();
    setState(() {});
  }

  Future<void> _disposeLoadedContent() async {
    (await _entryLoader).forEach((v) => v.dispose());
  }

  @override
  bool get wantKeepAlive => true;
}
