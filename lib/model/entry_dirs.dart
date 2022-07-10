import 'dart:async';
import 'dart:io';

import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';

final entryDirRepo = EntryDirRepo._private();

class EntryDirRepo {
  EntryDirRepo._private();

  // mapping between the raw entry directory path to a resolvable directory
  final Map<String?, EntryDir> _dirs = {};
  final StreamController<EntryDir> _ambiguousDirStreamController = StreamController.broadcast();

  Stream<EntryDir> get ambiguousDirStream => _ambiguousDirStreamController.stream;

  // get a resolvable directory for a raw entry directory path
  EntryDir getOrCreate(String? asIs) {
    var entryDir = _dirs[asIs];
    if (entryDir != null) return entryDir;

    final asIsLower = asIs?.toLowerCase();
    entryDir = _dirs.values.firstWhereOrNull((dir) => dir.asIsLower == asIsLower);
    if (entryDir != null && !entryDir.ambiguous) {
      entryDir.ambiguous = true;
      _ambiguousDirStreamController.add(entryDir);
    }

    return _dirs.putIfAbsent(asIs, () => entryDir ?? EntryDir(asIs));
  }
}

// Some directories are ambiguous because they use different cases,
// but the OS merge and present them as one directory.
// This class resolves ambiguous directories to get the directory path
// with the right case, as presented by the OS.
class EntryDir {
  final String? asIs, asIsLower;
  bool ambiguous = false;
  String? _resolved;

  EntryDir(this.asIs) : asIsLower = asIs?.toLowerCase();

  String? get resolved {
    if (!ambiguous) return asIs;
    if (asIs == null) return null;

    _resolved ??= _resolve();
    return _resolved;
  }

  String? _resolve() {
    final vrl = VolumeRelativeDirectory.fromPath(asIs!);
    if (vrl == null || vrl.relativeDir.isEmpty) return asIs;

    var resolved = vrl.volumePath;
    final parts = pContext.split(vrl.relativeDir);
    for (final part in parts) {
      FileSystemEntity? found;
      final dir = Directory(resolved);
      if (dir.existsSync()) {
        final partLower = part.toLowerCase();
        final childrenDirs = dir.listSync().where((v) => v.absolute is Directory).toSet();
        found = childrenDirs.firstWhereOrNull((v) => pContext.basename(v.path).toLowerCase() == partLower);
      }
      resolved = found?.path ?? '$resolved${pContext.separator}$part';
    }
    return resolved;
  }
}
