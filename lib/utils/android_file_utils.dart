import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/android_file_service.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

final AndroidFileUtils androidFileUtils = AndroidFileUtils._private();

class AndroidFileUtils {
  String primaryStorage, dcimPath, downloadPath, moviesPath, picturesPath;
  Set<StorageVolume> storageVolumes = {};
  Set<Package> _packages = {};
  List<String> _potentialAppDirs = [];

  AChangeNotifier appNameChangeNotifier = AChangeNotifier();

  Iterable<Package> get _launcherPackages => _packages.where((package) => package.categoryLauncher);

  AndroidFileUtils._private();

  Future<void> init() async {
    storageVolumes = await AndroidFileService.getStorageVolumes();
    // path_provider getExternalStorageDirectory() gives '/storage/emulated/0/Android/data/deckers.thibault.aves/files'
    primaryStorage = storageVolumes.firstWhere((volume) => volume.isPrimary).path;
    dcimPath = join(primaryStorage, 'DCIM');
    downloadPath = join(primaryStorage, 'Download');
    moviesPath = join(primaryStorage, 'Movies');
    picturesPath = join(primaryStorage, 'Pictures');
  }

  Future<void> initAppNames() async {
    _packages = await AndroidAppService.getPackages();
    _potentialAppDirs = _launcherPackages.expand((package) => package.potentialDirs).toList();
    appNameChangeNotifier.notifyListeners();
  }

  bool isCameraPath(String path) => path != null && path.startsWith(dcimPath) && (path.endsWith('Camera') || path.endsWith('100ANDRO'));

  bool isScreenshotsPath(String path) => path != null && (path.startsWith(dcimPath) || path.startsWith(picturesPath)) && path.endsWith('Screenshots');

  bool isScreenRecordingsPath(String path) => path != null && (path.startsWith(dcimPath) || path.startsWith(moviesPath)) && (path.endsWith('Screen recordings') || path.endsWith('ScreenRecords'));

  bool isDownloadPath(String path) => path == downloadPath;

  StorageVolume getStorageVolume(String path) {
    final volume = storageVolumes.firstWhere((v) => path.startsWith(v.path), orElse: () => null);
    // storage volume path includes trailing '/', but argument path may or may not,
    // which is an issue when the path is at the root
    return volume != null || path.endsWith('/') ? volume : getStorageVolume('$path/');
  }

  bool isOnRemovableStorage(String path) => getStorageVolume(path)?.isRemovable ?? false;

  AlbumType getAlbumType(String albumPath) {
    if (albumPath != null) {
      if (isCameraPath(albumPath)) return AlbumType.camera;
      if (isDownloadPath(albumPath)) return AlbumType.download;
      if (isScreenRecordingsPath(albumPath)) return AlbumType.screenRecordings;
      if (isScreenshotsPath(albumPath)) return AlbumType.screenshots;

      final dir = albumPath.split(separator).last;
      if (albumPath.startsWith(primaryStorage) && _potentialAppDirs.contains(dir)) return AlbumType.app;
    }
    return AlbumType.regular;
  }

  String getAlbumAppPackageName(String albumPath) {
    if (albumPath == null) return null;
    final dir = albumPath.split(separator).last;
    final package = _launcherPackages.firstWhere((package) => package.potentialDirs.contains(dir), orElse: () => null);
    return package?.packageName;
  }

  String getCurrentAppName(String packageName) {
    final package = _packages.firstWhere((package) => package.packageName == packageName, orElse: () => null);
    return package?.currentLabel;
  }
}

enum AlbumType { regular, app, camera, download, screenRecordings, screenshots }

class Package {
  final String packageName, currentLabel, englishLabel;
  final bool categoryLauncher, isSystem;
  final Set<String> ownedDirs = {};

  Package({
    this.packageName,
    this.currentLabel,
    this.englishLabel,
    this.categoryLauncher,
    this.isSystem,
  });

  factory Package.fromMap(Map map) {
    return Package(
      packageName: map['packageName'],
      currentLabel: map['currentLabel'],
      englishLabel: map['englishLabel'],
      categoryLauncher: map['categoryLauncher'],
      isSystem: map['isSystem'],
    );
  }

  Set<String> get potentialDirs => [
        currentLabel,
        englishLabel,
        ...ownedDirs,
      ].where((dir) => dir != null).toSet();

  @override
  String toString() => '$runtimeType#${shortHash(this)}{packageName=$packageName, categoryLauncher=$categoryLauncher, isSystem=$isSystem, currentLabel=$currentLabel, englishLabel=$englishLabel, ownedDirs=$ownedDirs}';
}

@immutable
class StorageVolume {
  final String _description, path, state;
  final bool isPrimary, isRemovable;

  const StorageVolume({
    String description,
    this.isPrimary,
    this.isRemovable,
    this.path,
    this.state,
  }) : _description = description;

  String getDescription(BuildContext context) {
    if (_description != null) return _description;
    // ideally, the context should always be provided, but in some cases (e.g. album comparison),
    // this would require numerous additional methods to have the context as argument
    // for such a minor benefit: fallback volume description on Android < N
    if (isPrimary) return context?.l10n?.storageVolumeDescriptionFallbackPrimary ?? 'Internal Storage';
    return context?.l10n?.storageVolumeDescriptionFallbackNonPrimary ?? 'SD card';
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
    this.volumePath,
    this.relativeDir,
  });

  factory VolumeRelativeDirectory.fromMap(Map map) {
    return VolumeRelativeDirectory(
      volumePath: map['volumePath'],
      relativeDir: map['relativeDir'] ?? '',
    );
  }

  // prefer static method over a null returning factory constructor
  static VolumeRelativeDirectory fromPath(String dirPath) {
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
    final volume = androidFileUtils.storageVolumes.firstWhere((volume) => volume.path == volumePath, orElse: () => null);
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
