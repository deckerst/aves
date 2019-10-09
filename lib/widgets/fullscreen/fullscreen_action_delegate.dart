import 'dart:io';

import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_app_service.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';

enum FullscreenAction { delete, edit, info, open, openMap, print, rename, rotateCCW, rotateCW, setAs, share }

class FullscreenActionDelegate {
  final ImageCollection collection;
  final VoidCallback showInfo;

  FullscreenActionDelegate({
    @required this.collection,
    @required this.showInfo,
  });

  onActionSelected(BuildContext context, ImageEntry entry, FullscreenAction action) {
    switch (action) {
      case FullscreenAction.delete:
        _showDeleteDialog(context, entry);
        break;
      case FullscreenAction.edit:
        AndroidAppService.edit(entry.uri, entry.mimeType);
        break;
      case FullscreenAction.info:
        showInfo();
        break;
      case FullscreenAction.rename:
        _showRenameDialog(context, entry);
        break;
      case FullscreenAction.open:
        AndroidAppService.open(entry.uri, entry.mimeType);
        break;
      case FullscreenAction.openMap:
        AndroidAppService.openMap(entry.geoUri);
        break;
      case FullscreenAction.print:
        _print(entry);
        break;
      case FullscreenAction.rotateCCW:
        _rotate(context, entry, clockwise: false);
        break;
      case FullscreenAction.rotateCW:
        _rotate(context, entry, clockwise: true);
        break;
      case FullscreenAction.setAs:
        AndroidAppService.setAs(entry.uri, entry.mimeType);
        break;
      case FullscreenAction.share:
        AndroidAppService.share(entry.uri, entry.mimeType);
        break;
    }
  }

  _showFeedback(BuildContext context, String message) {
    Flushbar(
      message: message,
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      borderColor: Colors.white30,
      borderWidth: 0.5,
      duration: Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: Duration(milliseconds: 600),
    )..show(context);
  }

  _print(ImageEntry entry) async {
    final doc = pdf.Document(title: entry.title);
    final image = await pdfImageFromImageProvider(
      pdf: doc.document,
      image: FileImage(File(entry.path)),
    );
    doc.addPage(pdf.Page(build: (context) => pdf.Center(child: pdf.Image(image)))); // Page
    Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: entry.title,
    );
  }

  _rotate(BuildContext context, ImageEntry entry, {@required bool clockwise}) async {
    final success = await entry.rotate(clockwise: clockwise);
    _showFeedback(context, success ? 'Done!' : 'Failed');
  }

  _showDeleteDialog(BuildContext context, ImageEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Are you sure?'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL'),
            ),
            FlatButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('DELETE'),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;
    if (!await collection.delete(entry)) {
      _showFeedback(context, 'Failed');
    } else if (collection.sortedEntries.isEmpty) {
      Navigator.pop(context);
    }
  }

  _showRenameDialog(BuildContext context, ImageEntry entry) async {
    final currentName = entry.title;
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: TextField(
              controller: controller,
              autofocus: true,
            ),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('CANCEL'),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text('APPLY'),
              ),
            ],
          );
        });
    if (newName == null || newName.isEmpty) return;
    _showFeedback(context, await entry.rename(newName) ? 'Done!' : 'Failed');
  }
}
