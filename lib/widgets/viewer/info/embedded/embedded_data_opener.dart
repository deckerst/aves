import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/keys.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:aves/widgets/viewer/info/embedded/notifications.dart';
import 'package:material_ui/material_ui.dart';

class const EmbeddedDataOpener({
  super.key,
  required final bool enabled,
  required final AvesEntry entry,
  required final Widget child,
}) extends StatelessWidget with FeedbackMixin {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<OpenEmbeddedDataNotification>(
      onNotification: (notification) {
        if (enabled) {
          _openEmbeddedData(context, notification);
          return true;
        }
        return false;
      },
      child: child,
    );
  }

  Future<void> _openEmbeddedData(BuildContext context, OpenEmbeddedDataNotification notification) async {
    late Map fields;
    switch (notification.source) {
      case .c2paResource:
        fields = await embeddedDataService.extractC2paResource(entry, notification.dataUri!);
      case .exifThumbnail:
        fields = await embeddedDataService.extractExifThumbnail(entry);
      case .googleDevice:
        fields = await embeddedDataService.extractGoogleDeviceItem(entry, notification.dataUri!);
      case .motionPhotoVideo:
        fields = await embeddedDataService.extractMotionPhotoVideo(entry);
      case .mpf:
        fields = await embeddedDataService.extractJpegMpfItem(entry, notification.mpfId!);
      case .videoCover:
        fields = await embeddedDataService.extractVideoEmbeddedPicture(entry);
      case .xmp:
        fields = await embeddedDataService.extractXmpDataProp(entry, notification.propPath, notification.mimeType);
    }

    AvesEntry.normalizeMimeTypeFields(fields);
    final embeddedMimeType = fields[EntryFields.mimeType] as String?;
    final embeddedUri = fields[EntryFields.uri] as String?;
    if (embeddedMimeType == null || embeddedUri == null) {
      showFeedback(context, FeedbackType.warn, context.l10n.viewerInfoOpenEmbeddedFailureFeedback);
      return;
    }

    if (!MimeTypes.isImage(embeddedMimeType) && !MimeTypes.isVideo(embeddedMimeType)) {
      // open with another app
      unawaited(
        appService.open(embeddedUri, embeddedMimeType, forceChooser: true).then((success) {
          if (!success) {
            // fallback to sharing, so that the file can be saved somewhere
            appService.shareSingle(embeddedUri, embeddedMimeType).then((success) {
              if (!success) showNoMatchingAppDialog(context);
            });
          }
        }),
      );
      return;
    }

    final embeddedEntry = AvesEntry.maybeFromFields(fields);
    if (embeddedEntry != null) {
      _openTempEntry(context, embeddedEntry);
    }
  }

  void _openTempEntry(BuildContext context, AvesEntry tempEntry) {
    Navigator.maybeOf(context)?.push(
      // When `PredictiveBackPageTransitionsBuilder` is the transition used for page N-1,
      // N-1 slides away and page N-2 (if any) briefly flashes, while the new page is fading in.
      // So we prefer an opaque route over a transparent one, to hide pages below.
      MaterialPageRoute(
        settings: const RouteSettings(name: EntryViewerPage.routeName),
        builder: (context) => EntryViewerPage(initialEntry: tempEntry),
      ),
    );
  }
}
