import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/markdown_container.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PolicyPage extends StatefulWidget {
  static const routeName = '/about/policy';

  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  late Future<String> _termsLoader;
  final ScrollController _scrollController = ScrollController();

  static const termsPath = 'assets/terms.md';
  static const termsDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    _termsLoader = rootBundle.loadString(termsPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !settings.useTvLayout,
        title: Text(context.l10n.policyPageTitle),
      ),
      body: SafeArea(
        child: FocusableActionDetector(
          autofocus: true,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.arrowUp): _ScrollIntent.up(),
            SingleActivator(LogicalKeyboardKey.arrowDown): _ScrollIntent.down(),
          },
          actions: {
            _ScrollIntent: CallbackAction<_ScrollIntent>(onInvoke: _onScrollIntent),
          },
          child: Center(
            child: FutureBuilder<String>(
              future: _termsLoader,
              builder: (context, snapshot) {
                if (snapshot.hasError || snapshot.connectionState != ConnectionState.done) return const SizedBox();
                final terms = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: MarkdownContainer(
                    scrollController: _scrollController,
                    data: terms,
                    textDirection: termsDirection,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onScrollIntent(_ScrollIntent intent) {
    late int factor;
    switch (intent.type) {
      case _ScrollDirection.up:
        factor = -1;
        break;
      case _ScrollDirection.down:
        factor = 1;
        break;
    }
    _scrollController.animateTo(
      _scrollController.offset + factor * 150,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }
}

class _ScrollIntent extends Intent {
  const _ScrollIntent({
    required this.type,
  });

  const _ScrollIntent.up() : type = _ScrollDirection.up;

  const _ScrollIntent.down() : type = _ScrollDirection.down;

  final _ScrollDirection type;
}

enum _ScrollDirection {
  up,
  down,
}
