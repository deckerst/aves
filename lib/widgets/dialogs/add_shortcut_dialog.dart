import 'package:aves/model/covers.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/item_picker.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/item_pick_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

class AddShortcutDialog extends StatefulWidget {
  static const routeName = '/dialog/add_shortcut';

  final CollectionLens? collection;
  final String defaultName;

  const AddShortcutDialog({
    super.key,
    required this.defaultName,
    this.collection,
  });

  @override
  State<AddShortcutDialog> createState() => _AddShortcutDialogState();
}

class _AddShortcutDialogState extends State<AddShortcutDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);
  AvesEntry? _coverEntry;

  @override
  void initState() {
    super.initState();
    final _collection = widget.collection;
    if (_collection != null) {
      final entries = _collection.sortedEntries;
      if (entries.isNotEmpty) {
        final coverEntries = _collection.filters.map((filter) => covers.of(filter)?.$1).whereNotNull().map((id) => entries.firstWhereOrNull((entry) => entry.id == id)).whereNotNull();
        _coverEntry = coverEntries.firstOrNull ?? entries.first;
      }
    }
    _nameController.text = widget.defaultName;
    _validate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Builder(
        builder: (context) {
          final shortestSide = MediaQuery.sizeOf(context).shortestSide;
          final extent = (shortestSide / 3.0).clamp(60.0, 160.0);
          return AvesDialog(
            scrollableContent: [
              if (_coverEntry != null)
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 16),
                  child: ItemPicker(
                    extent: extent,
                    entry: _coverEntry!,
                    onTap: _pickEntry,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.addShortcutDialogLabel,
                  ),
                  autofocus: true,
                  maxLength: 25,
                  onChanged: (_) => _validate(),
                  onSubmitted: (_) => _submit(context),
                ),
              ),
            ],
            actions: [
              const CancelButton(),
              ValueListenableBuilder<bool>(
                valueListenable: _isValidNotifier,
                builder: (context, isValid, child) {
                  return TextButton(
                    onPressed: isValid ? () => _submit(context) : null,
                    child: Text(context.l10n.addShortcutButtonLabel),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickEntry() async {
    final _collection = widget.collection;
    if (_collection == null) return;

    final entry = await Navigator.maybeOf(context)?.push<AvesEntry>(
      MaterialPageRoute(
        settings: const RouteSettings(name: ItemPickPage.routeName),
        builder: (context) {
          final pickFilters = _collection.filters.toSet();
          final liveFilters = pickFilters.whereType<QueryFilter>().where((v) => v.live).toSet();
          liveFilters.forEach((filter) {
            pickFilters.remove(filter);
            pickFilters.add(QueryFilter(filter.query));
          });
          return ItemPickPage(
            collection: CollectionLens(
              source: _collection.source,
              filters: pickFilters,
            ),
            canRemoveFilters: false,
          );
        },
        fullscreenDialog: true,
      ),
    );
    if (entry != null) {
      _coverEntry = entry;
      setState(() {});
    }
  }

  Future<void> _validate() async {
    final name = _nameController.text;
    _isValidNotifier.value = name.isNotEmpty;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop<(AvesEntry?, String)>((_coverEntry, _nameController.text));
    }
  }
}
