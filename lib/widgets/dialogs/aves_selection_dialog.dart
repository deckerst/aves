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

class SelectionRadioListTile<T> extends StatelessWidget {
  final T value;
  final String title;
  final TextBuilder<T>? optionSubtitleBuilder;
  final bool needConfirmation;
  final bool? dense;
  final T Function() getGroupValue;
  final void Function(T value) setGroupValue;

  const SelectionRadioListTile({
    super.key,
    required this.value,
    required this.title,
    this.optionSubtitleBuilder,
    required this.needConfirmation,
    this.dense,
    required this.getGroupValue,
    required this.setGroupValue,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = optionSubtitleBuilder?.call(value);
    return ReselectableRadioListTile<T>(
      // key is expected by test driver
      key: Key('$value'),
      value: value,
      groupValue: getGroupValue(),
      onChanged: (v) {
        if (needConfirmation) {
          setGroupValue(v as T);
        } else {
          Navigator.maybeOf(context)?.pop(v);
        }
      },
      reselectable: true,
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              softWrap: false,
              overflow: TextOverflow.fade,
            )
          : null,
      dense: dense,
    );
  }
}
