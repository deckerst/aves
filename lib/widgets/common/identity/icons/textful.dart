import 'package:aves/locale/number.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/mime_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/identity/icons/overlay.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const CalendarStackCount({
  super.key,
  required final AvesEntry entry,
}) extends StatelessWidget {
  static const double fontScale = 2;

  @override
  Widget build(BuildContext context) {
    final numberFormat = context.select<GridThemeData, ANumberFormat>((t) => t.numberFormatter);
    final child = OverlayIcon(
      text: numberFormat.format(entry.stackedEntries?.length ?? 0),
    );

    final fontSize = context.select<GridThemeData, double>((t) => t.fontSize * fontScale);
    return DefaultTextStyle(
      style: TextStyle(fontSize: fontSize),
      child: child,
    );
  }
}

class const MimeIcon({
  super.key,
  required final String mimeType,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final child = OverlayIcon(
      text: MimeUtils.displayType(mimeType.toLowerCase()),
    );

    final fontSize = context.select<GridThemeData, double>((t) => t.fontSize);
    return DefaultTextStyle(
      style: TextStyle(fontSize: fontSize),
      child: child,
    );
  }
}

class const RatingIcon({
  super.key,
  required final int rating,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final numberFormat = context.select<GridThemeData, ANumberFormat>((t) => t.numberFormatter);
    final child = OverlayIcon(
      icon: AIcons.rating,
      text: numberFormat.format(rating),
    );

    final fontSize = context.select<GridThemeData, double>((t) => t.fontSize);
    return DefaultTextStyle(
      style: TextStyle(fontSize: fontSize),
      child: child,
    );
  }
}

class const StackIcon({
  super.key,
  required final AvesEntry entry,
}) extends StatelessWidget {
  static const double scale = .8;

  @override
  Widget build(BuildContext context) {
    final numberFormat = context.select<GridThemeData, ANumberFormat>((t) => t.numberFormatter);
    final child = OverlayIcon(
      icon: AIcons.multiPage,
      iconScale: scale,
      text: numberFormat.format(entry.stackedEntries?.length ?? 0),
    );

    final fontSize = context.select<GridThemeData, double>((t) => t.fontSize);
    return DefaultTextStyle(
      style: TextStyle(fontSize: fontSize),
      child: child,
    );
  }
}

class const TrashIcon({
  super.key,
  required final int? trashDaysLeft,
}) extends StatelessWidget {
  static const double scale = .85;

  @override
  Widget build(BuildContext context) {
    final child = OverlayIcon(
      icon: AIcons.bin,
      iconScale: scale,
      text: trashDaysLeft != null ? context.l10n.timeDays(trashDaysLeft!) : null,
    );

    final fontSize = context.select<GridThemeData, double>((t) => t.fontSize);
    return DefaultTextStyle(
      style: TextStyle(fontSize: fontSize),
      child: child,
    );
  }
}

class const VideoIcon({
  super.key,
  required final AvesEntry entry,
  required final bool showDuration,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!showDuration) {
      return OverlayIcon(icon: _getIcon());
    }

    Widget child = OverlayIcon(
      icon: _getIcon(),
      text: entry.durationText,
      iconScale: entry.is360 ? .9 : 1,
    );

    final fontSize = context.select<GridThemeData, double>((t) => t.fontSize);
    return DefaultTextStyle(
      style: TextStyle(fontSize: fontSize),
      child: child,
    );
  }

  IconData _getIcon() {
    if (entry.is360) return AIcons.sphericalVideo;
    if (entry.isSlowMotion) return AIcons.slowMotion;
    return AIcons.videoPlay;
  }
}
