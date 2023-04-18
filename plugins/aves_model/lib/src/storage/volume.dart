import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class StorageVolume extends Equatable {
  final String? description;
  final String path, state;
  final bool isPrimary, isRemovable;

  @override
  List<Object?> get props => [description, path, state, isPrimary, isRemovable];

  const StorageVolume({
    required this.description,
    required this.isPrimary,
    required this.isRemovable,
    required this.path,
    required this.state,
  });

  factory StorageVolume.fromMap(Map map) {
    final isPrimary = map['isPrimary'] ?? false;
    return StorageVolume(
      description: map['description'],
      isPrimary: isPrimary,
      isRemovable: map['isRemovable'] ?? false,
      path: map['path'] ?? '',
      state: map['state'] ?? '',
    );
  }
}
