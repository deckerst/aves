import 'dart:ui';

import 'package:aves/theme/durations.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/identity/aves_app_bar.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/search/delegate.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SearchPage extends StatefulWidget {
  final AvesSearchDelegate delegate;
  final Animation<double> animation;

  const SearchPage({
    super.key,
    required this.delegate,
    required this.animation,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final Debouncer _debouncer = Debouncer(delay: Durations.searchDebounceDelay);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    widget.animation.addStatusListener(_onAnimationStatusChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _registerWidget(SearchPage widget) {
    widget.delegate.queryTextController.addListener(_onQueryChanged);
    widget.delegate.currentBodyNotifier.addListener(_onSearchBodyChanged);
    widget.delegate.focusNode = _focusNode;
  }

  void _unregisterWidget(SearchPage widget) {
    widget.delegate.queryTextController.removeListener(_onQueryChanged);
    widget.delegate.currentBodyNotifier.removeListener(_onSearchBodyChanged);
    widget.delegate.focusNode = null;
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    Future.delayed(Durations.pageTransitionAnimation * timeDilation).then((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
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
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          leading: Hero(
            tag: AvesAppBar.leadingHeroTag,
            transitionOnUserGestures: true,
            child: Center(child: widget.delegate.buildLeading(context)),
          ),
          title: Hero(
            tag: AvesAppBar.titleHeroTag,
            transitionOnUserGestures: true,
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontFeatures: [FontFeature.disable('smcp')]),
              child: TextField(
                controller: widget.delegate.queryTextController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.delegate.searchFieldLabel,
                  hintStyle: theme.inputDecorationTheme.hintStyle,
                ),
                textInputAction: TextInputAction.search,
                style: theme.textTheme.headline6,
                onSubmitted: (_) => widget.delegate.showResults(context),
              ),
            ),
          ),
          actions: widget.delegate.buildActions(context),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: body,
        ),
      ),
    );
  }
}
