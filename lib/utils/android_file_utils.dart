import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/services.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final AndroidFileUtils androidFileUtils = AndroidFileUtils._private();

class AndroidFileUtils {
  late String primaryStorage, dcimPath, downloadPath, moviesPath, picturesPath;
  Set<StorageVolume> storageVolumes = {};
  Set<Package> _packages = {};
  List<String> _potentialAppDirs = [];

  AChangeNotifier appNameChangeNotifier = AChangeNotifier();

  Iterable<Package> get _launcherPackages => _packages.where((package) => package.categoryLauncher);

  AndroidFileUtils._private();

  Future<void> init() async {
    storageVolumes = await storageService.getStorageVolumes();
    // path_provider getExternalStorageDirectory() gives '/storage/emulated/0/Android/data/deckers.thibault.aves/files'
    primaryStorage = storageVolumes.firstWhereOrNull((volume) => volume.isPrimary)?.path ?? '/';
    dcimPath = pContext.join(primaryStorage, 'DCIM');
    downloadPath = pContext.join(primaryStorage, 'Download');
    moviesPath = pContext.join(primaryStorage, 'Movies');
    picturesPath = pContext.join(primaryStorage, 'Pictures');
  }

  Future<void> initAppNames() async {
    _packages = await AndroidAppService.getPackages();
    _potentialAppDirs = _launcherPackages.expand((package) => package.potentialDirs).toList();
    appNameChangeNotifier.notifyListeners();
  }

  bool isCameraPath(String path) => path.startsWith(dcimPath) && (path.endsWith('Camera') || path.endsWith('100ANDRO'));

  bool isScreenshotsPath(String path) => (path.startsWith(dcimPath) || path.startsWith(picturesPath)) && path.endsWith('Screenshots');

  bool isScreenRecordingsPath(String path) => (path.startsWith(dcimPath) || path.startsWith(moviesPath)) && (path.endsWith('Screen recordings') || path.endsWith('ScreenRecords'));

  bool isDownloadPath(String path) => path == downloadPath;

  StorageVolume? getStorageVolume(String? path) {
    if (path == null) return null;
    final volume = storageVolumes.firstWhereOrNull((v) => path.startsWith(v.path));
    // storage volume path includes trailing '/', but argument path may or may not,
    // which is an issue when the path is at the root
    return volume != null || path.endsWith('/') ? volume : getStorageVolume('$path/');
  }

  bool isOnRemovableStorage(String path) => getStorageVolume(path)?.isRemovable ?? false;

  AlbumType getAlbumType(String albumPath) {
    if (isCameraPath(albumPath)) return AlbumType.camera;
    if (isDownloadPath(albumPath)) return AlbumType.download;
    if (isScreenRecordingsPath(albumPath)) return AlbumType.screenRecordings;
    if (isScreenshotsPath(albumPath)) return AlbumType.screenshots;

    final dir = pContext.split(albumPath).last;
    if (albumPath.startsWith(primaryStorage) && _potentialAppDirs.contains(dir)) return AlbumType.app;

    return AlbumType.regular;
  }

  String? getAlbumAppPackageName(String albumPath) {
    final dir = pContext.split(albumPath).last;
    final package = _launcherPackages.firstWhereOrNull((package) => package.potentialDirs.contains(dir));
    return package?.packageName;
  }

  String? getCurrentAppName(String packageName) {
    final package = _packages.firstWhereOrNull((package) => package.packageName == packageName);
    return package?.currentLabel;
  }
}

enum AlbumType { regular, app, camera, download, screenRecordings, screenshots }

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
      ].where((dir) => dir != null).cast<String>().toSet();

  @override
  String toString() => '$runtimeType#${shortHash(this)}{packageName=$packageName, categoryLauncher=$categoryLauncher, isSystem=$isSystem, currentLabel=$currentLabel, englishLabel=$englishLabel, ownedDirs=$ownedDirs}';
}

@immutable
class StorageVolume {
  final String? _description;
  final String path, state;
  final bool isPrimary, isRemovable;

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

@immutable
class VolumeRelativeDirectory {
  final String volumePath, relativeDir;

  const VolumeRelativeDirectory({
    required this.volumePath,
    required this.relativeDir,
  });

  static VolumeRelativeDirectory fromMap(Map map) {
    return VolumeRelativeDirectory(
      volumePath: map['volumePath'] ?? '',
      relativeDir: map['relativeDir'] ?? '',
    );
  }

  // prefer static method over a null returning factory constructor
  static VolumeRelativeDirectory? fromPath(String dirPath) {
    final volume = androidFileUtils.getStorageVolume(dirPath);
    if (volume == null) return null;

    final root = volume.path;
    final rootLength = root.length;
    return VolumeRelativeDirectory(
      volumePath: root,
      relativeDir: dirPath.length < rootLength ? '' : dirPath.substring(rootLength),
    );
  }

  String getVolumeDescription(BuildContext context) {
    final volume = androidFileUtils.storageVolumes.firstWhereOrNull((volume) => volume.path == volumePath);
    return volume?.getDescription(context) ?? volumePath;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is VolumeRelativeDirectory && other.volumePath == volumePath && other.relativeDir == relativeDir;
  }

  @override
  int get hashCode => hashValues(volumePath, relativeDir);
}
