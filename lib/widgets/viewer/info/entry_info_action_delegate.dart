import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_info_actions.dart';
import 'package:aves/model/actions/events.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_xmp_iptc.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/entry_editor.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryInfoActionDelegate with EntryEditorMixin, FeedbackMixin, PermissionAwareMixin {
  final AvesEntry entry;

  final StreamController<ActionEvent<EntryInfoAction>> _eventStreamController = StreamController<ActionEvent<EntryInfoAction>>.broadcast();

  Stream<ActionEvent<EntryInfoAction>> get eventStream => _eventStreamController.stream;

  EntryInfoActionDelegate(this.entry);

  bool isVisible(EntryInfoAction action) {
    switch (action) {
      // general
      case EntryInfoAction.editDate:
      case EntryInfoAction.editTags:
      case EntryInfoAction.removeMetadata:
        return true;
      // motion photo
      case EntryInfoAction.viewMotionPhotoVideo:
        return entry.isMotionPhoto;
    }
  }

  bool canApply(EntryInfoAction action) {
    switch (action) {
      // general
      case EntryInfoAction.editDate:
        return entry.canEditDate;
      case EntryInfoAction.editTags:
        return entry.canEditTags;
      case EntryInfoAction.removeMetadata:
        return entry.canRemoveMetadata;
      // motion photo
      case EntryInfoAction.viewMotionPhotoVideo:
        return true;
    }
  }

  void onActionSelected(BuildContext context, EntryInfoAction action) async {
    _eventStreamController.add(ActionStartedEvent(action));
    switch (action) {
      // general
      case EntryInfoAction.editDate:
        await _editDate(context);
        break;
      case EntryInfoAction.editTags:
        await _editTags(context);
        break;
      case EntryInfoAction.removeMetadata:
        await _removeMetadata(context);
        break;
      // motion photo
      case EntryInfoAction.viewMotionPhotoVideo:
        OpenEmbeddedDataNotification.motionPhotoVideo().dispatch(context);
        break;
    }
    _eventStreamController.add(ActionEndedEvent(action));
  }

  bool _isMainMode(BuildContext context) => context.read<ValueNotifier<AppMode>>().value == AppMode.main;

  Future<void> _edit(BuildContext context, Future<Set<EntryDataType>> Function() apply) async {
    if (!await checkStoragePermission(context, {entry})) return;

    // check before applying, because it relies on provider
    // but the widget tree may be disposed if the user navigated away
    final isMainMode = _isMainMode(context);

    final l10n = context.l10n;
    final source = context.read<CollectionSource?>();
    source?.pauseMonitoring();

    final dataTypes = await apply();
    final success = dataTypes.isNotEmpty;
    try {
      if (success) {
        if (isMainMode && source != null) {
          await source.refreshEntry(entry, dataTypes);
        } else {
          await entry.refresh(background: false, persist: false, dataTypes: dataTypes, geocoderLocale: settings.appliedLocale);
        }
        showFeedback(context, l10n.genericSuccessFeedback);
      } else {
        showFeedback(context, l10n.genericFailureFeedback);
      }
    } catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    source?.resumeMonitoring();
  }

  Future<void> _editDate(BuildContext context) async {
    final modifier = await selectDateModifier(context, {entry});
    if (modifier == null) return;

    await _edit(context, () => entry.editDate(modifier));
  }

  Future<void> _editTags(BuildContext context) async {
    final newTagsByEntry = await selectTags(context, {entry});
    if (newTagsByEntry == null) return;

    final newTags = newTagsByEntry[entry] ?? entry.tags;
    final currentTags = entry.tags;
    if (newTags.length == currentTags.length && newTags.every(currentTags.contains)) return;

    await _edit(context, () => entry.editTags(newTags));
  }

  Future<void> _removeMetadata(BuildContext context) async {
    final types = await selectMetadataToRemove(context, {entry});
    if (types == null) return;

    await _edit(context, () => entry.removeMetadata(types));
  }
}
