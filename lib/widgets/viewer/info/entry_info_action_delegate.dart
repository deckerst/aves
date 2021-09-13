import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_info_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/metadata/enums.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/edit_entry_date_dialog.dart';
import 'package:aves/widgets/dialogs/remove_entry_metadata_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryInfoActionDelegate with FeedbackMixin, PermissionAwareMixin {
  final AvesEntry entry;

  const EntryInfoActionDelegate(this.entry);

  void onActionSelected(BuildContext context, EntryInfoAction action) async {
    switch (action) {
      case EntryInfoAction.editDate:
        await _showDateEditDialog(context);
        break;
      case EntryInfoAction.removeMetadata:
        await _showMetadataRemovalDialog(context);
        break;
    }
  }

  bool _isMainMode(BuildContext context) => context.read<ValueNotifier<AppMode>>().value == AppMode.main;

  Future<void> _edit(BuildContext context, Future<bool> Function() apply) async {
    if (!await checkStoragePermission(context, {entry})) return;

    final source = context.read<CollectionSource?>();
    source?.pauseMonitoring();
    final success = await apply();
    if (success) {
      showFeedback(context, context.l10n.genericSuccessFeedback);
    } else {
      showFeedback(context, context.l10n.genericFailureFeedback);
    }
    source?.resumeMonitoring();
  }

  Future<void> _showDateEditDialog(BuildContext context) async {
    final modifier = await showDialog<DateModifier>(
      context: context,
      builder: (context) => EditEntryDateDialog(entry: entry),
    );
    if (modifier == null) return;

    await _edit(context, () => entry.editDate(modifier, persist: _isMainMode(context)));
  }

  Future<void> _showMetadataRemovalDialog(BuildContext context) async {
    final types = await showDialog<Set<MetadataType>>(
      context: context,
      builder: (context) => RemoveEntryMetadataDialog(entry: entry),
    );
    if (types == null || types.isEmpty) return;

    if (entry.isMotionPhoto && types.contains(MetadataType.xmp)) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AvesDialog(
            context: context,
            content: Text(context.l10n.removeEntryMetadataMotionPhotoXmpWarningDialogMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.applyButtonLabel),
              ),
            ],
          );
        },
      );
      if (proceed == null || !proceed) return;
    }

    await _edit(context, () => entry.removeMetadata(types, persist: _isMainMode(context)));
  }
}
