import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/model/video_playback.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

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
    _dbDateLoader = metadataDb.loadDates().then((values) => values[id]);
    _dbEntryLoader = metadataDb.loadEntries().then((values) => values.firstWhereOrNull((row) => row.id == id));
    _dbMetadataLoader = metadataDb.loadCatalogMetadata().then((values) => values.firstWhereOrNull((row) => row.id == id));
    _dbAddressLoader = metadataDb.loadAddresses().then((values) => values.firstWhereOrNull((row) => row.id == id));
    _dbTrashDetailsLoader = metadataDb.loadAllTrashDetails().then((values) => values.firstWhereOrNull((row) => row.id == id));
    _dbVideoPlaybackLoader = metadataDb.loadVideoPlayback(id);
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
                if (data != null)
                  InfoRowGroup(
                    info: {
                      'uri': data.uri,
                      'path': data.path ?? '',
                      'sourceMimeType': data.sourceMimeType,
                      'width': '${data.width}',
                      'height': '${data.height}',
                      'sourceRotationDegrees': '${data.sourceRotationDegrees}',
                      'sizeBytes': '${data.sizeBytes}',
                      'sourceTitle': data.sourceTitle ?? '',
                      'dateAddedSecs': '${data.dateAddedSecs}',
                      'dateModifiedSecs': '${data.dateModifiedSecs}',
                      'sourceDateTakenMillis': '${data.sourceDateTakenMillis}',
                      'durationMillis': '${data.durationMillis}',
                      'trashed': '${data.trashed}',
                    },
                  ),
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
                    info: {
                      'mimeType': data.mimeType ?? '',
                      'dateMillis': '${data.dateMillis}',
                      'isAnimated': '${data.isAnimated}',
                      'isFlipped': '${data.isFlipped}',
                      'rotationDegrees': '${data.rotationDegrees}',
                      'latitude': '${data.latitude}',
                      'longitude': '${data.longitude}',
                      'xmpSubjects': data.xmpSubjects ?? '',
                      'xmpTitle': data.xmpTitle ?? '',
                      'rating': '${data.rating}',
                    },
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
                    info: {
                      'countryCode': data.countryCode ?? '',
                      'countryName': data.countryName ?? '',
                      'adminArea': data.adminArea ?? '',
                      'locality': data.locality ?? '',
                    },
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
                if (data != null)
                  InfoRowGroup(
                    info: {
                      'dateMillis': '${data.dateMillis}',
                      'path': data.path,
                    },
                  ),
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
