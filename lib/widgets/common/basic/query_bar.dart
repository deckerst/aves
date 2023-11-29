import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class QueryBar extends StatefulWidget {
  final ValueNotifier<String> queryNotifier;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? leadingPadding;
  final IconData? icon;
  final String? hintText;
  final bool editable;

  const QueryBar({
    super.key,
    required this.queryNotifier,
    this.focusNode,
    this.leadingPadding,
    this.icon,
    this.hintText,
    this.editable = true,
  });

  @override
  State<QueryBar> createState() => _QueryBarState();

  static double getPreferredHeight(TextScaler textScaler) => textScaler.scale(kToolbarHeight);
}

class _QueryBarState extends State<QueryBar> {
  final Debouncer _debouncer = Debouncer(delay: ADurations.searchDebounceDelay);
  late TextEditingController _controller;

  ValueNotifier<String> get queryNotifier => widget.queryNotifier;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: queryNotifier.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      style: Theme.of(context).textTheme.bodyMedium!,
      child: FontSizeIconTheme(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: widget.focusNode,
                decoration: InputDecoration(
                  icon: Padding(
                    padding: widget.leadingPadding ?? const EdgeInsetsDirectional.only(start: 16),
                    // set theme at this level because `InputDecoration` defines its own `IconTheme` with a fixed size
                    child: FontSizeIconTheme(
                      child: Icon(widget.icon ?? AIcons.filter),
                    ),
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
                  duration: ADurations.appBarActionChangeAnimation,
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
      ),
    );
  }
}
