import 'dart:collection';
import 'dart:typed_data';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/android_debug_service.dart';
import 'package:aves/services/geocoding_service.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';

class MetadataTab extends StatefulWidget {
  final AvesEntry entry;

  const MetadataTab({
    super.key,
    required this.entry,
  });

  @override
  State<MetadataTab> createState() => _MetadataTabState();
}

class _MetadataTabState extends State<MetadataTab> {
  late Future<Map> _bitmapFactoryLoader, _contentResolverMetadataLoader, _exifInterfaceMetadataLoader;
  late Future<Map> _mediaMetadataLoader, _metadataExtractorLoader, _pixyMetaLoader, _tiffStructureLoader, _addressLoader;
  late Future<String?> _mp4ParserDumpLoader;

  // MediaStore timestamp keys
  static const secondTimestampKeys = ['date_added', 'date_modified', 'date_expires', 'isPlayed'];
  static const millisecondTimestampKeys = ['datetaken', 'datetime'];

  AvesEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  void _loadMetadata() {
    _bitmapFactoryLoader = AndroidDebugService.getBitmapFactoryInfo(entry);
    _contentResolverMetadataLoader = AndroidDebugService.getContentResolverMetadata(entry);
    _exifInterfaceMetadataLoader = AndroidDebugService.getExifInterfaceMetadata(entry);
    _mediaMetadataLoader = AndroidDebugService.getMediaMetadataRetrieverMetadata(entry);
    _metadataExtractorLoader = AndroidDebugService.getMetadataExtractorSummary(entry);
    _mp4ParserDumpLoader = AndroidDebugService.getMp4ParserDump(entry);
    _pixyMetaLoader = AndroidDebugService.getPixyMetadata(entry);
    _tiffStructureLoader = AndroidDebugService.getTiffStructure(entry);
    _addressLoader = entry.hasGps
        ? GeocodingService.getAddress(entry.latLng!, settings.appliedLocale).then((addresses) {
            if (addresses.isNotEmpty) {
              final address = addresses.first;
              return {
                'addressLine': address.addressLine,
                'adminArea': address.adminArea,
                'countryCode': address.countryCode,
                'countryName': address.countryName,
                'featureName': address.featureName,
                'locality': address.locality,
                'postalCode': address.postalCode,
                'subAdminArea': address.subAdminArea,
                'subLocality': address.subLocality,
                'subThoroughfare': address.subThoroughfare,
                'thoroughfare': address.thoroughfare,
              };
            }
            return {};
          })
        : Future.value({});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget builderFromSnapshotData(BuildContext context, Map snapshotData, String title) {
      final data = SplayTreeMap.of(snapshotData.map((k, v) {
        final key = k.toString();
        var value = v?.toString() ?? 'null';
        if ([...secondTimestampKeys, ...millisecondTimestampKeys].contains(key) && v is int && v != 0) {
          if (secondTimestampKeys.contains(key)) {
            v *= 1000;
          }
          try {
            value += ' (${DateTime.fromMillisecondsSinceEpoch(v)})';
          } catch (error) {
            value += ' (invalid DateTime})';
          }
        }
        if (key == 'xmp' && v != null && v is Uint8List) {
          value = String.fromCharCodes(v);
        }
        return MapEntry(key, value);
      }));
      return AvesExpansionTile(
        title: title,
        children: [
          if (data.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: InfoRowGroup(info: data),
            )
        ],
      );
    }

    Widget builderFromSnapshot(BuildContext context, AsyncSnapshot<Map> snapshot, String title) {
      if (snapshot.hasError) return Text(snapshot.error.toString());
      if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
      return builderFromSnapshotData(context, snapshot.data!, title);
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        FutureBuilder<Map>(
          future: _bitmapFactoryLoader,
          builder: (context, snapshot) => builderFromSnapshot(context, snapshot, 'Bitmap Factory'),
        ),
        FutureBuilder<Map>(
          future: _contentResolverMetadataLoader,
          builder: (context, snapshot) => builderFromSnapshot(context, snapshot, 'Content Resolver'),
        ),
        FutureBuilder<Map>(
          future: _exifInterfaceMetadataLoader,
          builder: (context, snapshot) => builderFromSnapshot(context, snapshot, 'Exif Interface'),
        ),
        FutureBuilder<Map>(
          future: _mediaMetadataLoader,
          builder: (context, snapshot) => builderFromSnapshot(context, snapshot, 'Media Metadata Retriever'),
        ),
        FutureBuilder<Map>(
          future: _metadataExtractorLoader,
          builder: (context, snapshot) => builderFromSnapshot(context, snapshot, 'Metadata Extractor'),
        ),
        FutureBuilder<String?>(
          future: _mp4ParserDumpLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
            final data = snapshot.data?.trim();
            return AvesExpansionTile(
              title: 'MP4 Parser',
              children: [
                if (data != null && data.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(data),
                    ),
                  )
              ],
            );
          },
        ),
        FutureBuilder<Map>(
          future: _pixyMetaLoader,
          builder: (context, snapshot) => builderFromSnapshot(context, snapshot, 'Pixy Meta'),
        ),
        if (entry.mimeType == MimeTypes.tiff)
          FutureBuilder<Map>(
            future: _tiffStructureLoader,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.entries.map((kv) => builderFromSnapshotData(context, kv.value as Map, 'TIFF ${kv.key}')).toList(),
              );
            },
          ),
        FutureBuilder<Map>(
          future: _addressLoader,
          builder: (context, snapshot) => builderFromSnapshot(context, snapshot, 'Address'),
        ),
      ],
    );
  }
}
