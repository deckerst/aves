import 'package:aves/app_mode.dart';
import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/viewer/debug/db.dart';
import 'package:aves/widgets/viewer/debug/metadata.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ViewerDebugPage extends StatelessWidget {
  static const routeName = '/viewer/debug';

  final AvesEntry entry;

  const ViewerDebugPage({required this.entry});

  @override
  Widget build(BuildContext context) {
    final tabs = <Tuple2<Tab, Widget>>[
      Tuple2(const Tab(text: 'Entry'), _buildEntryTabView()),
      if (context.select<ValueNotifier<AppMode>, bool>((vn) => vn.value != AppMode.view)) Tuple2(const Tab(text: 'DB'), DbTab(entry: entry)),
      Tuple2(const Tab(icon: Icon(AIcons.android)), MetadataTab(entry: entry)),
      Tuple2(const Tab(icon: Icon(AIcons.image)), _buildThumbnailsTabView()),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debug'),
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
    String toDateValue(int? time, {int factor = 1}) {
      var value = '$time';
      if (time != null && time > 0) {
        value += ' (${DateTime.fromMillisecondsSinceEpoch(time * factor)})';
      }
      return value;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
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
        }),
        const Divider(),
        InfoRowGroup({
          'dateModifiedSecs': toDateValue(entry.dateModifiedSecs, factor: 1000),
          'sourceDateTakenMillis': toDateValue(entry.sourceDateTakenMillis),
          'bestDate': '${entry.bestDate}',
        }),
        const Divider(),
        InfoRowGroup({
          'width': '${entry.width}',
          'height': '${entry.height}',
          'sourceRotationDegrees': '${entry.sourceRotationDegrees}',
          'rotationDegrees': '${entry.rotationDegrees}',
          'isRotated': '${entry.isRotated}',
          'isFlipped': '${entry.isFlipped}',
          'displayAspectRatio': '${entry.displayAspectRatio}',
          'displaySize': '${entry.displaySize}',
        }),
        const Divider(),
        InfoRowGroup({
          'durationMillis': '${entry.durationMillis}',
          'durationText': '${entry.durationText}',
        }),
        const Divider(),
        InfoRowGroup({
          'sizeBytes': '${entry.sizeBytes}',
          'isFavourite': '${entry.isFavourite}',
          'isSvg': '${entry.isSvg}',
          'isPhoto': '${entry.isPhoto}',
          'isVideo': '${entry.isVideo}',
          'isCatalogued': '${entry.isCatalogued}',
          'isAnimated': '${entry.isAnimated}',
          'isGeotiff': '${entry.isGeotiff}',
          'is360': '${entry.is360}',
          'canEdit': '${entry.canEdit}',
          'canEditExif': '${entry.canEditExif}',
          'canRotateAndFlip': '${entry.canRotateAndFlip}',
          'xmpSubjects': '${entry.xmpSubjects}',
        }),
        const Divider(),
        InfoRowGroup({
          'hasGps': '${entry.hasGps}',
          'hasAddress': '${entry.hasAddress}',
          'hasFineAddress': '${entry.hasFineAddress}',
          'latLng': '${entry.latLng}',
          'geoUri': '${entry.geoUri}',
        }),
      ],
    );
  }

  Widget _buildThumbnailsTabView() {
    final children = <Widget>[];
    if (entry.isSvg) {
      const extent = 128.0;
      children.addAll([
        const Text('SVG ($extent)'),
        SvgPicture(
          UriPicture(
            uri: entry.uri,
            mimeType: entry.mimeType,
          ),
          width: extent,
          height: extent,
        )
      ]);
    } else {
      children.addAll(
        entry.cachedThumbnails.expand((provider) => [
              Text('Raster (${provider.key.extent})'),
              Center(
                child: Image(
                  image: provider,
                ),
              ),
              const SizedBox(height: 16),
            ]),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }
}
