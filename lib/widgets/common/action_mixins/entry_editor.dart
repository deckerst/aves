import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/metadata/enums.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_entry_date_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_entry_tags_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/remove_entry_metadata_dialog.dart';
import 'package:flutter/material.dart';

mixin EntryEditorMixin {
  Future<DateModifier?> selectDateModifier(BuildContext context, Set<AvesEntry> entries) async {
    if (entries.isEmpty) return null;

    final modifier = await showDialog<DateModifier>(
      context: context,
      builder: (context) => EditEntryDateDialog(
        entry: entries.first,
      ),
    );
    return modifier;
  }

  Future<Map<AvesEntry, Set<String>>?> selectTags(BuildContext context, Set<AvesEntry> entries) async {
    if (entries.isEmpty) return null;

    final tagsByEntry = Map.fromEntries(entries.map((v) => MapEntry(v, v.tags.toSet())));
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: TagEditorPage.routeName),
        builder: (context) => TagEditorPage(
          tagsByEntry: tagsByEntry,
        ),
      ),
    );

    return tagsByEntry;
  }

  Future<Set<MetadataType>?> selectMetadataToRemove(BuildContext context, Set<AvesEntry> entries) async {
    if (entries.isEmpty) return null;

    final types = await showDialog<Set<MetadataType>>(
      context: context,
      builder: (context) => RemoveEntryMetadataDialog(
        showJpegTypes: entries.any((entry) => entry.mimeType == MimeTypes.jpeg),
      ),
    );
    if (types == null || types.isEmpty) return null;

    if (entries.any((entry) => entry.isMotionPhoto) && types.contains(MetadataType.xmp)) {
      final confirmed = await showDialog<bool>(
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
      if (confirmed == null || !confirmed) return null;
    }

    return types;
  }
}
