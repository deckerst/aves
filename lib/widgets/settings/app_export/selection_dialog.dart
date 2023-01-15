import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/settings/app_export/items.dart';
import 'package:flutter/material.dart';

class AppExportItemSelectionDialog extends StatefulWidget {
  final String title;
  final Set<AppExportItem>? selectableItems, initialSelection;

  const AppExportItemSelectionDialog({
    super.key,
    required this.title,
    this.selectableItems,
    this.initialSelection,
  });

  @override
  State<AppExportItemSelectionDialog> createState() => _AppExportItemSelectionDialogState();
}

class _AppExportItemSelectionDialogState extends State<AppExportItemSelectionDialog> {
  final Set<AppExportItem> _selectableItems = {}, _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _selectableItems.addAll(widget.selectableItems ?? AppExportItem.values);
    _selectedItems.addAll(widget.initialSelection ?? _selectableItems);
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      title: widget.title,
      scrollableContent: AppExportItem.values.map((v) {
        return SwitchListTile(
          value: _selectedItems.contains(v),
          onChanged: _selectableItems.contains(v)
              ? (selected) {
                  if (selected == true) {
                    _selectedItems.add(v);
                  } else {
                    _selectedItems.remove(v);
                  }
                  setState(() {});
                }
              : null,
          title: Text(
            v.getText(context),
            softWrap: false,
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
        );
      }).toList(),
      actions: [
        const CancelButton(),
        TextButton(
          onPressed: _selectedItems.isEmpty ? null : () => Navigator.pop(context, _selectedItems),
          child: Text(context.l10n.applyButtonLabel),
        ),
      ],
    );
  }
}
