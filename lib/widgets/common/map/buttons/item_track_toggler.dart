import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapItemTrackToggler extends StatelessWidget {
  final bool isMenuItem;
  final VoidCallback? onPressed;

  const MapItemTrackToggler({
    super.key,
    this.isMenuItem = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = context.select<Settings, bool>((v) => v.mapShowItemTracks);
    final icon = Icon(enabled ? AIcons.routeOff : AIcons.route);
    final text = enabled ? context.l10n.mapHideItemTracks : context.l10n.mapShowItemTracks;
    return isMenuItem
        ? MenuRow(
            text: text,
            icon: icon,
          )
        : IconButton(
            icon: icon,
            onPressed: onPressed,
            tooltip: text,
          );
  }
}
