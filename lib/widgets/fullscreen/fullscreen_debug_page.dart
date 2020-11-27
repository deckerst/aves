import 'package:aves/image_providers/thumbnail_provider.dart';
import 'package:aves/image_providers/uri_picture_provider.dart';
import 'package:aves/main.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/fullscreen/debug/db.dart';
import 'package:aves/widgets/fullscreen/debug/metadata.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuple/tuple.dart';

class FullscreenDebugPage extends StatelessWidget {
  static const routeName = '/fullscreen/debug';

  final ImageEntry entry;

  const FullscreenDebugPage({@required this.entry});

  @override
  Widget build(BuildContext context) {
    final tabs = <Tuple2<Tab, Widget>>[
      Tuple2(Tab(text: 'Entry'), _buildEntryTabView()),
      if (AvesApp.mode != AppMode.view) Tuple2(Tab(text: 'DB'), DbTab(entry: entry)),
      Tuple2(Tab(icon: Icon(AIcons.android)), MetadataTab(entry: entry)),
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
        }),
        Divider(),
        InfoRowGroup({
          'dateModifiedSecs': toDateValue(entry.dateModifiedSecs, factor: 1000),
          'sourceDateTakenMillis': toDateValue(entry.sourceDateTakenMillis),
          'bestDate': '${entry.bestDate}',
        }),
        Divider(),
        InfoRowGroup({
          'width': '${entry.width}',
          'height': '${entry.height}',
          'sourceRotationDegrees': '${entry.sourceRotationDegrees}',
          'rotationDegrees': '${entry.rotationDegrees}',
          'isFlipped': '${entry.isFlipped}',
          'portrait': '${entry.isPortrait}',
          'displayAspectRatio': '${entry.displayAspectRatio}',
          'displaySize': '${entry.displaySize}',
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
          'canEditExif': '${entry.canEditExif}',
          'canPrint': '${entry.canPrint}',
          'canRotateAndFlip': '${entry.canRotateAndFlip}',
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
          Center(
            child: Image(
              image: ThumbnailProvider(
                ThumbnailProviderKey.fromEntry(entry),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('Raster ($extent)'),
          Center(
            child: Image(
              image: ThumbnailProvider(
                ThumbnailProviderKey.fromEntry(entry, extent: extent),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
