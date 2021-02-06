import 'package:aves/model/entry.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:flutter/material.dart';

class DebugAppDatabaseSection extends StatefulWidget {
  @override
  _DebugAppDatabaseSectionState createState() => _DebugAppDatabaseSectionState();
}

class _DebugAppDatabaseSectionState extends State<DebugAppDatabaseSection> with AutomaticKeepAliveClientMixin {
  Future<int> _dbFileSizeLoader;
  Future<Set<AvesEntry>> _dbEntryLoader;
  Future<List<DateMetadata>> _dbDateLoader;
  Future<List<CatalogMetadata>> _dbMetadataLoader;
  Future<List<AddressDetails>> _dbAddressLoader;
  Future<List<FavouriteRow>> _dbFavouritesLoader;

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
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
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
                      ElevatedButton(
                        onPressed: () => metadataDb.reset().then((_) => _startDbReport()),
                        child: Text('Reset'),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<Set<AvesEntry>>(
                future: _dbEntryLoader,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();

                  return Row(
                    children: [
                      Expanded(
                        child: Text('entry rows: ${snapshot.data.length}'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
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
                        child: Text('date rows: ${snapshot.data.length}'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
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
                        child: Text('metadata rows: ${snapshot.data.length}'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
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
                        child: Text('address rows: ${snapshot.data.length}'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
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
                        child: Text('favourite rows: ${snapshot.data.length} (${favourites.count} in memory)'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => favourites.clear().then((_) => _startDbReport()),
                        child: Text('Clear'),
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
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
