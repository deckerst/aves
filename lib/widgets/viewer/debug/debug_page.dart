import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/favourites.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/viewer/debug/db.dart';
import 'package:aves/widgets/viewer/debug/metadata.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerDebugPage extends StatelessWidget {
  static const routeName = '/viewer/debug';

  final AvesEntry entry;

  const ViewerDebugPage({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = <(Tab, Widget)>[
      (const Tab(text: 'Entry'), _buildEntryTabView()),
      if (context.select<ValueNotifier<AppMode>, bool>((vn) => vn.value != AppMode.view)) (const Tab(text: 'DB'), DbTab(entry: entry)),
      (const Tab(icon: Icon(AIcons.android)), MetadataTab(entry: entry)),
      (const Tab(icon: Icon(AIcons.image)), _buildThumbnailsTabView()),
    ];
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Debug'),
            bottom: TabBar(
              tabs: tabs.map((t) => t.$1).toList(),
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              children: tabs.map((t) => t.$2).toList(),
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
        } catch (error) {
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
            'origin': '${entry.origin}',
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
            'dateAddedSecs': toDateValue(entry.dateAddedSecs, factor: 1000),
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
            'displaySize': '${entry.displaySize.width}x${entry.displaySize.height}',
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
            'isVideo': '${entry.isVideo}',
            'isCatalogued': '${entry.isCatalogued}',
            'is360': '${entry.is360}',
            'isAnimated': '${entry.isAnimated}',
            'isGeotiff': '${entry.isGeotiff}',
            'isHdr': '${entry.isHdr}',
            'isMultiPage': '${entry.isMultiPage}',
            'isMotionPhoto': '${entry.isMotionPhoto}',
            'canEdit': '${entry.canEdit}',
            'canEditDate': '${entry.canEditDate}',
            'canEditTags': '${entry.canEditTags}',
            'canRotate': '${entry.canRotate}',
            'canFlip': '${entry.canFlip}',
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
}
