import 'dart:ui' as ui;

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/home_widget.dart';
import 'package:aves/widgets/viewer/debug/db.dart';
import 'package:aves/widgets/viewer/debug/metadata.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ViewerDebugPage extends StatelessWidget {
  static const routeName = '/viewer/debug';

  final AvesEntry entry;

  const ViewerDebugPage({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = <Tuple2<Tab, Widget>>[
      Tuple2(const Tab(text: 'Entry'), _buildEntryTabView()),
      if (context.select<ValueNotifier<AppMode>, bool>((vn) => vn.value != AppMode.view)) Tuple2(const Tab(text: 'DB'), DbTab(entry: entry)),
      Tuple2(const Tab(icon: Icon(AIcons.android)), MetadataTab(entry: entry)),
      Tuple2(const Tab(icon: Icon(AIcons.image)), _buildThumbnailsTabView()),
      Tuple2(const Tab(icon: Icon(AIcons.addShortcut)), _buildWidgetTabView()),
    ];
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTabController(
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
      ),
    );
  }

  Widget _buildEntryTabView() {
    String toDateValue(int? time, {int factor = 1}) {
      var value = '$time';
      if (time != null && time > 0) {
        try {
          value += ' (${DateTime.fromMillisecondsSinceEpoch(time * factor)})';
        } catch (e) {
          value += ' (invalid DateTime})';
        }
      }
      return value;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InfoRowGroup(
          info: {
            'hash': '#${shortHash(entry)}',
            'id': '${entry.id}',
            'contentId': '${entry.contentId}',
            'uri': entry.uri,
            'path': entry.path ?? '',
            'directory': entry.directory ?? '',
            'filenameWithoutExtension': entry.filenameWithoutExtension ?? '',
            'extension': entry.extension ?? '',
            'sourceTitle': entry.sourceTitle ?? '',
            'sourceMimeType': entry.sourceMimeType,
            'mimeType': entry.mimeType,
            'isMissingAtPath': '${entry.isMissingAtPath}',
          },
        ),
        const Divider(),
        InfoRowGroup(
          info: {
            'trashed': '${entry.trashed}',
            'trashPath': '${entry.trashDetails?.path}',
            'trashDateMillis': '${entry.trashDetails?.dateMillis}',
          },
        ),
        const Divider(),
        InfoRowGroup(
          info: {
            'catalogDateMillis': toDateValue(entry.catalogDateMillis),
            'dateModifiedSecs': toDateValue(entry.dateModifiedSecs, factor: 1000),
            'sourceDateTakenMillis': toDateValue(entry.sourceDateTakenMillis),
            'bestDate': '${entry.bestDate}',
          },
        ),
        const Divider(),
        InfoRowGroup(
          info: {
            'width': '${entry.width}',
            'height': '${entry.height}',
            'sourceRotationDegrees': '${entry.sourceRotationDegrees}',
            'rotationDegrees': '${entry.rotationDegrees}',
            'isRotated': '${entry.isRotated}',
            'isFlipped': '${entry.isFlipped}',
            'displayAspectRatio': '${entry.displayAspectRatio}',
            'displaySize': '${entry.displaySize}',
          },
        ),
        const Divider(),
        InfoRowGroup(
          info: {
            'durationMillis': '${entry.durationMillis}',
            'durationText': entry.durationText,
          },
        ),
        const Divider(),
        InfoRowGroup(
          info: {
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
            'canEditDate': '${entry.canEditDate}',
            'canEditTags': '${entry.canEditTags}',
            'canRotateAndFlip': '${entry.canRotateAndFlip}',
            'tags': '${entry.tags}',
          },
        ),
        const Divider(),
        InfoRowGroup(
          info: {
            'hasGps': '${entry.hasGps}',
            'hasAddress': '${entry.hasAddress}',
            'hasFineAddress': '${entry.hasFineAddress}',
            'latLng': '${entry.latLng}',
          },
        ),
      ],
    );
  }

  Widget _buildThumbnailsTabView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: entry.cachedThumbnails
          .expand((provider) => [
                Text('Thumb extent: ${provider.key.extent}'),
                Center(
                  child: Image(
                    image: provider,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      return Container(
                        foregroundDecoration: const BoxDecoration(
                          border: Border.fromBorderSide(BorderSide(
                            color: Colors.amber,
                            width: .1,
                          )),
                        ),
                        child: child,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ])
          .toList(),
    );
  }

  Widget _buildWidgetTabView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [303, 636, 972, 1305]
          .expand((heightPx) => [
                Text('Widget heightPx: $heightPx'),
                FutureBuilder<Uint8List>(
                  future: HomeWidgetPainter(
                    entry: entry,
                    devicePixelRatio: ui.window.devicePixelRatio,
                  ).drawWidget(
                    widthPx: 978,
                    heightPx: heightPx,
                    outline: Colors.amber,
                    shape: WidgetShape.heart,
                    format: ui.ImageByteFormat.png,
                  ),
                  builder: (context, snapshot) {
                    final bytes = snapshot.data;
                    if (bytes == null) return const SizedBox();
                    return Image.memory(bytes);
                  },
                ),
              ])
          .toList(),
    );
  }
}
