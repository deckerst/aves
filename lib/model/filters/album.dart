import 'package:aves/model/covers.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/identity/aves_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AlbumFilter extends CoveredCollectionFilter {
  static const type = 'album';

  final String album;
  final String? displayName;
  late final EntryFilter _test;

  @override
  List<Object?> get props => [album, reversed];

  AlbumFilter(this.album, this.displayName, {super.reversed = false}) {
    _test = (entry) => entry.directory == album;
  }

  factory AlbumFilter.fromMap(Map<String, dynamic> json) {
    return AlbumFilter(
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
  Widget? iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) {
    return IconUtils.getAlbumIcon(
          context: context,
          albumPath: album,
          size: size,
        ) ??
        (showGenericIcon ? Icon(AIcons.album, size: size) : null);
  }

  @override
  Future<Color> color(BuildContext context) {
    // custom color has precedence over others, even custom app color
    final customColor = covers.of(this)?.item3;
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
        break;
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

  // key `album-{path}` is expected by test driver
  @override
  String get key => '$type-$reversed-$album';
}
