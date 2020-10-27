import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:flutter/material.dart';

class DbTab extends StatefulWidget {
  final ImageEntry entry;

  const DbTab({@required this.entry});

  @override
  _DbTabState createState() => _DbTabState();
}

class _DbTabState extends State<DbTab> {
  Future<DateMetadata> _dbDateLoader;
  Future<ImageEntry> _dbEntryLoader;
  Future<CatalogMetadata> _dbMetadataLoader;
  Future<AddressDetails> _dbAddressLoader;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _loadDatabase();
  }

  void _loadDatabase() {
    final contentId = entry.contentId;
    _dbDateLoader = metadataDb.loadDates().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _dbEntryLoader = metadataDb.loadEntries().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _dbMetadataLoader = metadataDb.loadMetadataEntries().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _dbAddressLoader = metadataDb.loadAddresses().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('DB'),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                await metadataDb.removeIds([entry.contentId]);
                _loadDatabase();
              },
              child: Text('Remove from DB'),
            ),
          ],
        ),
        FutureBuilder<DateMetadata>(
          future: _dbDateLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DB date:${data == null ? ' no row' : ''}'),
                if (data != null)
                  InfoRowGroup({
                    'dateMillis': '${data.dateMillis}',
                  }),
              ],
            );
          },
        ),
        SizedBox(height: 16),
        FutureBuilder<ImageEntry>(
          future: _dbEntryLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DB entry:${data == null ? ' no row' : ''}'),
                if (data != null)
                  InfoRowGroup({
                    'uri': '${data.uri}',
                    'path': '${data.path}',
                    'sourceMimeType': '${data.sourceMimeType}',
                    'width': '${data.width}',
                    'height': '${data.height}',
                    'sourceRotationDegrees': '${data.sourceRotationDegrees}',
                    'sizeBytes': '${data.sizeBytes}',
                    'sourceTitle': '${data.sourceTitle}',
                    'dateModifiedSecs': '${data.dateModifiedSecs}',
                    'sourceDateTakenMillis': '${data.sourceDateTakenMillis}',
                    'durationMillis': '${data.durationMillis}',
                  }),
              ],
            );
          },
        ),
        SizedBox(height: 16),
        FutureBuilder<CatalogMetadata>(
          future: _dbMetadataLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DB metadata:${data == null ? ' no row' : ''}'),
                if (data != null)
                  InfoRowGroup({
                    'mimeType': '${data.mimeType}',
                    'dateMillis': '${data.dateMillis}',
                    'isAnimated': '${data.isAnimated}',
                    'isFlipped': '${data.isFlipped}',
                    'rotationDegrees': '${data.rotationDegrees}',
                    'latitude': '${data.latitude}',
                    'longitude': '${data.longitude}',
                    'xmpSubjects': '${data.xmpSubjects}',
                    'xmpTitleDescription': '${data.xmpTitleDescription}',
                  }),
              ],
            );
          },
        ),
        SizedBox(height: 16),
        FutureBuilder<AddressDetails>(
          future: _dbAddressLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DB address:${data == null ? ' no row' : ''}'),
                if (data != null)
                  InfoRowGroup({
                    'addressLine': '${data.addressLine}',
                    'countryCode': '${data.countryCode}',
                    'countryName': '${data.countryName}',
                    'adminArea': '${data.adminArea}',
                    'locality': '${data.locality}',
                  }),
              ],
            );
          },
        ),
      ],
    );
  }
}
