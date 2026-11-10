import 'dart:collection';
import 'dart:typed_data';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/android_debug_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/basic/keep_alive.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:aves/widgets/viewer/debug/utils.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class const MetadataTab({
  super.key,
  required final AvesEntry entry,
}) extends StatefulWidget {
  @override
  State<MetadataTab> createState() => _MetadataTabState();
}

class _MetadataTabState extends State<MetadataTab> {
  late Future<Map> _bitmapFactoryLoader, _contentResolverMetadataLoader, _exifInterfaceMetadataLoader, _mpvDumpLoader;
  late Future<Map> _mediaMetadataLoader, _metadataExtractorLoader, _pixyMetaLoader, _tiffStructureLoader, _addressLoader;
  late Future<String?> _mp4ParserDumpLoader;

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
    _mpvDumpLoader = videoMetadataFetcher.getMetadata(uri: entry.uri, mimeType: entry.mimeType);
    _mediaMetadataLoader = AndroidDebugService.getMediaMetadataRetrieverMetadata(entry);
    _metadataExtractorLoader = AndroidDebugService.getMetadataExtractorSummary(entry);
    _mp4ParserDumpLoader = AndroidDebugService.getMp4ParserDump(entry);
    _pixyMetaLoader = AndroidDebugService.getPixyMetadata(entry);
    _tiffStructureLoader = AndroidDebugService.getTiffStructure(entry);
    _addressLoader = entry.hasGps
        ? geocodingService.getAddress(entry.latLng!, settings.avesLocale).then((addresses) {
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
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _Section(title: 'Bitmap Factory', loader: _bitmapFactoryLoader),
        _Section(title: 'Content Resolver', loader: _contentResolverMetadataLoader),
        _Section(title: 'Exif Interface', loader: _exifInterfaceMetadataLoader),
        _Section(title: 'Media Metadata Retriever', loader: _mediaMetadataLoader),
        _Section(title: 'Metadata Extractor', loader: _metadataExtractorLoader),
        _Section(
          title: 'MP4 Parser',
          loader: _mp4ParserDumpLoader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
            final data = snapshot.data?.trim();
            return AvesExpansionTile(
              title: 'MP4 Parser',
              locale: KnownLocale.english,
              children: [
                if (data != null && data.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(data),
                    ),
                  ),
              ],
            );
          },
        ),
        _Section(title: 'MPV', loader: _mpvDumpLoader),
        _Section(title: 'Pixy Meta', loader: _pixyMetaLoader),
        if (entry.mimeType == MimeTypes.tiff)
          _Section(
            title: 'TIFF',
            loader: _tiffStructureLoader,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
              final pageByIndex = Map.fromEntries(snapshot.data!.entries);
              final indices = pageByIndex.keys.whereType<String>().toList().sorted(compareNatural);
              return Column(
                crossAxisAlignment: .start,
                children: indices.map((index) {
                  final page = pageByIndex[index] as Map;
                  return _Section.builderFromMap(context, page, 'TIFF $index');
                }).toList(),
              );
            },
          ),
        _Section(title: 'Address', loader: _addressLoader),
      ],
    );
  }
}

class const _Section<T>({
  super.key,
  required final String title,
  required final Future<T> loader,
  final AsyncWidgetBuilder<T>? builder,
}) extends StatelessWidget {
  // MediaStore timestamp keys
  static const secondTimestampKeys = ['date_added', 'date_modified', 'date_expires', 'isPlayed'];
  static const millisecondTimestampKeys = ['datetaken', 'datetime', 'inferred_date'];

  @override
  Widget build(BuildContext context) {
    return AKeepAlive(
      child: FutureBuilder<T>(
        future: loader,
        builder: (context, snapshot) {
          return builder?.call(context, snapshot) ?? builderFromSnapshot(context, snapshot, title);
        },
      ),
    );
  }

  Widget builderFromSnapshot(BuildContext context, AsyncSnapshot<T> snapshot, String title) {
    if (snapshot.hasError) return Text(snapshot.error.toString());
    if (snapshot.connectionState != ConnectionState.done) return const SizedBox();
    final snapshotData = snapshot.data;
    if (snapshotData is Map) {
      return builderFromMap(context, snapshotData, title);
    }
    return const SizedBox();
  }

  static Widget builderFromMap(BuildContext context, Map snapshotData, String title) {
    final data = SplayTreeMap.of(
      snapshotData.map((k, v) {
        final key = k.toString();
        var value = v?.toString() ?? 'null';
        if ([...secondTimestampKeys, ...millisecondTimestampKeys].contains(key) && v is int && v != 0) {
          value = ViewerDebugUtils.toDateValue(v, factor: secondTimestampKeys.contains(key) ? 1000 : 1);
        }
        if (key == 'xmp' && v != null && v is Uint8List) {
          value = String.fromCharCodes(v);
        }
        return MapEntry(key, value);
      }),
    );
    return AvesExpansionTile(
      title: title,
      locale: KnownLocale.english,
      children: [
        if (data.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: InfoRowGroup(info: data),
          ),
      ],
    );
  }
}
