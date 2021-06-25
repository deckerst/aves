import 'dart:convert';

import 'package:aves/model/entry.dart';
import 'package:aves/services/services.dart';
import 'package:aves/utils/string_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class SvgMetadataService {
  static const docDirectory = 'Document';
  static const metadataDirectory = 'Metadata';

  static const _attributes = ['x', 'y', 'width', 'height', 'preserveAspectRatio', 'viewBox'];
  static const _textElements = ['title', 'desc'];
  static const _metadataElement = 'metadata';

  static Future<Size?> getSize(AvesEntry entry) async {
    try {
      final data = await imageFileService.getSvg(entry.uri, entry.mimeType);

      final document = XmlDocument.parse(utf8.decode(data));
      final root = document.rootElement;

      String? getAttribute(String attributeName) => root.attributes.firstWhereOrNull((a) => a.name.qualified == attributeName)?.value;
      double? tryParseWithoutUnit(String? s) => s == null ? null : double.tryParse(s.replaceAll(RegExp(r'[a-z%]'), ''));

      final width = tryParseWithoutUnit(getAttribute('width'));
      final height = tryParseWithoutUnit(getAttribute('height'));
      if (width != null && height != null) {
        return Size(width, height);
      }

      final viewBox = getAttribute('viewBox');
      if (viewBox != null) {
        final parts = viewBox.split(RegExp(r'[\s,]+'));
        if (parts.length == 4) {
          final vbWidth = tryParseWithoutUnit(parts[2]);
          final vbHeight = tryParseWithoutUnit(parts[3]);
          if (vbWidth != null && vbWidth > 0 && vbHeight != null && vbHeight > 0) {
            return Size(vbWidth, vbHeight);
          }
        }
      }
    } catch (error, stack) {
      debugPrint('failed to parse XML from SVG with error=$error\n$stack');
    }
    return null;
  }

  static Future<Map<String, Map<String, String>>> getAllMetadata(AvesEntry entry) async {
    String formatKey(String key) {
      switch (key) {
        case 'desc':
          return 'Description';
        default:
          return key.toSentenceCase();
      }
    }

    try {
      final data = await imageFileService.getSvg(entry.uri, entry.mimeType);

      final document = XmlDocument.parse(utf8.decode(data));
      final root = document.rootElement;

      final docDir = Map.fromEntries([
        ...root.attributes.where((a) => _attributes.contains(a.name.qualified)).map((a) => MapEntry(formatKey(a.name.qualified), a.value)),
        ..._textElements.map((name) => MapEntry(formatKey(name), root.getElement(name)?.text)).where((kv) => kv.value != null).cast<MapEntry<String, String>>(),
      ]);

      final metadata = root.getElement(_metadataElement);
      final metadataDir = Map.fromEntries([
        if (metadata != null) MapEntry('Metadata', metadata.toXmlString(pretty: true)),
      ]);

      return {
        if (docDir.isNotEmpty) docDirectory: docDir,
        if (metadataDir.isNotEmpty) metadataDirectory: metadataDir,
      };
    } catch (error, stack) {
      debugPrint('failed to parse XML from SVG with error=$error\n$stack');
    }
    return {};
  }
}
