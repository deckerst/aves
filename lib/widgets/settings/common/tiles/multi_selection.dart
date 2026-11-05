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
  required final Set<T> Function(BuildContext, Settings) selector,
  required final ValueChanged<Set<T>> onSelection,
  required final TitleBuilder tileTitle,
  final String? noneSubtitle,
  final String? dialogTitle,
  final IconBuilder<T>? optionLeadingBuilder,
  final TextBuilder<T>? optionSubtitleBuilder,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<Settings, Set<T>>(
      selector: selector,
      builder: (context, current, child) {
        final subtitle = current.isEmpty ? noneSubtitle : current.map((v) => getName(context, v)).join(AText.separator);
        return ListTile(
          title: Text(tileTitle(context) ?? AText.valueNotAvailable),
          subtitle: subtitle != null ? AvesListSubtitle(subtitle) : null,
          onTap: () => showSelectionDialog<Set<T>>(
            context: context,
            builder: (context) => AvesMultiSelectionDialog<T>(
              initialValue: current.toSet(),
              options: Map.fromEntries(values.map((v) => MapEntry(v, getName(context, v)))),
              optionLeadingBuilder: optionLeadingBuilder,
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
