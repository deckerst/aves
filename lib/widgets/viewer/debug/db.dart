import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/viewer/video_playback.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DbTab extends StatefulWidget {
  final AvesEntry entry;

  const DbTab({
    super.key,
    required this.entry,
  });

  @override
  State<DbTab> createState() => _DbTabState();
}

class _DbTabState extends State<DbTab> {
  late Future<int?> _dbDateLoader;
  late Future<AvesEntry?> _dbEntryLoader;
  late Future<CatalogMetadata?> _dbMetadataLoader;
  late Future<AddressDetails?> _dbAddressLoader;
  late Future<TrashDetails?> _dbTrashDetailsLoader;
  late Future<VideoPlaybackRow?> _dbVideoPlaybackLoader;

  AvesEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _loadDatabase();
  }

  void _loadDatabase() {
    final id = entry.id;
    _dbDateLoader = localMediaDb.loadDates().then((values) => values[id]);
    _dbEntryLoader = localMediaDb.loadEntriesById({id}).then((values) => values.firstOrNull);
    _dbMetadataLoader = localMediaDb.loadCatalogMetadata().then((values) => values.firstWhereOrNull((row) => row.id == id));
    _dbAddressLoader = localMediaDb.loadAddresses().then((values) => values.firstWhereOrNull((row) => row.id == id));
    _dbTrashDetailsLoader = localMediaDb.loadAllTrashDetails().then((values) => values.firstWhereOrNull((row) => row.id == id));
    _dbVideoPlaybackLoader = localMediaDb.loadVideoPlayback(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FutureBuilder<int?>(
          future: _dbDateLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DB date:${data == null ? ' no row' : ''}'),
                if (data != null)
                  InfoRowGroup(
                    info: {
                      'dateMillis': '$data',
                    },
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<AvesEntry?>(
          future: _dbEntryLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DB entry:${data == null ? ' no row' : ''}'),
                if (data != null) ...[
                  ElevatedButton(
                    onPressed: () async {
                      final source = context.read<CollectionSource>();
                      await source.removeEntries({entry.uri}, includeTrash: true);
                    },
                    child: const Text('Untrack entry'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final duplicates = {entry.copyWith(id: localMediaDb.nextId)};
                      final source = context.read<CollectionSource>();
                      source.addEntries(duplicates);
                      await localMediaDb.insertEntries(duplicates);
                    },
                    child: const Text('Duplicate entry'),
                  ),
                  InfoRowGroup(
                    info: Map.fromEntries(data.toDatabaseMap().entries.map((kv) => MapEntry(kv.key, kv.value?.toString() ?? ''))),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<CatalogMetadata?>(
          future: _dbMetadataLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DB metadata:${data == null ? ' no row' : ''}'),
                if (data != null)
                  InfoRowGroup(
                    info: Map.fromEntries(data.toMap().entries.map((kv) => MapEntry(kv.key, kv.value?.toString() ?? ''))),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<AddressDetails?>(
          future: _dbAddressLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DB address:${data == null ? ' no row' : ''}'),
                if (data != null)
                  InfoRowGroup(
                    info: Map.fromEntries(data.toMap().entries.map((kv) => MapEntry(kv.key, kv.value?.toString() ?? ''))),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<TrashDetails?>(
          future: _dbTrashDetailsLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DB trash details:${data == null ? ' no row' : ''}'),
                if (data != null) ...[
                  ElevatedButton(
                    onPressed: () async {
                      entry.trashDetails = null;
                      await localMediaDb.updateTrash(entry.id, entry.trashDetails);
                      _loadDatabase();
                    },
                    child: const Text('Remove details'),
                  ),
                  InfoRowGroup(
                    info: {
                      'dateMillis': '${data.dateMillis}',
                      'path': data.path,
                    },
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<VideoPlaybackRow?>(
          future: _dbVideoPlaybackLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DB video playback:${data == null ? ' no row' : ''}'),
                if (data != null)
                  InfoRowGroup(
                    info: {
                      'resumeTimeMillis': '${data.resumeTimeMillis}',
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
