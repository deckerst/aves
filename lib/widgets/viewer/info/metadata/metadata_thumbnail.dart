import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:aves/widgets/viewer/info/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/info_page.dart';
import 'package:material_ui/material_ui.dart';

class const MetadataThumbnails({
  super.key,
  required final AvesEntry entry,
}) extends StatefulWidget {
  @override
  State<MetadataThumbnails> createState() => _MetadataThumbnailsState();
}

class _MetadataThumbnailsState extends State<MetadataThumbnails> {
  late Future<AvesEntry?> _loader;

  @override
  void initState() {
    super.initState();
    _loader = embeddedDataService.extractExifThumbnail(widget.entry).then(AvesEntry.maybeFromFields);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AvesEntry?>(
      future: _loader,
      builder: (context, snapshot) {
        final thumbnailEntry = snapshot.data;
        if (thumbnailEntry == null) return const SizedBox();

        return Container(
          alignment: .topStart,
          padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 4),
          child: GestureDetector(
            onTap: () => OpenEmbeddedDataNotification.exifThumbnail().dispatch(context),
            child: DecoratedThumbnail(
              entry: thumbnailEntry,
              tileExtent: InfoPage.inlineThumbnailExtent,
              isMosaic: true,
              selectable: false,
              highlightable: false,
            ),
          ),
        );
      },
    );
  }
}
