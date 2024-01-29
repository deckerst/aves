import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/radio_list_tile.dart';
import 'package:flutter/material.dart';

// do not use as `T` a record containing a collection
// because radio value comparison will fail without deep equality
class AvesSingleSelectionDialog<T> extends StatefulWidget {
  static const routeName = '/dialog/selection';

  final T initialValue;
  final Map<T, String> options;
  final TextBuilder<T>? optionSubtitleBuilder;
  final String? title, message, confirmationButtonLabel;
  final bool? dense;

  const AvesSingleSelectionDialog({
    super.key,
    required this.initialValue,
    required this.options,
    this.optionSubtitleBuilder,
    this.title,
    this.message,
    this.confirmationButtonLabel,
    this.dense,
  });

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
            optionSubtitleBuilder: widget.optionSubtitleBuilder,
            needConfirmation: needConfirmation,
            dense: widget.dense,
            getGroupValue: () => _selectedValue,
            setGroupValue: (v) => setState(() => _selectedValue = v),
          );
        }),
        if (verticalPadding != 0) SizedBox(height: verticalPadding),
      ],
      actions: [
        const CancelButton(),
        if (needConfirmation)
          TextButton(
            onPressed: () => Navigator.maybeOf(context)?.pop(_selectedValue),
            child: Text(confirmationButtonLabel),
          ),
      ],
    );
  }
}
