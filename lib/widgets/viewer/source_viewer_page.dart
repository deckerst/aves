import 'package:aves/widgets/common/aves_highlight.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/darcula.dart';

class SourceViewerPage extends StatefulWidget {
  static const routeName = '/viewer/source';

  final Future<String> Function() loader;

  const SourceViewerPage({
    super.key,
    required this.loader,
  });

  @override
  State<SourceViewerPage> createState() => _SourceViewerPageState();
}

class _SourceViewerPageState extends State<SourceViewerPage> {
  late Future<String> _loader;

  static const maxCodeSize = 2 << 16; // 128kB

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

            final data = snapshot.data!;
            final source = data.length < maxCodeSize ? data : '${data.substring(0, maxCodeSize)}\n\n*** TRUNCATED ***';

            return Container(
              constraints: const BoxConstraints.expand(),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: AvesHighlightView(
                    input: source,
                    language: 'xml',
                    theme: darculaTheme,
                    padding: const EdgeInsets.all(8),
                    textStyle: const TextStyle(
                      fontSize: 10,
                    ),
                    tabSize: 4,
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
