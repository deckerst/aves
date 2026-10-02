import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/common/basic/list_tiles/common.dart';
import 'package:aves/widgets/common/identity/aves_list_subtitle.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/multi_selection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const SettingsMultiSelectionListTile<T>({
  super.key,
  required final List<T> values,
  required final String Function(BuildContext, T) getName,
  required final List<T> Function(BuildContext, Settings) selector,
  required final ValueChanged<List<T>> onSelection,
  required final TitleBuilder tileTitle,
  required final String noneSubtitle,
  final String? dialogTitle,
  final TextBuilder<T>? optionSubtitleBuilder,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<Settings, List<T>>(
      selector: selector,
      builder: (context, current, child) {
        return ListTile(
          title: Text(tileTitle(context) ?? '?'),
          subtitle: AvesListSubtitle(current.isEmpty ? noneSubtitle : current.map((v) => getName(context, v)).join(AText.separator)),
          onTap: () => showSelectionDialog<List<T>>(
            context: context,
            builder: (context) => AvesMultiSelectionDialog<T>(
              initialValue: current.toSet(),
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
