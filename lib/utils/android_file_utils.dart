import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final AndroidFileUtils androidFileUtils = AndroidFileUtils._private();

class AndroidFileUtils {
  static const String trashDirPath = '#trash';

  late final String separator, vaultRoot, primaryStorage;
  late final String dcimPath, downloadPath, moviesPath, picturesPath, avesVideoCapturesPath;
  late final Set<String> videoCapturesPaths;
  Set<StorageVolume> storageVolumes = {};
  Set<Package> _packages = {};
  List<String> _potentialAppDirs = [];
  bool _initialized = false;

  ValueNotifier<bool> areAppNamesReadyNotifier = ValueNotifier(false);

  Iterable<Package> get _launcherPackages => _packages.where((package) => package.categoryLauncher);

  AndroidFileUtils._private();

  Future<void> init() async {
    if (_initialized) return;

    separator = pContext.separator;
    await _initStorageVolumes();
    vaultRoot = await storageService.getVaultRoot();
    primaryStorage = storageVolumes.firstWhereOrNull((volume) => volume.isPrimary)?.path ?? separator;
    // standard
    dcimPath = pContext.join(primaryStorage, 'DCIM');
    downloadPath = pContext.join(primaryStorage, 'Download');
    moviesPath = pContext.join(primaryStorage, 'Movies');
    picturesPath = pContext.join(primaryStorage, 'Pictures');
    avesVideoCapturesPath = pContext.join(dcimPath, 'Video Captures');
    videoCapturesPaths = {
      // from Samsung
      pContext.join(dcimPath, 'Videocaptures'),
      // from Aves
      avesVideoCapturesPath,
    };

    _initialized = true;
  }

  Future<void> _initStorageVolumes() async {
    storageVolumes = await storageService.getStorageVolumes();
    if (storageVolumes.isEmpty) {
      // this can happen when the device is booting up
      debugPrint('Storage volume list is empty. Retrying in a second...');
      await Future.delayed(const Duration(seconds: 1));
      await _initStorageVolumes();
    }
  }

  Future<void> initAppNames() async {
    if (_packages.isEmpty) {
      debugPrint('Access installed app inventory');
      _packages = await androidAppService.getPackages();
      _potentialAppDirs = _launcherPackages.expand((package) => package.potentialDirs).toList();
      areAppNamesReadyNotifier.value = true;
    }
  }

  Future<void> resetAppNames() async {
    _packages.clear();
    _potentialAppDirs.clear();
    areAppNamesReadyNotifier.value = false;
  }

  bool isCameraPath(String path) => path.startsWith(dcimPath) && (path.endsWith('${separator}Camera') || path.endsWith('${separator}100ANDRO'));

  bool isScreenshotsPath(String path) => (path.startsWith(dcimPath) || path.startsWith(picturesPath)) && path.endsWith('${separator}Screenshots');

  bool isScreenRecordingsPath(String path) => (path.startsWith(dcimPath) || path.startsWith(moviesPath)) && (path.endsWith('${separator}Screen recordings') || path.endsWith('${separator}ScreenRecords'));

  bool isVideoCapturesPath(String path) => videoCapturesPaths.contains(path);

  bool isDownloadPath(String path) => path == downloadPath;

  StorageVolume? getStorageVolume(String? path) {
    if (path == null) return null;
    final volume = storageVolumes.firstWhereOrNull((v) => path.startsWith(v.path));
    // storage volume path includes trailing '/', but argument path may or may not,
    // which is an issue when the path is at the root
    return volume != null || path.endsWith(separator) ? volume : getStorageVolume('$path$separator');
  }

  bool isOnRemovableStorage(String path) => getStorageVolume(path)?.isRemovable ?? false;

  AlbumType getAlbumType(String dirPath) {
    if (vaults.isVault(dirPath)) return AlbumType.vault;

    if (isCameraPath(dirPath)) return AlbumType.camera;
    if (isDownloadPath(dirPath)) return AlbumType.download;
    if (isScreenRecordingsPath(dirPath)) return AlbumType.screenRecordings;
    if (isScreenshotsPath(dirPath)) return AlbumType.screenshots;
    if (isVideoCapturesPath(dirPath)) return AlbumType.videoCaptures;

    final dir = pContext.split(dirPath).last;
    if (dirPath.startsWith(primaryStorage) && _potentialAppDirs.contains(dir)) return AlbumType.app;

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

enum AlbumType {
  regular,
  vault,
  app,
  camera,
  download,
  screenRecordings,
  screenshots,
  videoCaptures,
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

@immutable
class VolumeRelativeDirectory extends Equatable {
  final String volumePath, relativeDir;

  @override
  List<Object?> get props => [volumePath, relativeDir];

  String get dirPath => '$volumePath$relativeDir';

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

  Map<String, dynamic> toMap() => {
        'volumePath': volumePath,
        'relativeDir': relativeDir,
      };

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
}
