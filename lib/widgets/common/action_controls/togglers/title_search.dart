import 'package:aves/model/query.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const TitleSearchToggler({
  super.key,
  required final bool queryEnabled,
  final bool isMenuItem = false,
  final FocusNode? focusNode,
  final VoidCallback? onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final icon = Icon(queryEnabled ? AIcons.hideTitleFilter : AIcons.showTitleFilter);
    final text = queryEnabled ? context.l10n.collectionActionHideTitleSearch : context.l10n.collectionActionShowTitleSearch;
    return isMenuItem
        ? MenuRow(
            text: text,
            icon: icon,
          )
        : IconButton(
            icon: icon,
            onPressed: onPressed,
            focusNode: focusNode,
            tooltip: text,
          );
  }
}

class const TitleSearchTogglerCaption({
  super.key,
  required final bool enabled,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // `Query` may not be available during hero
    return Selector<Query?, bool>(
      selector: (context, query) => query?.enabled ?? false,
      builder: (context, queryEnabled, child) {
        return CaptionedButtonText(
          text: queryEnabled ? context.l10n.collectionActionHideTitleSearch : context.l10n.collectionActionShowTitleSearch,
          enabled: enabled,
        );
      },
    );
  }
}
