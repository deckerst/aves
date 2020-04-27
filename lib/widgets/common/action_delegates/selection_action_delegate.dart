import 'dart:async';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/widgets/common/action_delegates/permission_aware.dart';
import 'package:aves/widgets/common/entry_actions.dart';
import 'package:collection/collection.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SelectionActionDelegate with PermissionAwareMixin {
  final CollectionLens collection;

  SelectionActionDelegate({
    @required this.collection,
  });

  void onActionSelected(BuildContext context, EntryAction action) {
    switch (action) {
      case EntryAction.delete:
        _showDeleteDialog(context);
        break;
      case EntryAction.share:
        _share();
        break;
      default:
        break;
    }
  }

  void _showDeleteDialog(BuildContext context) async {
    final selection = collection.selection.toList();
    final count = selection.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Are you sure you want to delete ${Intl.plural(count, one: 'this item', other: 'these ${count} items')}?'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            FlatButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    if (!await checkStoragePermission(context, selection)) return;

    _showOpReport(
      context: context,
      selection: selection,
      opStream: ImageFileService.delete(selection),
      onDone: (processed) {
        final deletedUris = processed.where((e) => e.success).map((e) => e.uri);
        final deletedCount = deletedUris.length;
        final selectionCount = selection.length;
        if (deletedCount < selectionCount) {
          _showFeedback(context, 'Failed to delete ${selectionCount - deletedCount} items');
        }
        if (deletedCount > 0) {
          collection.source.removeEntries(selection.where((e) => deletedUris.contains(e.uri)));
        }
        collection.browse();
      },
    );
  }

  void _share() {
    final urisByMimeType = groupBy<ImageEntry, String>(collection.selection, (e) => e.mimeType).map((k, v) => MapEntry(k, v.map((e) => e.uri).toList()));
    AndroidAppService.share(urisByMimeType);
  }

  // selection action report overlay

  OverlayEntry _opReportOverlayEntry;

  static const _overlayAnimationDuration = Duration(milliseconds: 300);

  void _showOpReport({
    @required BuildContext context,
    @required List<ImageEntry> selection,
    @required Stream<ImageOpEvent> opStream,
    @required void Function(Set<ImageOpEvent> processed) onDone,
  }) {
    final processed = <ImageOpEvent>{};
    _opReportOverlayEntry = OverlayEntry(
      builder: (context) {
        return StreamBuilder<ImageOpEvent>(
            stream: opStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                processed.add(snapshot.data);
              }

              Widget child = const SizedBox.shrink();
              if (snapshot.hasError || snapshot.connectionState == ConnectionState.done) {
                _hideOpReportOverlay().then((_) => onDone(processed));
              } else if (snapshot.connectionState == ConnectionState.active) {
                final percent = processed.length.toDouble() / selection.length;
                child = CircularPercentIndicator(
                  percent: percent,
                  lineWidth: 16,
                  radius: 160,
                  backgroundColor: Colors.white24,
                  progressColor: Theme.of(context).accentColor,
                  animation: true,
                  center: Text(NumberFormat.percentPattern().format(percent)),
                  animateFromLastPercent: true,
                );
              }
              return AnimatedSwitcher(
                duration: _overlayAnimationDuration,
                child: child,
              );
            });
      },
    );
    Overlay.of(context).insert(_opReportOverlayEntry);
  }

  Future<void> _hideOpReportOverlay() async {
    await Future.delayed(_overlayAnimationDuration);
    _opReportOverlayEntry.remove();
    _opReportOverlayEntry = null;
  }

  void _showFeedback(BuildContext context, String message) {
    Flushbar(
      message: message,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      borderColor: Colors.white30,
      borderWidth: 0.5,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 600),
    ).show(context);
  }
}
