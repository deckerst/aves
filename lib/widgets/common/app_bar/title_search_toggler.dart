import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class TitleSearchToggler extends StatelessWidget {
  final bool queryEnabled, isMenuItem;
  final VoidCallback? onPressed;

  const TitleSearchToggler({
    super.key,
    required this.queryEnabled,
    this.isMenuItem = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(queryEnabled ? AIcons.filterOff : AIcons.filter);
    final text = queryEnabled ? context.l10n.collectionActionHideTitleSearch : context.l10n.collectionActionShowTitleSearch;
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
