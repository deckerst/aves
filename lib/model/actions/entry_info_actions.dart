import 'package:aves/theme/colors.dart';
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
  // GeoTIFF
  showGeoTiffOnMap,
  // motion photo
  convertMotionPhotoToStillImage,
  viewMotionPhotoVideo,
  // debug
  debug,
}

class EntryInfoActions {
  static const common = [
    EntryInfoAction.editDate,
    EntryInfoAction.editLocation,
    EntryInfoAction.editRating,
    EntryInfoAction.editTags,
    EntryInfoAction.removeMetadata,
  ];

  static const formatSpecific = [
    EntryInfoAction.showGeoTiffOnMap,
    EntryInfoAction.convertMotionPhotoToStillImage,
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
      // GeoTIFF
      case EntryInfoAction.showGeoTiffOnMap:
        return context.l10n.entryActionShowGeoTiffOnMap;
      // motion photo
      case EntryInfoAction.convertMotionPhotoToStillImage:
        return context.l10n.entryActionConvertMotionPhotoToStillImage;
      case EntryInfoAction.viewMotionPhotoVideo:
        return context.l10n.entryActionViewMotionPhotoVideo;
      // debug
      case EntryInfoAction.debug:
        return 'Debug';
    }
  }

  Widget getIcon() {
    final child = Icon(_getIconData());
    switch (this) {
      case EntryInfoAction.debug:
        return ShaderMask(
          shaderCallback: AvesColorsData.debugGradient.createShader,
          blendMode: BlendMode.srcIn,
          child: child,
        );
      default:
        return child;
    }
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
      // GeoTIFF
      case EntryInfoAction.showGeoTiffOnMap:
        return AIcons.map;
      // motion photo
      case EntryInfoAction.convertMotionPhotoToStillImage:
        return AIcons.convertToStillImage;
      case EntryInfoAction.viewMotionPhotoVideo:
        return AIcons.openVideo;
      // debug
      case EntryInfoAction.debug:
        return AIcons.debug;
    }
  }
}
