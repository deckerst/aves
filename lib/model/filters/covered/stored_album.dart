import 'package:aves/model/covers.dart';
import 'package:aves/model/filters/covered/album_base.dart';
import 'package:aves/model/filters/covered/covered.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class StoredAlbumFilter extends AlbumBaseFilter with CoveredFilter {
  static const type = 'album';

  final String album;
  final String? displayName;
  late final EntryFilter _test;

  @override
  List<Object?> get props => [album, reversed];

  StoredAlbumFilter(this.album, this.displayName, {super.reversed = false}) {
    _test = (entry) => entry.directory == album;
  }

  factory StoredAlbumFilter.fromMap(Map<String, dynamic> json) {
    return StoredAlbumFilter(
      json['album'],
      json['uniqueName'],
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'album': album,
        'uniqueName': displayName,
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => _test;

  @override
  bool get exclusiveProp => true;

  @override
  String get universalLabel => displayName ?? pContext.split(album).last;

  @override
  String getTooltip(BuildContext context) => album;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    return IconUtils.getAlbumIcon(
          context: context,
          albumPath: album,
          size: size,
        ) ??
        (allowGenericIcon ? Icon(AIcons.album, size: size) : null);
  }

  @override
  Future<Color> color(BuildContext context) {
    // custom color has precedence over others, even custom app color
    final customColor = covers.of(this)?.$3;
    if (customColor != null) return SynchronousFuture(customColor);

    final colors = context.read<AvesColorsData>();
    // do not use async/await and rely on `SynchronousFuture`
    // to prevent rebuilding of the `FutureBuilder` listening on this future
    final albumType = covers.effectiveAlbumType(album);
    switch (albumType) {
      case AlbumType.regular:
      case AlbumType.vault:
        break;
      case AlbumType.app:
        final appColor = colors.appColor(album);
        if (appColor != null) return appColor;
      case AlbumType.camera:
        return SynchronousFuture(colors.albumCamera);
      case AlbumType.download:
        return SynchronousFuture(colors.albumDownload);
      case AlbumType.screenRecordings:
        return SynchronousFuture(colors.albumScreenRecordings);
      case AlbumType.screenshots:
        return SynchronousFuture(colors.albumScreenshots);
      case AlbumType.videoCaptures:
        return SynchronousFuture(colors.albumVideoCaptures);
    }
    return super.color(context);
  }

  @override
  String get category => type;

  // key is expected by test driver
  @override
  String get key => '$type-$reversed-$album';

  @override
  bool match(String query) => (displayName ?? album).toUpperCase().contains(query);

  @override
  StorageVolume? get storageVolume => androidFileUtils.getStorageVolume(album);

  @override
  bool get canRename {
    if (isVault) return true;

    // do not allow renaming volume root
    final dir = androidFileUtils.relativeDirectoryFromPath(album);
    return dir != null && dir.relativeDir.isNotEmpty;
  }

  @override
  bool get isVault => vaults.isVault(album);
}
