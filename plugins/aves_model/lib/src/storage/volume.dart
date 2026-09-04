import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class StorageVolume extends Equatable {
  final String? mediaStoreVolumeName, description;
  final String path, state;
  final bool isPrimary, isRemovable;

  @override
  List<Object?> get props => [mediaStoreVolumeName, description, path, state, isPrimary, isRemovable];

  const new({
    required this.mediaStoreVolumeName,
    required this.description,
    required this.isPrimary,
    required this.isRemovable,
    required this.path,
    required this.state,
  });

  factory fromMap(Map map) {
    return StorageVolume(
      mediaStoreVolumeName: map['mediaStoreVolumeName'],
      description: map['description'],
      isPrimary: map['isPrimary'] ?? false,
      isRemovable: map['isRemovable'] ?? false,
      path: map['path'] ?? '',
      state: map['state'] ?? '',
    );
  }
}
