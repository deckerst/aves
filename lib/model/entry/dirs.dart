import 'dart:async';

final entryDirRepo = EntryDirRepo._private();

class EntryDirRepo {
  new _private();

  // mapping between the raw entry directory path to a resolvable directory
  final Map<String?, EntryDir> _dirs = {};
  final Map<String, EntryDir> _dirsByLower = {};
  final StreamController<EntryDir> _ambiguousDirStreamController = StreamController.broadcast();

  Stream<EntryDir> get ambiguousDirStream => _ambiguousDirStreamController.stream;

  // get a resolvable directory for a raw entry directory path
  EntryDir getOrCreate(String? asIs) {
    if (asIs == null) return EntryDir(null);
    var entryDir = _dirs[asIs];
    if (entryDir != null) return entryDir;

    final asIsLower = asIs.toLowerCase();
    entryDir = _dirsByLower[asIsLower];
    if (entryDir != null) {
      if (!entryDir.ambiguous) {
        entryDir.ambiguous = true;
        _ambiguousDirStreamController.add(entryDir);
      }
      _dirs[asIs] = entryDir;
      return entryDir;
    }

    final newDir = EntryDir(asIs);
    _dirs[asIs] = newDir;
    _dirsByLower[asIsLower] = newDir;
    return newDir;
  }
}


// Some directories are ambiguous because they use different cases,
// but the OS merge and present them as one directory.
// This class resolves ambiguous directories to get the directory path
// with the right case, as presented by the OS.
class EntryDir {
  final String? asIs, asIsLower;
  bool ambiguous = false;

  new(this.asIs) : asIsLower = asIs?.toLowerCase();

  String? get resolved => asIs;
}
