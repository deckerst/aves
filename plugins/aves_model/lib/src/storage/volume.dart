import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class const StorageVolume({
  required final String? mediaStoreVolumeName,
  required final String? description,
  required final bool isPrimary,
  required final bool isRemovable,
  required final String path,
  required final String state,
}) extends Equatable {
  @override
  List<Object?> get props => [mediaStoreVolumeName, description, path, state, isPrimary, isRemovable];

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
