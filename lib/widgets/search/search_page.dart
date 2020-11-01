import 'package:aves/widgets/search/search_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  static const routeName = '/search';

  final ImageSearchDelegate delegate;
  final Animation<double> animation;

  const SearchPage({
    this.delegate,
    this.animation,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.delegate.queryTextController.addListener(_onQueryChanged);
    widget.animation.addStatusListener(_onAnimationStatusChanged);
    widget.delegate.currentBodyNotifier.addListener(_onSearchBodyChanged);
    focusNode.addListener(_onFocusChanged);
    widget.delegate.focusNode = focusNode;
  }

  @override
  void dispose() {
    super.dispose();
    widget.delegate.queryTextController.removeListener(_onQueryChanged);
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    widget.delegate.currentBodyNotifier.removeListener(_onSearchBodyChanged);
    widget.delegate.focusNode = null;
    focusNode.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    focusNode.requestFocus();
  }

  @override
  void didUpdateWidget(SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      oldWidget.delegate.queryTextController.removeListener(_onQueryChanged);
      widget.delegate.queryTextController.addListener(_onQueryChanged);
      oldWidget.delegate.currentBodyNotifier.removeListener(_onSearchBodyChanged);
      widget.delegate.currentBodyNotifier.addListener(_onSearchBodyChanged);
      oldWidget.delegate.focusNode = null;
      widget.delegate.focusNode = focusNode;
    }
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus && widget.delegate.currentBody != SearchBody.suggestions) {
      widget.delegate.showSuggestions(context);
    }
  }

  void _onQueryChanged() {
    setState(() {
      // rebuild ourselves because query changed.
    });
  }

  void _onSearchBodyChanged() {
    setState(() {
      // rebuild ourselves because search body changed.
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.delegate.appBarTheme(context);
    Widget body;
    switch (widget.delegate.currentBody) {
      case SearchBody.suggestions:
        body = KeyedSubtree(
          key: ValueKey<SearchBody>(SearchBody.suggestions),
          child: widget.delegate.buildSuggestions(context),
        );
        break;
      case SearchBody.results:
        body = KeyedSubtree(
          key: ValueKey<SearchBody>(SearchBody.results),
          child: widget.delegate.buildResults(context),
        );
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
          focusNode: focusNode,
          style: theme.textTheme.headline6,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => widget.delegate.showResults(context),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: MaterialLocalizations.of(context).searchFieldLabel,
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
