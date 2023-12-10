import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:flutter/material.dart';

class AvesMultiSelectionDialog<T> extends StatefulWidget {
  static const routeName = '/dialog/multi_selection';

  final Set<T> initialValue;
  final Map<T, String> options;
  final TextBuilder<T>? optionSubtitleBuilder;
  final String? title, message;
  final bool? dense;

  const AvesMultiSelectionDialog({
    super.key,
    required this.initialValue,
    required this.options,
    this.optionSubtitleBuilder,
    this.title,
    this.message,
    this.dense,
  });

  @override
  State<AvesMultiSelectionDialog<T>> createState() => _AvesMultiSelectionDialogState<T>();
}

class _AvesMultiSelectionDialogState<T> extends State<AvesMultiSelectionDialog<T>> {
  late Set<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final message = widget.message;
    final verticalPadding = (title == null && message == null) ? AvesDialog.cornerRadius.y / 2 : .0;
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
          final value = kv.key;
          final title = kv.value;
          final subtitle = widget.optionSubtitleBuilder?.call(value);
          return SwitchListTile(
            value: _selectedValues.contains(value),
            onChanged: (v) {
              if (v) {
                _selectedValues.add(value);
              } else {
                _selectedValues.remove(value);
              }
              setState(() {});
            },
            title: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(title),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  )
                : null,
            dense: widget.dense,
          );
        }),
        if (verticalPadding != 0) SizedBox(height: verticalPadding),
      ],
      actions: [
        const CancelButton(),
        TextButton(
          onPressed: () => Navigator.maybeOf(context)?.pop(widget.options.keys.where(_selectedValues.contains).toList()),
          child: Text(context.l10n.applyButtonLabel),
        ),
      ],
    );
  }
}
