import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class const AvesReorderableListDialog<T>({
  super.key,
  required final List<T> initialValue,
  required final Map<T, String> options,
  final String? title,
  final String? confirmationButtonLabel,
}) extends StatefulWidget {
  static const routeName = '/dialog/reorderable_list';

  @override
  State<AvesReorderableListDialog<T>> createState() => _AvesReorderableListDialogState<T>();
}

class _AvesReorderableListDialogState<T> extends State<AvesReorderableListDialog<T>> {
  late List<T> items;

  Map<T, String> get options => widget.options;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    items = [
      ...initialValue,
      ...options.keys.whereNot(initialValue.contains),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final verticalPadding = title == null ? AvesDialog.cornerRadius.y / 2 : .0;
    return AvesDialog(
      title: title,
      scrollableContent: [
        ReorderableListView.builder(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              key: ValueKey(item),
              leading: const Icon(AIcons.dragHandle),
              title: Text(options[item] ?? '?'),
            );
          },
          itemCount: options.length,
          onReorderItem: (oldIndex, newIndex) => setState(
            () => items.insert(newIndex, items.removeAt(oldIndex)),
          ),
          shrinkWrap: true,
        ),
      ],
      actions: [
        const CancelButton(),
        TextButton(
          onPressed: () => Navigator.maybeOf(context)?.pop<List<T>>(items),
          child: Text(widget.confirmationButtonLabel ?? context.l10n.applyButtonLabel),
        ),
      ],
    );
  }
}
