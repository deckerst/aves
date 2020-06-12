import 'dart:collection';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/services/metadata_service.dart';
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
  Future<Map> _contentResolverMetadataLoader;

  int get contentId => widget.entry.contentId;

  @override
  void initState() {
    super.initState();
    _initFutures();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debug'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'DB'),
              Tab(text: 'Content Resolver'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildDbTabView(),
              _buildContentResolverTabView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDbTabView() {
    final catalog = widget.entry.catalogMetadata;
    return ListView(
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
        Text('Catalog metadata:${catalog == null ? ' no data' : ''}'),
        if (catalog != null)
          InfoRowGroup({
            'contentId': '${catalog.contentId}',
            'dateMillis': '${catalog.dateMillis}',
            'isAnimated': '${catalog.isAnimated}',
            'videoRotation': '${catalog.videoRotation}',
            'latitude': '${catalog.latitude}',
            'longitude': '${catalog.longitude}',
            'xmpSubjects': '${catalog.xmpSubjects}',
            'xmpTitleDescription': '${catalog.xmpTitleDescription}',
          }),
      ],
    );
  }

  // MediaStore timestamp keys
  static const secondTimestampKeys = ['date_added', 'date_modified', 'date_expires', 'isPlayed'];
  static const millisecondTimestampKeys = ['datetaken', 'datetime'];

  Widget _buildContentResolverTabView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FutureBuilder(
          future: _contentResolverMetadataLoader,
          builder: (context, AsyncSnapshot<Map> snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
            final data = SplayTreeMap.of(snapshot.data.map((k, v) {
              final key = k.toString();
              var value = v?.toString() ?? 'null';
              if ([...secondTimestampKeys, ...millisecondTimestampKeys].contains(key) && v is num && v != 0) {
                if (secondTimestampKeys.contains(key)) {
                  v *= 1000;
                }
                value += ' (${DateTime.fromMillisecondsSinceEpoch(v)})';
              }
              return MapEntry(key, value);
            }));
            return InfoRowGroup(data);
          },
        ),
      ],
    );
  }

  void _initFutures() {
    _dbDateLoader = metadataDb.loadDates().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _dbMetadataLoader = metadataDb.loadMetadataEntries().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _dbAddressLoader = metadataDb.loadAddresses().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _contentResolverMetadataLoader = MetadataService.getContentResolverMetadata(widget.entry);
    setState(() {});
  }
}
