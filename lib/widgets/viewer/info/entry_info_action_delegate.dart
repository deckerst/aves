import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_info_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/common/action_mixins/entry_editor.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryInfoActionDelegate with EntryEditorMixin, FeedbackMixin, PermissionAwareMixin {
  final AvesEntry entry;

  const EntryInfoActionDelegate(this.entry);

  bool isVisible(EntryInfoAction action) {
    switch (action) {
      // general
      case EntryInfoAction.editDate:
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
        return entry.canEditExif;
      case EntryInfoAction.removeMetadata:
        return entry.canRemoveMetadata;
      // motion photo
      case EntryInfoAction.viewMotionPhotoVideo:
        return true;
    }
  }

  void onActionSelected(BuildContext context, EntryInfoAction action) async {
    switch (action) {
      // general
      case EntryInfoAction.editDate:
        await _editDate(context);
        break;
      case EntryInfoAction.removeMetadata:
        await _removeMetadata(context);
        break;
      // motion photo
      case EntryInfoAction.viewMotionPhotoVideo:
        OpenEmbeddedDataNotification.motionPhotoVideo().dispatch(context);
        break;
    }
  }

  bool _isMainMode(BuildContext context) => context.read<ValueNotifier<AppMode>>().value == AppMode.main;

  Future<void> _edit(BuildContext context, Future<bool> Function() apply) async {
    if (!await checkStoragePermission(context, {entry})) return;

    final l10n = context.l10n;
    final source = context.read<CollectionSource?>();
    source?.pauseMonitoring();
    final success = await apply();
    if (success) {
      if (_isMainMode(context) && source != null) {
        await source.refreshEntry(entry);
      } else {
        await entry.refresh(background: false, persist: false, force: true, geocoderLocale: settings.appliedLocale);
      }
      showFeedback(context, l10n.genericSuccessFeedback);
    } else {
      showFeedback(context, l10n.genericFailureFeedback);
    }
    source?.resumeMonitoring();
  }

  Future<void> _editDate(BuildContext context) async {
    final modifier = await selectDateModifier(context, {entry});
    if (modifier == null) return;

    await _edit(context, () => entry.editDate(modifier));
  }

  Future<void> _removeMetadata(BuildContext context) async {
    final types = await selectMetadataToRemove(context, {entry});
    if (types == null) return;

    await _edit(context, () => entry.removeMetadata(types));
  }
}
