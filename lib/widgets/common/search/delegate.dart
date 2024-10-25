import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leak_tracker/leak_tracker.dart';
import 'package:provider/provider.dart';

abstract class AvesSearchDelegate extends SearchDelegate {
  final String routeName;
  final bool canPop;
  final TextEditingController queryTextController = TextEditingController();
  final ValueNotifier<SearchBody?> currentBodyNotifier = ValueNotifier(null);

  AvesSearchDelegate({
    required this.routeName,
    this.canPop = true,
    String? initialQuery,
    required super.searchFieldLabel,
    required super.searchFieldStyle,
  }) {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$AvesSearchDelegate',
        object: this,
      );
    }
    query = initialQuery ?? '';
  }

  @override
  Widget? buildLeading(BuildContext context) {
    if (settings.useTvLayout) {
      return const Icon(AIcons.search);
    }

    // use a property instead of checking `Navigator.canPop(context)`
    // because the navigator state changes as soon as we press back
    // so the leading may mistakenly switch to the close button
    final animate = context.read<Settings>().animate;
    return canPop
        ? IconButton(
            icon: animate ? AnimatedIcon(
              icon: AnimatedIcons.menu_arrow,
              progress: transitionAnimation,
            ): const Icon(Icons.arrow_back),
            onPressed: () => goBack(context),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          )
        : const CloseButton(
            onPressed: SystemNavigator.pop,
          );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (!settings.useTvLayout && query.isNotEmpty)
        IconButton(
          icon: const Icon(AIcons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          tooltip: context.l10n.clearTooltip,
        ),
    ];
  }

  void goBack(BuildContext context) {
    clean();
    Navigator.maybeOf(context)?.pop();
  }

  void clean() {
    currentBody = null;
    searchFieldFocusNode?.unfocus();
  }

  // adapted from Flutter `SearchDelegate` in `/material/search.dart`

  @override
  void showResults(BuildContext context) {
    if (settings.useTvLayout) {
      suggestionsScrollController?.jumpTo(0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        suggestionsFocusNode?.requestFocus();
        FocusScope.of(context).nextFocus();
      });
    } else {
      searchFieldFocusNode?.unfocus();
      currentBody = SearchBody.results;
    }
  }

  @override
  void showSuggestions(BuildContext context) {
    assert(searchFieldFocusNode != null, '_focusNode must be set by route before showSuggestions is called.');
    searchFieldFocusNode!.requestFocus();
    currentBody = SearchBody.suggestions;
  }

  @override
  Animation<double> get transitionAnimation => proxyAnimation;

  FocusNode? searchFieldFocusNode;

  FocusNode? get suggestionsFocusNode => null;

  ScrollController? get suggestionsScrollController => null;

  final ProxyAnimation proxyAnimation = ProxyAnimation(kAlwaysDismissedAnimation);

  @override
  String get query => queryTextController.text;

  @override
  set query(String value) {
    queryTextController.text = value;
    if (queryTextController.text.isNotEmpty) {
      queryTextController.selection = TextSelection.fromPosition(TextPosition(offset: queryTextController.text.length));
    }
  }

  SearchBody? get currentBody => currentBodyNotifier.value;

  set currentBody(SearchBody? value) {
    currentBodyNotifier.value = value;
  }

  SearchPageRoute? route;

  /// Releases the resources.
  @override
  @mustCallSuper
  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    currentBodyNotifier.dispose();
    queryTextController.dispose();
    proxyAnimation.parent = null;
    super.dispose();
  }
}
