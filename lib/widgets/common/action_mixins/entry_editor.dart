import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/metadata_edition.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/placeholder.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_date_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_description_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_location_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/edit_rating_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/remove_metadata_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/tag_editor_page.dart';
import 'package:aves_model/aves_model.dart';
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
      routeSettings: const RouteSettings(name: EditEntryDateDialog.routeName),
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
      routeSettings: const RouteSettings(name: EditEntryLocationDialog.routeName),
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
      routeSettings: const RouteSettings(name: EditEntryTitleDescriptionDialog.routeName),
    );
  }

  Future<int?> selectRating(BuildContext context, Set<AvesEntry> entries) async {
    if (entries.isEmpty) return null;

    return showDialog<int>(
      context: context,
      builder: (context) => EditEntryRatingDialog(
        entry: entries.first,
      ),
      routeSettings: const RouteSettings(name: EditEntryRatingDialog.routeName),
    );
  }

  Future<Map<AvesEntry, Set<String>>?> selectTags(BuildContext context, Set<AvesEntry> entries) async {
    if (entries.isEmpty) return null;

    final filtersByEntry = Map.fromEntries(entries.map((v) {
      return MapEntry(v, v.tags.map(TagFilter.new).toSet());
    }));
    await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: TagEditorPage.routeName),
        builder: (context) => TagEditorPage(
          filtersByEntry: filtersByEntry,
        ),
      ),
    );

    final tagsByEntry = <AvesEntry, Set<String>>{};
    await Future.forEach(filtersByEntry.entries, (kv) async {
      final entry = kv.key;
      final filters = kv.value;
      tagsByEntry[entry] = await getTagsFromFilters(filters, entry);
    });

    return tagsByEntry;
  }

  Future<Set<String>> getTagsFromFilters(Set<CollectionFilter> filters, AvesEntry entry) async {
    final tags = filters.whereType<TagFilter>().map((v) => v.tag).toSet();
    final placeholderTags = await Future.wait(filters.whereType<PlaceholderFilter>().map((v) => v.toTag(entry)));
    tags.addAll(placeholderTags.whereNotNull().where((v) => v.isNotEmpty));
    return tags;
  }

  Future<Set<MetadataType>?> selectMetadataToRemove(BuildContext context, Set<AvesEntry> entries) async {
    if (entries.isEmpty) return null;

    final types = await showDialog<Set<MetadataType>>(
      context: context,
      builder: (context) => RemoveEntryMetadataDialog(
        showJpegTypes: entries.any((entry) => entry.mimeType == MimeTypes.jpeg),
      ),
      routeSettings: const RouteSettings(name: RemoveEntryMetadataDialog.routeName),
    );
    if (types == null || types.isEmpty) return null;

    if (entries.any((entry) => entry.isMotionPhoto) && types.contains(MetadataType.xmp)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AvesDialog(
          content: Text(context.l10n.removeEntryMetadataMotionPhotoXmpWarningDialogMessage),
          actions: [
            const CancelButton(),
            TextButton(
              onPressed: () => Navigator.maybeOf(context)?.pop(true),
              child: Text(context.l10n.applyButtonLabel),
            ),
          ],
        ),
        routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
      );
      if (confirmed == null || !confirmed) return null;
    }

    return types;
  }
}
