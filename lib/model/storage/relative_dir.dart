import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class VolumeRelativeDirectory extends Equatable {
  final String volumePath, relativeDir;

  @override
  List<Object?> get props => [volumePath, relativeDir];

  String get dirPath => '$volumePath$relativeDir';

  const VolumeRelativeDirectory({
    required this.volumePath,
    required this.relativeDir,
  });

  static VolumeRelativeDirectory fromMap(Map map) {
    return VolumeRelativeDirectory(
      volumePath: map['volumePath'] ?? '',
      relativeDir: map['relativeDir'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'volumePath': volumePath,
        'relativeDir': relativeDir,
      };

  // prefer static method over a null returning factory constructor
  static VolumeRelativeDirectory? fromPath(String dirPath) {
    final volume = androidFileUtils.getStorageVolume(dirPath);
    if (volume == null) return null;

    final root = volume.path;
    final rootLength = root.length;
    return VolumeRelativeDirectory(
      volumePath: root,
      relativeDir: dirPath.length < rootLength ? '' : dirPath.substring(rootLength),
    );
  }

  String getVolumeDescription(BuildContext context) {
    final volume = androidFileUtils.storageVolumes.firstWhereOrNull((volume) => volume.path == volumePath);
    return volume?.getDescription(context) ?? volumePath;
  }
}
