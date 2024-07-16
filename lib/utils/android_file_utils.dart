import 'package:aves/model/apps.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

final AndroidFileUtils androidFileUtils = AndroidFileUtils._private();

class AndroidFileUtils {
  // cf https://developer.android.com/reference/android/content/ContentResolver#SCHEME_CONTENT
  static const contentScheme = 'content';

  // cf https://developer.android.com/reference/android/provider/MediaStore#AUTHORITY
  static const mediaStoreAuthority = 'media';

  // cf https://developer.android.com/reference/android/provider/MediaStore#VOLUME_EXTERNAL
  static const externalVolume = 'external';

  static const mediaStoreUriRoot = '$contentScheme://$mediaStoreAuthority/';
  static const mediaUriPathRoots = {'/$externalVolume/images/', '/$externalVolume/video/'};

  static const recoveryDir = 'Lost & Found';
  static const trashDirPath = '#trash';

  late final String separator, vaultRoot, primaryStorage;
  late final String dcimPath, downloadPath, moviesPath, picturesPath, avesVideoCapturesPath;
  late final Set<String> videoCapturesPaths;
  Set<StorageVolume> storageVolumes = {};
  bool _initialized = false;

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

  // prefer static method over a null returning factory constructor
  VolumeRelativeDirectory? relativeDirectoryFromPath(String dirPath) {
    final volume = getStorageVolume(dirPath);
    if (volume == null) return null;

    final root = volume.path;
    final rootLength = root.length;
    return VolumeRelativeDirectory(
      volumePath: root,
      relativeDir: dirPath.length < rootLength ? '' : dirPath.substring(rootLength),
    );
  }

  bool isOnRemovableStorage(String path) => getStorageVolume(path)?.isRemovable ?? false;

  AlbumType getAlbumType(String dirPath) {
    if (vaults.isVault(dirPath)) return AlbumType.vault;

    if (isCameraPath(dirPath)) return AlbumType.camera;
    if (isDownloadPath(dirPath)) return AlbumType.download;
    if (isScreenRecordingsPath(dirPath)) return AlbumType.screenRecordings;
    if (isScreenshotsPath(dirPath)) return AlbumType.screenshots;
    if (isVideoCapturesPath(dirPath)) return AlbumType.videoCaptures;

    final dir = pContext.split(dirPath).lastOrNull;
    if (dir != null && dirPath.startsWith(primaryStorage) && appInventory.isPotentialAppDir(dir)) return AlbumType.app;

    return AlbumType.regular;
  }
}
