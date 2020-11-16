import 'dart:convert';

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/widgets/common/aves_highlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/darcula.dart';

class SourceViewerPage extends StatefulWidget {
  static const routeName = '/fullscreen/source';

  final ImageEntry entry;

  const SourceViewerPage({
    @required this.entry,
  });

  @override
  _SourceViewerPageState createState() => _SourceViewerPageState();
}

class _SourceViewerPageState extends State<SourceViewerPage> {
  Future<String> _loader;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _loader = ImageFileService.getImage(entry.uri, entry.mimeType, 0, false).then(utf8.decode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Source'),
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _loader,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return SizedBox.shrink();
            }

            final source = snapshot.data;
            final highlightView = AvesHighlightView(
              source,
              language: 'xml',
              theme: darculaTheme,
              padding: EdgeInsets.all(8),
              textStyle: TextStyle(
                fontSize: 12,
              ),
              tabSize: 4,
            );
            return Container(
              constraints: BoxConstraints.expand(),
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
