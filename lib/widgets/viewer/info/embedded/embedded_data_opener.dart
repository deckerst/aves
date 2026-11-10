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

class EmbeddedDataOpener extends StatelessWidget with FeedbackMixin {
  final bool enabled;
  final AvesEntry entry;
  final Widget child;

  const new({
    super.key,
    required this.enabled,
    required this.entry,
    required this.child,
  });

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
    final mimeType = fields[EntryFields.mimeType] as String?;
    final uri = fields[EntryFields.uri] as String?;
    if (mimeType == null || uri == null) {
      showFeedback(context, FeedbackType.warn, context.l10n.viewerInfoOpenEmbeddedFailureFeedback);
      return;
    }

    if (!MimeTypes.isImage(mimeType) && !MimeTypes.isVideo(mimeType)) {
      // open with another app
      unawaited(
        appService.open(uri, mimeType, forceChooser: true).then((success) {
          if (!success) {
            // fallback to sharing, so that the file can be saved somewhere
            appService.shareSingle(uri, mimeType).then((success) {
              if (!success) showNoMatchingAppDialog(context);
            });
          }
        }),
      );
      return;
    }

    _openTempEntry(context, AvesEntry.fromMap(fields));
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
