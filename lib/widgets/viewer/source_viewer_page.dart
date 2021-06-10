import 'package:aves/widgets/common/aves_highlight.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/darcula.dart';

class SourceViewerPage extends StatefulWidget {
  static const routeName = '/viewer/source';

  final Future<String> Function() loader;

  const SourceViewerPage({
    required this.loader,
  });

  @override
  _SourceViewerPageState createState() => _SourceViewerPageState();
}

class _SourceViewerPageState extends State<SourceViewerPage> {
  late Future<String> _loader;

  @override
  void initState() {
    super.initState();
    _loader = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.sourceViewerPageTitle),
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _loader,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (!snapshot.hasData) return const SizedBox.shrink();

            final source = snapshot.data!;
            final highlightView = AvesHighlightView(
              source,
              language: 'xml',
              theme: darculaTheme,
              padding: const EdgeInsets.all(8),
              textStyle: const TextStyle(
                fontSize: 12,
              ),
              tabSize: 4,
            );
            return Container(
              constraints: const BoxConstraints.expand(),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: highlightView,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
