import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

final AppInventory appInventory = AppInventory._private();

class AppInventory {
  Set<Package> _packages = {};
  List<String> _potentialAppDirs = [];

  ValueNotifier<bool> areAppNamesReadyNotifier = ValueNotifier(false);

  Iterable<Package> get _launcherPackages => _packages.where((v) => v.categoryLauncher);

  AppInventory._private();

  Future<void> initAppNames() async {
    if (_packages.isEmpty) {
      debugPrint('Access installed app inventory');
      _packages = await appService.getPackages();
      _potentialAppDirs = _launcherPackages.expand((v) => v.potentialDirs).toList();
      areAppNamesReadyNotifier.value = true;
    }
  }

  Future<void> resetAppNames() async {
    _packages.clear();
    _potentialAppDirs.clear();
    areAppNamesReadyNotifier.value = false;
  }

  bool isPotentialAppDir(String dir) => _potentialAppDirs.contains(dir);

  String? getAlbumAppPackageName(String albumPath) {
    final dir = pContext.split(albumPath).last;
    final package = _launcherPackages.firstWhereOrNull((v) => v.potentialDirs.contains(dir));
    return package?.packageName;
  }

  String? getCurrentAppName(String packageName) {
    final package = _packages.firstWhereOrNull((v) => v.packageName == packageName);
    return package?.currentLabel;
  }
}

class Package {
  final String packageName;
  final String? currentLabel, englishLabel;
  final bool categoryLauncher, isSystem;
  final Set<String> ownedDirs = {};

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

  Set<String> get potentialDirs => [
        currentLabel,
        englishLabel,
        ...ownedDirs,
      ].whereNotNull().toSet();

  @override
  String toString() => '$runtimeType#${shortHash(this)}{packageName=$packageName, categoryLauncher=$categoryLauncher, isSystem=$isSystem, currentLabel=$currentLabel, englishLabel=$englishLabel, ownedDirs=$ownedDirs}';
}
