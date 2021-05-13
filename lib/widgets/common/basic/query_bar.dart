import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QueryBar extends StatefulWidget {
  final ValueNotifier<String> filterNotifier;

  const QueryBar({required this.filterNotifier});

  @override
  _QueryBarState createState() => _QueryBarState();
}

class _QueryBarState extends State<QueryBar> {
  final Debouncer _debouncer = Debouncer(delay: Durations.searchDebounceDelay);
  late TextEditingController _controller;

  ValueNotifier<String> get filterNotifier => widget.filterNotifier;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: filterNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    final clearButton = IconButton(
      icon: Icon(AIcons.clear),
      onPressed: () {
        _controller.clear();
        filterNotifier.value = '';
      },
      tooltip: context.l10n.clearTooltip,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              icon: Padding(
                padding: EdgeInsetsDirectional.only(start: 16),
                child: Icon(AIcons.search),
              ),
              hintText: MaterialLocalizations.of(context).searchFieldLabel,
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
            ),
            textInputAction: TextInputAction.search,
            onChanged: (s) => _debouncer(() => filterNotifier.value = s),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 16),
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
              child: value.text.isNotEmpty ? clearButton : SizedBox.shrink(),
            ),
          ),
        )
      ],
    );
  }
}
