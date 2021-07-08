import 'package:aves/theme/durations.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  static const routeName = '/search';

  final CollectionSearchDelegate delegate;
  final Animation<double> animation;

  const SearchPage({
    Key? key,
    required this.delegate,
    required this.animation,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final Debouncer _debouncer = Debouncer(delay: Durations.searchDebounceDelay);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.delegate.queryTextController.addListener(_onQueryChanged);
    widget.animation.addStatusListener(_onAnimationStatusChanged);
    widget.delegate.currentBodyNotifier.addListener(_onSearchBodyChanged);
    _focusNode.addListener(_onFocusChanged);
    widget.delegate.focusNode = _focusNode;
  }

  @override
  void dispose() {
    widget.delegate.queryTextController.removeListener(_onQueryChanged);
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    widget.delegate.currentBodyNotifier.removeListener(_onSearchBodyChanged);
    widget.delegate.focusNode = null;
    _focusNode.dispose();
    super.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    _focusNode.requestFocus();
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      oldWidget.delegate.queryTextController.removeListener(_onQueryChanged);
      widget.delegate.queryTextController.addListener(_onQueryChanged);
      oldWidget.delegate.currentBodyNotifier.removeListener(_onSearchBodyChanged);
      widget.delegate.currentBodyNotifier.addListener(_onSearchBodyChanged);
      oldWidget.delegate.focusNode = null;
      widget.delegate.focusNode = _focusNode;
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && widget.delegate.currentBody != SearchBody.suggestions) {
      widget.delegate.showSuggestions(context);
    }
  }

  void _onQueryChanged() {
    _debouncer(() {
      if (mounted) {
        // rebuild ourselves because query changed.
        setState(() {});
      }
    });
  }

  void _onSearchBodyChanged() {
    setState(() {
      // rebuild ourselves because search body changed.
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget? body;
    switch (widget.delegate.currentBody) {
      case SearchBody.suggestions:
        body = KeyedSubtree(
          key: const ValueKey<SearchBody>(SearchBody.suggestions),
          child: widget.delegate.buildSuggestions(context),
        );
        break;
      case SearchBody.results:
        body = KeyedSubtree(
          key: const ValueKey<SearchBody>(SearchBody.results),
          child: widget.delegate.buildResults(context),
        );
        break;
      case null:
        break;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        iconTheme: theme.primaryIconTheme,
        textTheme: theme.primaryTextTheme,
        brightness: theme.primaryColorBrightness,
        leading: widget.delegate.buildLeading(context),
        title: TextField(
          controller: widget.delegate.queryTextController,
          focusNode: _focusNode,
          style: theme.textTheme.headline6,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => widget.delegate.showResults(context),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: context.l10n.searchCollectionFieldHint,
            hintStyle: theme.inputDecorationTheme.hintStyle,
          ),
        ),
        actions: widget.delegate.buildActions(context),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: body,
      ),
    );
  }
}
