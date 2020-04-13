import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';

class FullscreenDebugPage extends StatefulWidget {
  final ImageEntry entry;

  const FullscreenDebugPage({@required this.entry});

  @override
  _FullscreenDebugPageState createState() => _FullscreenDebugPageState();
}

class _FullscreenDebugPageState extends State<FullscreenDebugPage> {
  Future<DateMetadata> _dbDateLoader;
  Future<CatalogMetadata> _dbMetadataLoader;
  Future<AddressDetails> _dbAddressLoader;

  int get contentId => widget.entry.contentId;

  @override
  void initState() {
    super.initState();
    _startDbReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder(
              future: _dbDateLoader,
              builder: (context, AsyncSnapshot<DateMetadata> snapshot) {
                if (snapshot.hasError) return Text(snapshot.error.toString());
                if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
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
            const SizedBox(height: 16),
            FutureBuilder(
              future: _dbMetadataLoader,
              builder: (context, AsyncSnapshot<CatalogMetadata> snapshot) {
                if (snapshot.hasError) return Text(snapshot.error.toString());
                if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
                final data = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DB metadata:${data == null ? ' no row' : ''}'),
                    if (data != null)
                      InfoRowGroup({
                        'dateMillis': '${data.dateMillis}',
                        'isAnimated': '${data.isAnimated}',
                        'videoRotation': '${data.videoRotation}',
                        'latitude': '${data.latitude}',
                        'longitude': '${data.longitude}',
                        'xmpSubjects': '${data.xmpSubjects}',
                        'xmpTitleDescription': '${data.xmpTitleDescription}',
                      }),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: _dbAddressLoader,
              builder: (context, AsyncSnapshot<AddressDetails> snapshot) {
                if (snapshot.hasError) return Text(snapshot.error.toString());
                if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
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
            const Divider(),
            Text('Catalog metadata: ${widget.entry.catalogMetadata}'),
          ],
        ),
      ),
    );
  }

  void _startDbReport() {
    _dbDateLoader = metadataDb.loadDates().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _dbMetadataLoader = metadataDb.loadMetadataEntries().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _dbAddressLoader = metadataDb.loadAddresses().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    setState(() {});
  }
}
