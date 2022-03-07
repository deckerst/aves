import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/reselectable_radio_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'aves_dialog.dart';

Future<void> showSelectionDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required void Function(T value) onSelection,
}) async {
  final value = await showDialog<T>(
    context: context,
    builder: builder,
  );
  // wait for the dialog to hide as applying the change may block the UI
  await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
  if (value != null) {
    onSelection(value);
  }
}

typedef TextBuilder<T> = String Function(T value);

class AvesSelectionDialog<T> extends StatefulWidget {
  final T initialValue;
  final Map<T, String> options;
  final TextBuilder<T>? optionSubtitleBuilder;
  final String? title, message, confirmationButtonLabel;
  final bool? dense;

  const AvesSelectionDialog({
    Key? key,
    required this.initialValue,
    required this.options,
    this.optionSubtitleBuilder,
    this.title,
    this.message,
    this.confirmationButtonLabel,
    this.dense,
  }) : super(key: key);

  @override
  State<AvesSelectionDialog<T>> createState() => _AvesSelectionDialogState<T>();
}

class _AvesSelectionDialogState<T> extends State<AvesSelectionDialog<T>> {
  late T _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final confirmationButtonLabel = widget.confirmationButtonLabel;
    final needConfirmation = confirmationButtonLabel != null;
    return AvesDialog(
      title: widget.title,
      scrollableContent: [
        if (message != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(message),
          ),
        ...widget.options.entries.map((kv) => _buildRadioListTile(kv.key, kv.value, needConfirmation)),
      ],
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        if (needConfirmation)
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedValue),
            child: Text(confirmationButtonLabel),
          ),
      ],
    );
  }

  Widget _buildRadioListTile(T value, String title, bool needConfirmation) {
    final subtitle = widget.optionSubtitleBuilder?.call(value);
    return ReselectableRadioListTile<T>(
      // key is expected by test driver
      key: Key(value.toString()),
      value: value,
      groupValue: _selectedValue,
      onChanged: (v) {
        if (needConfirmation) {
          setState(() => _selectedValue = v!);
        } else {
          Navigator.pop(context, v);
        }
      },
      reselectable: true,
      title: Text(
        title,
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              softWrap: false,
              overflow: TextOverflow.fade,
              maxLines: 1,
            )
          : null,
      dense: widget.dense,
    );
  }
}
