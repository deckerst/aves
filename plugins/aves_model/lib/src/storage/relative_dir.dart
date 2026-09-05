import 'package:aves_model/aves_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class const VolumeRelativeDirectory({
  required final String volumePath,
  required final String relativeDir,
}) extends Equatable {
  @override
  List<Object?> get props => [volumePath, relativeDir];

  String get dirPath => '$volumePath$relativeDir';

  factory volume(StorageVolume volume) {
    return VolumeRelativeDirectory(volumePath: volume.path, relativeDir: '');
  }

  static VolumeRelativeDirectory fromMap(Map map) {
    return VolumeRelativeDirectory(
      volumePath: map['volumePath'] ?? '',
      relativeDir: map['relativeDir'] ?? '',
    );
  }

  Map<String, String> toMap() => {
    'volumePath': volumePath,
    'relativeDir': relativeDir,
  };

  VolumeRelativeDirectory copyWith({
    String? volumePath,
    String? relativeDir,
  }) {
    return VolumeRelativeDirectory(
      volumePath: volumePath ?? this.volumePath,
      relativeDir: relativeDir ?? this.relativeDir,
    );
  }
}
