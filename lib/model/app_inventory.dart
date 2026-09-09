import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

final AppInventory appInventory = AppInventory._private();

class AppInventory {
  Set<Package> _packages = {};
  Set<Package> _launcherPackages = {};
  Set<String> _potentialAppDirs = {};

  final Map<String, bool> _isPotentialAppDirCache = {};
  final Map<String, String?> _albumAppPackageNameCache = {};
  final Map<String, String?> _currentAppNameCache = {};

  final ValueNotifier<bool> areAppNamesReadyNotifier = ValueNotifier(false);

  new _private();

  Future<void> initAppNames() async {
    if (_packages.isEmpty) {
      debugPrint('Access installed app inventory');

      _packages = await appService.getPackages();
      _launcherPackages = _packages.where((v) => v.categoryLauncher).toSet();
      _potentialAppDirs = _launcherPackages.expand((v) => v.potentialDirs).toSet();

      _invalidateCaches();
      areAppNamesReadyNotifier.value = true;
    }
  }

  Future<void> resetAppNames() async {
    debugPrint('Reset installed app inventory');

    _packages.clear();
    _launcherPackages.clear();
    _potentialAppDirs.clear();

    _invalidateCaches();
    areAppNamesReadyNotifier.value = false;
  }

  void _invalidateCaches() {
    _isPotentialAppDirCache.clear();
    _albumAppPackageNameCache.clear();
    _currentAppNameCache.clear();
  }

  bool _testAppDirPath(String normalizedDirPath, Iterable<String> potentialDirs) => potentialDirs.any(normalizedDirPath.endsWith);

  bool isPotentialAppDir(String dirPath) {
    return _isPotentialAppDirCache.putIfAbsent(dirPath, () {
      final normalizedPath = Package.normalizePotentialDir(dirPath);
      return _testAppDirPath(normalizedPath, _potentialAppDirs);
    });
  }

  String? getAlbumAppPackageName(String dirPath) {
    return _albumAppPackageNameCache.putIfAbsent(dirPath, () {
      final normalizedPath = Package.normalizePotentialDir(dirPath);
      final package = _launcherPackages.firstWhereOrNull((v) => _testAppDirPath(normalizedPath, v.potentialDirs));
      return package?.packageName;
    });
  }

  String? getCurrentAppName(String packageName) {
    return _currentAppNameCache.putIfAbsent(packageName, () {
      final package = _packages.firstWhereOrNull((v) => v.packageName == packageName);
      return package?.currentLabel;
    });
  }
}

class Package({
  required final String packageName,
  required final String? currentLabel,
  required final String? englishLabel,
  required final bool categoryLauncher,
  required final bool isSystem,
}) {
  final Set<String> _ownedDirs = {};
  final Set<String> _potentialDirs = {};

  factory fromMap(Map map) {
    return Package(
      packageName: map['packageName'] ?? '',
      currentLabel: map['currentLabel'],
      englishLabel: map['englishLabel'],
      categoryLauncher: map['categoryLauncher'] ?? false,
      isSystem: map['isSystem'] ?? false,
    );
  }

  void addOwnedDirs(Set<String> dirs) {
    _ownedDirs.addAll(dirs);
    _potentialDirs.clear();
  }

  Set<String> get potentialDirs {
    if (_potentialDirs.isEmpty) {
      final separator = pContext.separator;
      _potentialDirs.addAll(
        [
          currentLabel,
          englishLabel,
          ..._ownedDirs,
        ].nonNulls.map(normalizePotentialDir).map((v) => '$separator$v'),
      );
    }
    return _potentialDirs;
  }

  static String normalizePotentialDir(String dir) {
    return dir.replaceAll('_', ' ').trim().toLowerCase();
  }

  @override
  String toString() =>
      '$runtimeType#${shortHash(this)}{'
      'packageName=$packageName, categoryLauncher=$categoryLauncher, isSystem=$isSystem, '
      'currentLabel=$currentLabel, englishLabel=$englishLabel, ownedDirs=$_ownedDirs}';
}
