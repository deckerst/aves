import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_metadata_edition.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/metadata/enums/enums.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_date_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_description_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_location_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_rating_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_tags_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/remove_metadata_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

mixin EntryEditorMixin {
  Future<DateModifier?> selectDateModifier(BuildContext context, Set<AvesEntry> entries, CollectionLens? collection) async {
    if (entries.isEmpty) return null;

    return showDialog<DateModifier>(
      context: context,
      builder: (context) => EditEntryDateDialog(
        entry: entries.first,
        collection: collection,
      ),
    );
  }

  Future<LatLng?> selectLocation(BuildContext context, Set<AvesEntry> entries, CollectionLens? collection) async {
    if (entries.isEmpty) return null;

    final entry = entries.firstWhereOrNull((entry) => entry.hasGps) ?? entries.first;

    return showDialog<LatLng>(
      context: context,
      builder: (context) => EditEntryLocationDialog(
        entry: entry,
        collection: collection,
      ),
    );
  }

  Future<Map<DescriptionField, String?>?> selectTitleDescriptionModifier(BuildContext context, Set<AvesEntry> entries) async {
    if (entries.isEmpty) return null;

    final entry = entries.first;
    final initialTitle = entry.catalogMetadata?.xmpTitle ?? '';
    final initialDescription = await metadataFetchService.getDescription(entry) ?? '';

    return showDialog<Map<DescriptionField, String?>>(
      context: context,
      builder: (context) => EditEntryTitleDescriptionDialog(
        initialTitle: initialTitle,
        initialDescription: initialDescription,
      ),
    );
  }

  Future<int?> selectRating(BuildContext context, Set<AvesEntry> entries) async {
    if (entries.isEmpty) return null;

    return showDialog<int>(
      context: context,
      builder: (context) => EditEntryRatingDialog(
        entry: entries.first,
      ),
    );
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
