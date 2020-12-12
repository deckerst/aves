import 'dart:collection';
import 'dart:convert';

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/utils/string_utils.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:aves/widgets/fullscreen/source_viewer_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class SvgMetadata {
  static const docDirectory = 'Document';
  static const metadataDirectory = 'Metadata';

  static const _attributes = ['x', 'y', 'width', 'height', 'preserveAspectRatio', 'viewBox'];
  static const _textElements = ['title', 'desc'];
  static const _metadataElement = 'metadata';

  static Future<Map<String, Map<String, String>>> getAllMetadata(ImageEntry entry) async {
    try {
      final data = await ImageFileService.getImage(entry.uri, entry.mimeType, 0, false);

      final document = XmlDocument.parse(utf8.decode(data));
      final root = document.rootElement;

      final docDir = Map.fromEntries([
        ...root.attributes.where((a) => _attributes.contains(a.name.qualified)).map((a) => MapEntry(_formatKey(a.name.qualified), a.value)),
        ..._textElements.map((name) => MapEntry(_formatKey(name), root.getElement(name)?.text)).where((kv) => kv.value != null),
      ]);

      final metadata = root.getElement(_metadataElement);
      final metadataDir = Map.fromEntries([
        if (metadata != null) MapEntry('Metadata', metadata.toXmlString(pretty: true)),
      ]);

      return {
        if (docDir.isNotEmpty) docDirectory: docDir,
        if (metadataDir.isNotEmpty) metadataDirectory: metadataDir,
      };
    } catch (exception, stack) {
      debugPrint('failed to parse XML from SVG with exception=$exception\n$stack');
      return null;
    }
  }

  static Map<String, InfoLinkHandler> getLinkHandlers(SplayTreeMap<String, String> tags) {
    return {
      'Metadata': InfoLinkHandler(
        linkText: 'View XML',
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: SourceViewerPage.routeName),
              builder: (context) => SourceViewerPage(
                loader: () => SynchronousFuture(tags['Metadata']),
              ),
            ),
          );
        },
      ),
    };
  }

  static String _formatKey(String key) {
    switch (key) {
      case 'desc':
        return 'Description';
      default:
        return key.toSentenceCase();
    }
  }
}
