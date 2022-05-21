import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class QueryBar extends StatefulWidget {
  final ValueNotifier<String> queryNotifier;
  final FocusNode? focusNode;
  final IconData? icon;
  final String? hintText;
  final bool editable;

  const QueryBar({
    super.key,
    required this.queryNotifier,
    this.focusNode,
    this.icon,
    this.hintText,
    this.editable = true,
  });

  @override
  State<QueryBar> createState() => _QueryBarState();
}

class _QueryBarState extends State<QueryBar> {
  final Debouncer _debouncer = Debouncer(delay: Durations.searchDebounceDelay);
  late TextEditingController _controller;

  ValueNotifier<String> get queryNotifier => widget.queryNotifier;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: queryNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    final clearButton = IconButton(
      icon: const Icon(AIcons.clear),
      onPressed: widget.editable
          ? () {
              _controller.clear();
              queryNotifier.value = '';
            }
          : null,
      tooltip: context.l10n.clearTooltip,
    );

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2!,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: widget.focusNode ?? FocusNode(),
              decoration: InputDecoration(
                icon: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: Icon(widget.icon ?? AIcons.filter),
                ),
                hintText: widget.hintText ?? MaterialLocalizations.of(context).searchFieldLabel,
                hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (s) => _debouncer(() => queryNotifier.value = s.trim()),
              enabled: widget.editable,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 16),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, child) => AnimatedSwitcher(
                duration: Durations.appBarActionChangeAnimation,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    axis: Axis.horizontal,
                    sizeFactor: animation,
                    child: child,
                  ),
                ),
                child: value.text.isNotEmpty ? clearButton : const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
