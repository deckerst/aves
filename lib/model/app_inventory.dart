import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

final AppInventory appInventory = AppInventory._private();

class AppInventory {
  Set<Package> _packages = {};
  Set<Package> _launcherPackages = {};
  List<String> _potentialAppDirs = [];

  final Map<String, bool> _isPotentialAppDirCache = {};
  final Map<String, String?> _albumAppPackageNameCache = {};
  final Map<String, String?> _currentAppNameCache = {};

  final ValueNotifier<bool> areAppNamesReadyNotifier = ValueNotifier(false);

  AppInventory._private();

  Future<void> initAppNames() async {
    if (_packages.isEmpty) {
      debugPrint('Access installed app inventory');

      _packages = await appService.getPackages();
      _launcherPackages = _packages.where((v) => v.categoryLauncher).toSet();
      _potentialAppDirs = _launcherPackages.expand((v) => v.potentialDirs).toList();

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

  bool isPotentialAppDir(String dir) {
    return _isPotentialAppDirCache.putIfAbsent(dir, () {
      return _potentialAppDirs.contains(Package.normalizePotentialDir(dir));
    });
  }

  String? getAlbumAppPackageName(String albumPath) {
    return _albumAppPackageNameCache.putIfAbsent(albumPath, () {
      final dir = Package.normalizePotentialDir(pContext.split(albumPath).last);
      final package = _launcherPackages.firstWhereOrNull((v) => v.potentialDirs.contains(dir));
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

class Package {
  final String packageName;
  final String? currentLabel, englishLabel;
  final bool categoryLauncher, isSystem;

  final Set<String> _ownedDirs = {};
  final Set<String> _potentialDirs = {};

  Package({
    required this.packageName,
    required this.currentLabel,
    required this.englishLabel,
    required this.categoryLauncher,
    required this.isSystem,
  });

  factory Package.fromMap(Map map) {
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
      _potentialDirs.addAll(
        [
          currentLabel,
          englishLabel,
          ..._ownedDirs,
        ].nonNulls.map(normalizePotentialDir),
      );
    }
    return _potentialDirs;
  }

  static String normalizePotentialDir(String dir) {
    return dir.replaceAll('_', ' ').trim().toLowerCase();
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{packageName=$packageName, categoryLauncher=$categoryLauncher, isSystem=$isSystem, currentLabel=$currentLabel, englishLabel=$englishLabel, ownedDirs=$_ownedDirs}';
}
