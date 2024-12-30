import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/pop/double_back.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/behaviour/pop/tv_navigation.dart';
import 'package:aves/widgets/common/identity/aves_app_bar.dart';
import 'package:aves/widgets/common/search/delegate.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  static const routeName = '/search';

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
  final Debouncer _debouncer = Debouncer(delay: ADurations.searchDebounceDelay);
  final FocusNode _searchFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    widget.animation.addStatusListener(_onAnimationStatusChanged);
    _searchFieldFocusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delegate != widget.delegate) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    _searchFieldFocusNode.dispose();
    super.dispose();
  }

  void _registerWidget(SearchPage widget) {
    widget.delegate.queryTextController.addListener(_onQueryChanged);
    widget.delegate.currentBodyNotifier.addListener(_onSearchBodyChanged);
    widget.delegate.searchFieldFocusNode = _searchFieldFocusNode;
  }

  void _unregisterWidget(SearchPage widget) {
    widget.delegate.queryTextController.removeListener(_onQueryChanged);
    widget.delegate.currentBodyNotifier.removeListener(_onSearchBodyChanged);
    widget.delegate.searchFieldFocusNode = null;
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (!status.isCompleted) {
      return;
    }
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    Future.delayed(ADurations.pageTransitionLoose * timeDilation).then((_) {
      if (!mounted) return;
      _searchFieldFocusNode.requestFocus();
    });
  }

  void _onFocusChanged() {
    if (_searchFieldFocusNode.hasFocus && widget.delegate.currentBody != SearchBody.suggestions) {
      widget.delegate.showSuggestions(context);
    }
  }

  void _onQueryChanged() {
    _debouncer(() {
      if (!mounted) return;
      // rebuild ourselves because query changed.
      setState(() {});
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

    Widget leading = Center(child: widget.delegate.buildLeading(context));
    Widget title = DefaultTextStyle.merge(
      style: const TextStyle(fontFeatures: [FontFeature.disable('smcp')]),
      child: TextField(
        controller: widget.delegate.queryTextController,
        focusNode: _searchFieldFocusNode,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.delegate.searchFieldLabel,
          hintStyle: theme.inputDecorationTheme.hintStyle,
        ),
        textInputAction: TextInputAction.search,
        style: Themes.searchFieldStyle(context),
        onSubmitted: (_) => widget.delegate.showResults(context),
      ),
    );
    Widget body;
    switch (widget.delegate.currentBody) {
      case SearchBody.suggestions:
        body = KeyedSubtree(
          key: const ValueKey<SearchBody>(SearchBody.suggestions),
          child: widget.delegate.buildSuggestions(context),
        );
      case SearchBody.results:
        body = KeyedSubtree(
          key: const ValueKey<SearchBody>(SearchBody.results),
          child: widget.delegate.buildResults(context),
        );
      case null:
        body = const SizedBox();
    }

    final animate = context.select<Settings, bool>((v) => v.animate);
    if (animate) {
      leading = Hero(
        tag: AvesAppBar.leadingHeroTag,
        transitionOnUserGestures: true,
        child: leading,
      );
      title = Hero(
        tag: AvesAppBar.titleHeroTag,
        transitionOnUserGestures: true,
        child: title,
      );
      body = AnimatedSwitcher(
        duration: ADurations.searchBodyTransition,
        child: body,
      );
    }

    return AvesScaffold(
      appBar: AppBar(
        leading: leading,
        title: title,
        actions: widget.delegate.buildActions(context),
      ),
      body: AvesPopScope(
        handlers: [
          tvNavigationPopHandler,
          doubleBackPopHandler,
        ],
        child: body,
      ),
    );
  }
}
