import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:aves/widgets/viewer/info/embedded/notifications.dart';
import 'package:aves/widgets/viewer/info/info_page.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class const ManifestThumbnail({
  super.key,
  required final AvesEntry entry,
  required final String? thumbnailUri,
}) extends StatefulWidget {
  @override
  State<ManifestThumbnail> createState() => _ManifestThumbnailState();
}

class _ManifestThumbnailState extends State<ManifestThumbnail> {
  late final Future<AvesEntry?> _loader;

  @override
  void initState() {
    super.initState();
    final thumbnailUri = widget.thumbnailUri;
    _loader = thumbnailUri != null ? embeddedDataService.extractC2paResource(widget.entry, thumbnailUri).then(AvesEntry.maybeFromFields) : SynchronousFuture(null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AvesEntry?>(
      future: _loader,
      builder: (context, snapshot) {
        final thumbnailEntry = snapshot.data;
        if (thumbnailEntry == null) return const SizedBox();

        final thumbnailUri = widget.thumbnailUri;
        return GestureDetector(
          onTap: thumbnailUri != null ? () => OpenEmbeddedDataNotification.c2paResource(dataUri: thumbnailUri).dispatch(context) : null,
          child: DecoratedThumbnail(
            entry: thumbnailEntry,
            tileExtent: InfoPage.inlineThumbnailExtent,
            isMosaic: true,
            selectable: false,
            highlightable: false,
          ),
        );
      },
    );
  }
}
