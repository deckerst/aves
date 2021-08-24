import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/services/services.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:flutter/material.dart';

class DebugAppDatabaseSection extends StatefulWidget {
  const DebugAppDatabaseSection({Key? key}) : super(key: key);

  @override
  _DebugAppDatabaseSectionState createState() => _DebugAppDatabaseSectionState();
}

class _DebugAppDatabaseSectionState extends State<DebugAppDatabaseSection> with AutomaticKeepAliveClientMixin {
  late Future<int> _dbFileSizeLoader;
  late Future<Set<AvesEntry>> _dbEntryLoader;
  late Future<Map<int?, int?>> _dbDateLoader;
  late Future<List<CatalogMetadata>> _dbMetadataLoader;
  late Future<List<AddressDetails>> _dbAddressLoader;
  late Future<Set<FavouriteRow>> _dbFavouritesLoader;
  late Future<Set<CoverRow>> _dbCoversLoader;

  @override
  void initState() {
    super.initState();
    _startDbReport();
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

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('DB file size: ${formatFilesize(snapshot.data!)}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => metadataDb.reset().then((_) => _startDbReport()),
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

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('entry rows: ${snapshot.data!.length}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => metadataDb.clearEntries().then((_) => _startDbReport()),
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

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('date rows: ${snapshot.data!.length}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => metadataDb.clearDates().then((_) => _startDbReport()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<List>(
                future: _dbMetadataLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('metadata rows: ${snapshot.data!.length}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => metadataDb.clearMetadataEntries().then((_) => _startDbReport()),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<List>(
                future: _dbAddressLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('address rows: ${snapshot.data!.length}'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => metadataDb.clearAddresses().then((_) => _startDbReport()),
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

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('favourite rows: ${snapshot.data!.length} (${favourites.count} in memory)'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => favourites.clear().then((_) => _startDbReport()),
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

                  if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('cover rows: ${snapshot.data!.length} (${covers.count} in memory)'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => covers.clear().then((_) => _startDbReport()),
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

  void _startDbReport() {
    _dbFileSizeLoader = metadataDb.dbFileSize();
    _dbEntryLoader = metadataDb.loadEntries();
    _dbDateLoader = metadataDb.loadDates();
    _dbMetadataLoader = metadataDb.loadMetadataEntries();
    _dbAddressLoader = metadataDb.loadAddresses();
    _dbFavouritesLoader = metadataDb.loadFavourites();
    _dbCoversLoader = metadataDb.loadCovers();
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
