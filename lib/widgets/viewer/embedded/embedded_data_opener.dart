import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:flutter/material.dart';

class EmbeddedDataOpener extends StatelessWidget with FeedbackMixin {
  final AvesEntry entry;
  final Widget child;

  const EmbeddedDataOpener({
    super.key,
    required this.entry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OpenEmbeddedDataNotification>(
      onNotification: (notification) {
        _openEmbeddedData(context, notification);
        return true;
      },
      child: child,
    );
  }

  Future<void> _openEmbeddedData(BuildContext context, OpenEmbeddedDataNotification notification) async {
    late Map fields;
    switch (notification.source) {
      case EmbeddedDataSource.motionPhotoVideo:
        fields = await embeddedDataService.extractMotionPhotoVideo(entry);
        break;
      case EmbeddedDataSource.videoCover:
        fields = await embeddedDataService.extractVideoEmbeddedPicture(entry);
        break;
      case EmbeddedDataSource.xmp:
        fields = await embeddedDataService.extractXmpDataProp(entry, notification.propPath, notification.mimeType);
        break;
    }
    if (!fields.containsKey('mimeType') || !fields.containsKey('uri')) {
      showFeedback(context, context.l10n.viewerInfoOpenEmbeddedFailureFeedback);
      return;
    }

    final mimeType = fields['mimeType']!;
    final uri = fields['uri']!;
    if (!MimeTypes.isImage(mimeType) && !MimeTypes.isVideo(mimeType)) {
      // open with another app
      unawaited(androidAppService.open(uri, mimeType).then((success) {
        if (!success) {
          // fallback to sharing, so that the file can be saved somewhere
          androidAppService.shareSingle(uri, mimeType).then((success) {
            if (!success) showNoMatchingAppDialog(context);
          });
        }
      }));
      return;
    }

    _openTempEntry(context, AvesEntry.fromMap(fields));
  }

  void _openTempEntry(BuildContext context, AvesEntry tempEntry) {
    Navigator.push(
      context,
      TransparentMaterialPageRoute(
        settings: const RouteSettings(name: EntryViewerPage.routeName),
        pageBuilder: (context, a, sa) => EntryViewerPage(
          initialEntry: tempEntry,
        ),
      ),
    );
  }
}
