import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const LayoutBarToggler({
  super.key,
  final bool isMenuItem = false,
  final FocusNode? focusNode,
  final VoidCallback? onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final enabled = context.select<Settings, bool>((v) => v.showCollectionLayoutBar);
    final icon = Icon(enabled ? AIcons.hideLayoutBar : AIcons.showLayoutBar);
    final text = enabled ? context.l10n.collectionActionHideLayoutBar : context.l10n.collectionActionShowLayoutBar;
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

class const LayoutBarTogglerCaption({
  super.key,
  required final bool enabled,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final enabled = context.select<Settings, bool>((v) => v.showCollectionLayoutBar);
    return CaptionedButtonText(
      text: enabled ? context.l10n.collectionActionHideLayoutBar : context.l10n.collectionActionShowLayoutBar,
      enabled: enabled,
    );
  }
}
