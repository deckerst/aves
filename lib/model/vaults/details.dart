import 'package:aves/model/vaults/enums.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class VaultDetails extends Equatable {
  final String name;
  final bool autoLockScreenOff, useBin;
  final VaultLockType lockType;

  @override
  List<Object?> get props => [name, autoLockScreenOff, useBin, lockType];

  const VaultDetails({
    required this.name,
    required this.autoLockScreenOff,
    required this.useBin,
    required this.lockType,
  });

  VaultDetails copyWith({
    String? name,
  }) {
    return VaultDetails(
      name: name ?? this.name,
      autoLockScreenOff: autoLockScreenOff,
      useBin: useBin,
      lockType: lockType,
    );
  }

  factory VaultDetails.fromMap(Map map) {
    return VaultDetails(
      name: map['name'] as String,
      autoLockScreenOff: (map['autoLock'] as int? ?? 0) != 0,
      useBin: (map['useBin'] as int? ?? 0) != 0,
      lockType: VaultLockType.values.safeByName(map['lockType'] as String, VaultLockType.system),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'autoLock': autoLockScreenOff ? 1 : 0,
        'useBin': useBin ? 1 : 0,
        'lockType': lockType.name,
      };

  String get passKey => 'vault_pass_$name';

  String get path => '${androidFileUtils.vaultRoot}$name';

  static String? nameFromPath(String path) {
    return path.startsWith(androidFileUtils.vaultRoot) ? path.substring(androidFileUtils.vaultRoot.length) : null;
  }
}
