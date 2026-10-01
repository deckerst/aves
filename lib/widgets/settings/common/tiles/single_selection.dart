import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/list_tiles/common.dart';
import 'package:aves/widgets/common/identity/aves_list_subtitle.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/single_selection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const SettingsSelectionListTile<T>({
  super.key,
  required final List<T> values,
  required final String Function(BuildContext, T) getName,
  required final T Function(BuildContext, Settings) selector,
  required final ValueChanged<T> onSelection,
  required final TitleBuilder tileTitle,
  final WidgetBuilder? trailingBuilder,
  final String? dialogTitle,
  final TextBuilder<T>? optionSubtitleBuilder,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<Settings, T>(
      selector: selector,
      builder: (context, current, child) {
        return ListTile(
          title: Text(tileTitle(context) ?? '?'),
          subtitle: AvesListSubtitle(getName(context, current)),
          trailing: trailingBuilder?.call(context),
          onTap: () => showSelectionDialog<T>(
            context: context,
            builder: (context) => AvesSingleSelectionDialog<T>(
              initialValue: current,
              options: Map.fromEntries(values.map((v) => MapEntry(v, getName(context, v)))),
              optionSubtitleBuilder: optionSubtitleBuilder,
              title: dialogTitle,
            ),
            onSelection: onSelection,
          ),
        );
      },
    );
  }
}
