import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

extension ExtraVolumeRelativeDirectoryView on VolumeRelativeDirectory {
  String getVolumeDescription(BuildContext context) {
    final volume = androidFileUtils.storageVolumes.firstWhereOrNull((volume) => volume.path == volumePath);
    return volume?.getDescription(context) ?? volumePath;
  }
}
