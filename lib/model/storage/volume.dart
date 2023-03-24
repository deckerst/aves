import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class StorageVolume extends Equatable {
  final String? _description;
  final String path, state;
  final bool isPrimary, isRemovable;

  @override
  List<Object?> get props => [_description, path, state, isPrimary, isRemovable];

  const StorageVolume({
    required String? description,
    required this.isPrimary,
    required this.isRemovable,
    required this.path,
    required this.state,
  }) : _description = description;

  String getDescription(BuildContext? context) {
    if (_description != null) return _description!;
    // ideally, the context should always be provided, but in some cases (e.g. album comparison),
    // this would require numerous additional methods to have the context as argument
    // for such a minor benefit: fallback volume description on Android < N
    if (isPrimary) return context?.l10n.storageVolumeDescriptionFallbackPrimary ?? 'Internal Storage';
    return context?.l10n.storageVolumeDescriptionFallbackNonPrimary ?? 'SD card';
  }

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
