import 'package:aves/model/covers.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/model/vaults/details.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/model/video_playback.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class DebugAppDatabaseSection extends StatefulWidget {
  const DebugAppDatabaseSection({super.key});

  @override
  State<DebugAppDatabaseSection> createState() => _DebugAppDatabaseSectionState();
}

class _DebugAppDatabaseSectionState extends State<DebugAppDatabaseSection> with AutomaticKeepAliveClientMixin {
  late Future<int> _dbFileSizeLoader;
  late Future<Set<AvesEntry>> _dbEntryLoader;
  late Future<Map<int?, int?>> _dbDateLoader;
  late Future<Set<CatalogMetadata>> _dbMetadataLoader;
  late Future<Set<AddressDetails>> _dbAddressLoader;
  late Future<Set<TrashDetails>> _dbTrashLoader;
  late Future<Set<VaultDetails>> _dbVaultsLoader;
  late Future<Set<FavouriteRow>> _dbFavouritesLoader;
  late Future<Set<CoverRow>> _dbCoversLoader;
  late Future<Set<VideoPlaybackRow>> _dbVideoPlaybackLoader;

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
                future: _dbFileSizeLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('DB file size: ${formatFileSize('en_US', snapshot.data!)}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => metadataDb.reset().then((_) => _reload()),
                        child: const Text('Reset'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Set<AvesEntry>>(
                future: _dbEntryLoader,
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
                        onPressed: () => metadataDb.clearEntries().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Map<int?, int?>>(
                future: _dbDateLoader,
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
                        onPressed: () => metadataDb.clearDates().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Set>(
                future: _dbMetadataLoader,
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
                        onPressed: () => metadataDb.clearCatalogMetadata().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Set>(
                future: _dbAddressLoader,
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
                        onPressed: () => metadataDb.clearAddresses().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Set>(
                future: _dbTrashLoader,
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
                        onPressed: () => metadataDb.clearTrashDetails().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Set>(
                future: _dbVaultsLoader,
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
              FutureBuilder<Set>(
                future: _dbFavouritesLoader,
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
              FutureBuilder<Set>(
                future: _dbCoversLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('cover rows: ${snapshot.data!.length} (${covers.count} in memory)'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => covers.clear().then((_) => _reload()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Set>(
                future: _dbVideoPlaybackLoader,
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
                        onPressed: () => metadataDb.clearVideoPlayback().then((_) => _reload()),
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
    _dbFileSizeLoader = metadataDb.dbFileSize();
    _dbEntryLoader = metadataDb.loadEntries();
    _dbDateLoader = metadataDb.loadDates();
    _dbMetadataLoader = metadataDb.loadCatalogMetadata();
    _dbAddressLoader = metadataDb.loadAddresses();
    _dbTrashLoader = metadataDb.loadAllTrashDetails();
    _dbVaultsLoader = metadataDb.loadAllVaults();
    _dbFavouritesLoader = metadataDb.loadAllFavourites();
    _dbCoversLoader = metadataDb.loadAllCovers();
    _dbVideoPlaybackLoader = metadataDb.loadAllVideoPlayback();
    setState(() {});
  }
  
  Future<void> _disposeLoadedContent() async {
    (await _dbEntryLoader).forEach((v) => v.dispose());
  }

  @override
  bool get wantKeepAlive => true;
}
