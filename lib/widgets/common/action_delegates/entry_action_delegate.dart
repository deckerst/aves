import 'dart:io';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/widgets/common/action_delegates/feedback.dart';
import 'package:aves/widgets/common/action_delegates/permission_aware.dart';
import 'package:aves/widgets/common/action_delegates/rename_entry_dialog.dart';
import 'package:aves/widgets/common/entry_actions.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';
import 'package:aves/widgets/fullscreen/debug.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:pedantic/pedantic.dart';
import 'package:printing/printing.dart';

class EntryActionDelegate with FeedbackMixin, PermissionAwareMixin {
  final CollectionLens collection;
  final VoidCallback showInfo;

  EntryActionDelegate({
    @required this.collection,
    @required this.showInfo,
  });

  bool get hasCollection => collection != null;

  void onActionSelected(BuildContext context, ImageEntry entry, EntryAction action) {
    switch (action) {
      case EntryAction.toggleFavourite:
        entry.toggleFavourite();
        break;
      case EntryAction.delete:
        _showDeleteDialog(context, entry);
        break;
      case EntryAction.edit:
        AndroidAppService.edit(entry.uri, entry.mimeType);
        break;
      case EntryAction.info:
        showInfo();
        break;
      case EntryAction.rename:
        _showRenameDialog(context, entry);
        break;
      case EntryAction.open:
        AndroidAppService.open(entry.uri, entry.mimeTypeAnySubtype);
        break;
      case EntryAction.openMap:
        AndroidAppService.openMap(entry.geoUri);
        break;
      case EntryAction.print:
        _print(entry);
        break;
      case EntryAction.rotateCCW:
        _rotate(context, entry, clockwise: false);
        break;
      case EntryAction.rotateCW:
        _rotate(context, entry, clockwise: true);
        break;
      case EntryAction.setAs:
        AndroidAppService.setAs(entry.uri, entry.mimeType);
        break;
      case EntryAction.share:
        AndroidAppService.share({
          entry.mimeType: [entry.uri]
        });
        break;
      case EntryAction.debug:
        _goToDebug(context, entry);
        break;
    }
  }

  Future<void> _print(ImageEntry entry) async {
    final uri = entry.uri;
    final mimeType = entry.mimeType;
    final documentName = entry.bestTitle ?? 'Aves';
    final doc = pdf.Document(title: documentName);

    PdfImage pdfImage;
    if (entry.isSvg) {
      final bytes = await ImageFileService.getImage(uri, mimeType);
      if (bytes != null && bytes.isNotEmpty) {
        final svgRoot = await svg.fromSvgBytes(bytes, uri);
        final viewBox = svgRoot.viewport.viewBox;
        // 1000 is arbitrary, but large enough to look ok in the print preview
        final targetSize = viewBox * 1000 / viewBox.longestSide;
        final picture = svgRoot.toPicture(size: targetSize);
        final uiImage = await picture.toImage(targetSize.width.ceil(), targetSize.height.ceil());
        pdfImage = await pdfImageFromImage(
          pdf: doc.document,
          image: uiImage,
        );
      }
    } else {
      pdfImage = await pdfImageFromImageProvider(
        pdf: doc.document,
        image: UriImage(uri: uri, mimeType: mimeType),
      );
    }
    if (pdfImage != null) {
      doc.addPage(pdf.Page(build: (context) => pdf.Center(child: pdf.Image(pdfImage)))); // Page
      unawaited(Printing.layoutPdf(
        onLayout: (format) => doc.save(),
        name: documentName,
      ));
    }
  }

  Future<void> _rotate(BuildContext context, ImageEntry entry, {@required bool clockwise}) async {
    if (!await checkStoragePermission(context, [entry])) return;

    final success = await entry.rotate(clockwise: clockwise);
    if (!success) showFeedback(context, 'Failed');
  }

  Future<void> _showDeleteDialog(BuildContext context, ImageEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Are you sure?'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.toUpperCase()),
            ),
            FlatButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'.toUpperCase()),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    if (!await checkStoragePermission(context, [entry])) return;

    if (!await entry.delete()) {
      showFeedback(context, 'Failed');
    } else if (hasCollection) {
      // update collection
      collection.source.removeEntries([entry]);
      if (collection.sortedEntries.isEmpty) {
        Navigator.pop(context);
      }
    } else {
      // leave viewer
      exit(0);
    }
  }

  Future<void> _showRenameDialog(BuildContext context, ImageEntry entry) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameEntryDialog(entry),
    );
    if (newName == null || newName.isEmpty) return;

    if (!await checkStoragePermission(context, [entry])) return;

    showFeedback(context, await entry.rename(newName) ? 'Done!' : 'Failed');
  }

  void _goToDebug(BuildContext context, ImageEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenDebugPage(entry: entry),
      ),
    );
  }
}
