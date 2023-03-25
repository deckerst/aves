import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum WallpaperTarget { home, lock, homeLock }

extension ExtraWallpaperTarget on WallpaperTarget {
  String getName(BuildContext context) {
    switch (this) {
      case WallpaperTarget.home:
        return context.l10n.wallpaperTargetHome;
      case WallpaperTarget.lock:
        return context.l10n.wallpaperTargetLock;
      case WallpaperTarget.homeLock:
        return context.l10n.wallpaperTargetHomeLock;
    }
  }
}
