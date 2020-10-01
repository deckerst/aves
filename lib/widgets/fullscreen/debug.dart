import 'dart:collection';
import 'dart:typed_data';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/image_providers/thumbnail_provider.dart';
import 'package:aves/widgets/common/image_providers/uri_picture_provider.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuple/tuple.dart';

class FullscreenDebugPage extends StatefulWidget {
  static const routeName = '/fullscreen/debug';

  final ImageEntry entry;

  const FullscreenDebugPage({@required this.entry});

  @override
  _FullscreenDebugPageState createState() => _FullscreenDebugPageState();
}

class _FullscreenDebugPageState extends State<FullscreenDebugPage> {
  Future<DateMetadata> _dbDateLoader;
  Future<CatalogMetadata> _dbMetadataLoader;
  Future<AddressDetails> _dbAddressLoader;
  Future<Map> _contentResolverMetadataLoader, _exifInterfaceMetadataLoader;

  ImageEntry get entry => widget.entry;

  int get contentId => entry.contentId;

  @override
  void initState() {
    super.initState();
    _initFutures();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Tuple2<Tab, Widget>>[
      Tuple2(Tab(text: 'Entry'), _buildEntryTabView()),
      Tuple2(Tab(text: 'DB'), _buildDbTabView()),
      Tuple2(Tab(icon: Icon(AIcons.android)), _buildContentResolverTabView()),
      Tuple2(Tab(icon: Icon(AIcons.image)), _buildThumbnailsTabView()),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Debug'),
          bottom: TabBar(
            tabs: tabs.map((t) => t.item1).toList(),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: tabs.map((t) => t.item2).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryTabView() {
    String toDateValue(int time, {int factor = 1}) {
      var value = '$time';
      if (time != null && time > 0) {
        value += ' (${DateTime.fromMillisecondsSinceEpoch(time * factor)})';
      }
      return value;
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        InfoRowGroup({
          'uri': '${entry.uri}',
          'contentId': '${entry.contentId}',
          'path': '${entry.path}',
          'directory': '${entry.directory}',
          'filenameWithoutExtension': '${entry.filenameWithoutExtension}',
          'sourceTitle': '${entry.sourceTitle}',
          'sourceMimeType': '${entry.sourceMimeType}',
          'mimeType': '${entry.mimeType}',
          'mimeTypeAnySubtype': '${entry.mimeTypeAnySubtype}',
        }),
        Divider(),
        InfoRowGroup({
          'dateModifiedSecs': toDateValue(entry.dateModifiedSecs, factor: 1000),
          'sourceDateTakenMillis': toDateValue(entry.sourceDateTakenMillis),
          'bestDate': '${entry.bestDate}',
          'monthTaken': '${entry.monthTaken}',
          'dayTaken': '${entry.dayTaken}',
        }),
        Divider(),
        InfoRowGroup({
          'width': '${entry.width}',
          'height': '${entry.height}',
          'orientationDegrees': '${entry.orientationDegrees}',
          'rotated': '${entry.rotated}',
          'displayAspectRatio': '${entry.displayAspectRatio}',
          'displaySize': '${entry.displaySize}',
          'megaPixels': '${entry.megaPixels}',
        }),
        Divider(),
        InfoRowGroup({
          'durationMillis': '${entry.durationMillis}',
          'durationText': '${entry.durationText}',
        }),
        Divider(),
        InfoRowGroup({
          'sizeBytes': '${entry.sizeBytes}',
          'isFavourite': '${entry.isFavourite}',
          'isSvg': '${entry.isSvg}',
          'isPhoto': '${entry.isPhoto}',
          'isVideo': '${entry.isVideo}',
          'isCatalogued': '${entry.isCatalogued}',
          'isAnimated': '${entry.isAnimated}',
          'canEdit': '${entry.canEdit}',
          'canPrint': '${entry.canPrint}',
          'canRotate': '${entry.canRotate}',
          'xmpSubjects': '${entry.xmpSubjects}',
        }),
        Divider(),
        InfoRowGroup({
          'hasGps': '${entry.hasGps}',
          'isLocated': '${entry.isLocated}',
          'latLng': '${entry.latLng}',
          'geoUri': '${entry.geoUri}',
        }),
      ],
    );
  }

  Widget _buildThumbnailsTabView() {
    const extent = 128.0;
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (entry.isSvg) ...[
          Text('SVG ($extent)'),
          SvgPicture(
            UriPicture(
              uri: entry.uri,
              mimeType: entry.mimeType,
            ),
            width: extent,
            height: extent,
          )
        ],
        if (!entry.isSvg) ...[
          Text('Raster (fast)'),
          Center(child: Image(image: ThumbnailProvider(entry: entry))),
          SizedBox(height: 16),
          Text('Raster ($extent)'),
          Center(child: Image(image: ThumbnailProvider(entry: entry, extent: extent))),
        ],
      ],
    );
  }

  Widget _buildDbTabView() {
    final catalog = entry.catalogMetadata;
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
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
        Divider(),
        Text('Catalog metadata:${catalog == null ? ' no data' : ''}'),
        if (catalog != null)
          InfoRowGroup({
            'contentId': '${catalog.contentId}',
            'mimeType': '${catalog.mimeType}',
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
    Widget builder(BuildContext context, AsyncSnapshot<Map> snapshot) {
      if (snapshot.hasError) return Text(snapshot.error.toString());
      if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
      final data = SplayTreeMap.of(snapshot.data.map((k, v) {
        final key = k.toString();
        var value = v?.toString() ?? 'null';
        if ([...secondTimestampKeys, ...millisecondTimestampKeys].contains(key) && v is num && v != 0) {
          if (secondTimestampKeys.contains(key)) {
            v *= 1000;
          }
          value += ' (${DateTime.fromMillisecondsSinceEpoch(v)})';
        }
        if (key == 'xmp' && v != null && v is Uint8List) {
          value = String.fromCharCodes(v);
        }
        return MapEntry(key, value);
      }));
      return InfoRowGroup(data);
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        SectionTitle('Content Resolver (Media Store)'),
        FutureBuilder<Map>(
          future: _contentResolverMetadataLoader,
          builder: builder,
        ),
        SectionTitle('Exif Interface'),
        FutureBuilder<Map>(
          future: _exifInterfaceMetadataLoader,
          builder: builder,
        ),
      ],
    );
  }

  void _initFutures() {
    _dbDateLoader = metadataDb.loadDates().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _dbMetadataLoader = metadataDb.loadMetadataEntries().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _dbAddressLoader = metadataDb.loadAddresses().then((values) => values.firstWhere((row) => row.contentId == contentId, orElse: () => null));
    _contentResolverMetadataLoader = MetadataService.getContentResolverMetadata(entry);
    _exifInterfaceMetadataLoader = MetadataService.getExifInterfaceMetadata(entry);
    setState(() {});
  }
}
