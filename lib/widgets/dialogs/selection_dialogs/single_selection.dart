import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/radio_list_tile.dart';
import 'package:material_ui/material_ui.dart';

// do not use as `T` a record containing a collection
// because radio value comparison will fail without deep equality
class const AvesSingleSelectionDialog<T>({
  super.key,
  required final T initialValue,
  required final Map<T, String> options,
  final IconBuilder<T>? optionIconBuilder,
  final TextBuilder<T>? optionSubtitleBuilder,
  final String? title,
  final String? message,
  final String? confirmationButtonLabel,
  final bool? dense,
}) extends StatefulWidget {
  static const routeName = '/dialog/selection';

  @override
  State<AvesSingleSelectionDialog<T>> createState() => _AvesSingleSelectionDialogState<T>();
}

class _AvesSingleSelectionDialogState<T> extends State<AvesSingleSelectionDialog<T>> {
  late T _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final message = widget.message;
    final verticalPadding = (title == null && message == null) ? AvesDialog.cornerRadius.y / 2 : .0;
    final confirmationButtonLabel = widget.confirmationButtonLabel;
    final needConfirmation = confirmationButtonLabel != null;
    return AvesDialog(
      title: title,
      scrollableContent: [
        RadioGroup<T>(
          groupValue: _selectedValue,
          onChanged: (v) {
            // always update the group value even when popping afterwards,
            // so that the group value can be used in pop handlers
            // as well as the regular return value from navigation
            _selectedValue = v as T;
            if (!needConfirmation) {
              // validate without confirmation
              Navigator.maybeOf(context)?.pop<T>(v);
            } else {
              setState(() {});
            }
          },
          child: Column(
            crossAxisAlignment: .start,
            children: [
              if (verticalPadding != 0) SizedBox(height: verticalPadding),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(message),
                ),
              ...widget.options.entries.map((kv) {
                final radioValue = kv.key;
                final radioTitle = kv.value;
                return SelectionRadioListTile(
                  value: radioValue,
                  title: radioTitle,
                  optionIconBuilder: widget.optionIconBuilder,
                  optionSubtitleBuilder: widget.optionSubtitleBuilder,
                  dense: widget.dense,
                );
              }),
              if (verticalPadding != 0) SizedBox(height: verticalPadding),
            ],
          ),
        ),
      ],
      actions: [
        const CancelButton(),
        if (needConfirmation)
          TextButton(
            onPressed: () => Navigator.maybeOf(context)?.pop<T>(_selectedValue),
            child: Text(confirmationButtonLabel),
          ),
      ],
    );
  }
}
