import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraWallpaperTargetView on WallpaperTarget {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      WallpaperTarget.home => l10n.wallpaperTargetHome,
      WallpaperTarget.lock => l10n.wallpaperTargetLock,
      WallpaperTarget.homeLock => l10n.wallpaperTargetHomeLock,
    };
  }
}
