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
}
