import 'dart:async';
import 'dart:io';

import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';

final entryDirRepo = EntryDirRepo._private();

class EntryDirRepo._private() {
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
class EntryDir(final String? asIs) {
  final String? asIsLower = asIs?.toLowerCase();
  bool ambiguous = false;

  // assume directories leading to ambiguity do not change during app lifetime
  // so we can cache directory children and avoid repeated synchronous listings
  static final _childrenDirPathsByParent = <String, Set<String>>{};

  String? _resolved;

  String? get resolved {
    if (!ambiguous) return asIs;
    if (asIs == null) return null;

    _resolved ??= _resolve();
    return _resolved;
  }

  String? _resolve() {
    final vrl = androidFileUtils.relativeDirectoryFromPath(asIs!);
    if (vrl == null || vrl.relativeDir.isEmpty) return asIs;

    var resolved = vrl.volumePath;
    final parts = pContext.split(vrl.relativeDir);
    for (final part in parts) {
      String? found;
      final childrenDirPaths = _childrenDirPathsByParent.putIfAbsent(resolved, () => _listDirChildren(resolved));
      if (childrenDirPaths.isNotEmpty) {
        final partLower = part.toLowerCase();
        found = childrenDirPaths.firstWhereOrNull((v) => pContext.basename(v).toLowerCase() == partLower);
      }
      resolved = found ?? '$resolved${pContext.separator}$part';
    }
    return resolved;
  }

  Set<String> _listDirChildren(String dirPath) {
    final dir = Directory(dirPath);
    if (dir.existsSync()) {
      try {
        return dir.listSync().where((v) => v.absolute is Directory).map((v) => v.path).toSet();
      } catch (error) {
        // ignore, could be IO issue when listing directory
      }
    }
    return {};
  }
}
