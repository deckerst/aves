import 'package:aves/model/entry.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/basic/query_bar.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryQueryBar extends StatefulWidget {
  final ValueNotifier<String> queryNotifier;
  final FocusNode focusNode;

  static const preferredHeight = kToolbarHeight;

  const EntryQueryBar({
    Key? key,
    required this.queryNotifier,
    required this.focusNode,
  }) : super(key: key);

  @override
  _EntryQueryBarState createState() => _EntryQueryBarState();
}

class _EntryQueryBarState extends State<EntryQueryBar> {
  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant EntryQueryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  // TODO TLAD focus on text field when enabled (`autofocus` is unusable)
  // TODO TLAD lose focus on navigation to viewer?
  void _registerWidget(EntryQueryBar widget) {
    widget.queryNotifier.addListener(_onQueryChanged);
  }

  void _unregisterWidget(EntryQueryBar widget) {
    widget.queryNotifier.removeListener(_onQueryChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: EntryQueryBar.preferredHeight,
      alignment: Alignment.topCenter,
      child: Selector<Selection<AvesEntry>, bool>(
        selector: (context, selection) => !selection.isSelecting,
        builder: (context, editable, child) => QueryBar(
          queryNotifier: widget.queryNotifier,
          focusNode: widget.focusNode,
          hintText: context.l10n.collectionSearchTitlesHintText,
          editable: editable,
        ),
      ),
    );
  }

  void _onQueryChanged() {
    final query = widget.queryNotifier.value;
    context.read<CollectionLens>().setLiveQuery(query);
  }
}
