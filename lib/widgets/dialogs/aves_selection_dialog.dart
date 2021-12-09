import 'package:aves/widgets/common/basic/reselectable_radio_list_tile.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

typedef TextBuilder<T> = String Function(T value);

class AvesSelectionDialog<T> extends StatefulWidget {
  final T initialValue;
  final Map<T, String> options;
  final TextBuilder<T>? optionSubtitleBuilder;
  final String? title, message, confirmationButtonLabel;

  const AvesSelectionDialog({
    Key? key,
    required this.initialValue,
    required this.options,
    this.optionSubtitleBuilder,
    this.title,
    this.message,
    this.confirmationButtonLabel,
  }) : super(key: key);

  @override
  _AvesSelectionDialogState<T> createState() => _AvesSelectionDialogState<T>();
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
      context: context,
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
            child: Text(confirmationButtonLabel!),
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
    );
  }
}
