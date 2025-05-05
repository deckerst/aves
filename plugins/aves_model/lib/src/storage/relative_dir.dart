import 'package:aves_model/aves_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

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

  factory VolumeRelativeDirectory.volume(StorageVolume volume) {
    return VolumeRelativeDirectory(volumePath: volume.path, relativeDir: '');
  }

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
