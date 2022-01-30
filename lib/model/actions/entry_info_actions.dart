import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum EntryInfoAction {
  // general
  editDate,
  editLocation,
  editRating,
  editTags,
  removeMetadata,
  // motion photo
  viewMotionPhotoVideo,
}

class EntryInfoActions {
  static const all = [
    EntryInfoAction.editDate,
    EntryInfoAction.editLocation,
    EntryInfoAction.editRating,
    EntryInfoAction.editTags,
    EntryInfoAction.removeMetadata,
    EntryInfoAction.viewMotionPhotoVideo,
  ];
}

extension ExtraEntryInfoAction on EntryInfoAction {
  String getText(BuildContext context) {
    switch (this) {
      // general
      case EntryInfoAction.editDate:
        return context.l10n.entryInfoActionEditDate;
      case EntryInfoAction.editLocation:
        return context.l10n.entryInfoActionEditLocation;
      case EntryInfoAction.editRating:
        return context.l10n.entryInfoActionEditRating;
      case EntryInfoAction.editTags:
        return context.l10n.entryInfoActionEditTags;
      case EntryInfoAction.removeMetadata:
        return context.l10n.entryInfoActionRemoveMetadata;
      // motion photo
      case EntryInfoAction.viewMotionPhotoVideo:
        return context.l10n.entryActionViewMotionPhotoVideo;
    }
  }

  Widget getIcon() {
    return Icon(_getIconData());
  }

  IconData _getIconData() {
    switch (this) {
      // general
      case EntryInfoAction.editDate:
        return AIcons.date;
      case EntryInfoAction.editLocation:
        return AIcons.location;
      case EntryInfoAction.editRating:
        return AIcons.editRating;
      case EntryInfoAction.editTags:
        return AIcons.editTags;
      case EntryInfoAction.removeMetadata:
        return AIcons.clear;
      // motion photo
      case EntryInfoAction.viewMotionPhotoVideo:
        return AIcons.motionPhoto;
    }
  }
}
