import 'dart:async';

import 'package:aves/model/actions/entry_info_actions.dart';
import 'package:aves/model/actions/events.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_xmp_iptc.dart';
import 'package:aves/widgets/common/action_mixins/entry_editor.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/viewer/action/single_entry_editor.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:flutter/material.dart';

class EntryInfoActionDelegate with FeedbackMixin, PermissionAwareMixin, EntryEditorMixin, SingleEntryEditorMixin {
  @override
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

  Future<void> _editDate(BuildContext context) async {
    final modifier = await selectDateModifier(context, {entry});
    if (modifier == null) return;

    await edit(context, () => entry.editDate(modifier));
  }

  Future<void> _editTags(BuildContext context) async {
    final newTagsByEntry = await selectTags(context, {entry});
    if (newTagsByEntry == null) return;

    final newTags = newTagsByEntry[entry] ?? entry.tags;
    final currentTags = entry.tags;
    if (newTags.length == currentTags.length && newTags.every(currentTags.contains)) return;

    await edit(context, () => entry.editTags(newTags));
  }

  Future<void> _removeMetadata(BuildContext context) async {
    final types = await selectMetadataToRemove(context, {entry});
    if (types == null) return;

    await edit(context, () => entry.removeMetadata(types));
  }
}
