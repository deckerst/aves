import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

extension ExtraStyleReader on StyleReader {
  Future<Style> readExtra({required bool skipSources}) async {
    final styleJsonString = await _httpGet(uri);
    final styleJsonDecoded = await compute(jsonDecode, styleJsonString);
    if (styleJsonDecoded is! Map) {
      throw _invalidStyle(uri);
    }

    final styleMap = styleJsonDecoded.cast<String, Object?>();
    final sources = (styleMap['sources'] as Map).cast<String, Object?>();
    final Map<String, VectorTileProvider> providerByName = skipSources ? {} : await readProviderByName(sources);
    final name = styleMap['name'] as String?;

    final center = styleMap['center'];
    LatLng? centerPoint;
    if (center is List && center.length == 2) {
      centerPoint = LatLng((center[1] as num).toDouble(), (center[0] as num).toDouble());
    }

    double? zoom = (styleMap['zoom'] as num?)?.toDouble();
    if (zoom != null && zoom < 2) {
      zoom = null;
      centerPoint = null;
    }

    final spriteUri = styleMap['sprite'];
    SpriteStyle? sprites;
    if (spriteUri is String && spriteUri.trim().isNotEmpty) {
      final spriteUris = [
        _SpriteUri(json: '$spriteUri@2x.json?secure', image: '$spriteUri@2x.png?secure'),
        _SpriteUri(json: '$spriteUri.json?secure', image: '$spriteUri.png?secure'),
      ];
      for (final spriteUri in spriteUris) {
        try {
          final spritesJsonString = await _httpGet(spriteUri.json);
          final spritesJsonDecoded = await compute(jsonDecode, spritesJsonString);
          if (spritesJsonDecoded is! Map) continue;

          final spritesMap = spritesJsonDecoded.cast<String, Object?>();
          sprites = SpriteStyle(
            atlasProvider: () => _loadBinary(spriteUri.image),
            index: SpriteIndexReader(logger: logger).read(spritesMap),
          );
        } catch (e) {
          logger.log(() => 'error reading sprite uri: ${spriteUri.json}');
        }
        break;
      }
    }
    return Style(
      theme: ThemeReader(logger: logger).read(styleMap),
      providers: TileProviders(providerByName),
      sprites: sprites,
      name: name,
      center: centerPoint,
      zoom: zoom,
    );
  }

  static Future<Map<String, VectorTileProvider>> readProviderByName(Map<String, Object?> sources) async {
    final providers = <String, VectorTileProvider>{};
    final sourceEntries = sources.entries.toList();
    for (final sourceEntry in sourceEntries) {
      var source = sourceEntry.value;
      if (source is! Map) continue;

      final sourceType = source['type'] as String?;
      final sourceUrl = source['url'] as String?;

      final type = TileProviderType.values.where((e) => e.name == sourceType).firstOrNull;
      if (type == null) continue;

      if (sourceUrl != null) {
        final sourceJsonString = await _httpGet(sourceUrl);
        final sourceDecoded = await compute(jsonDecode, sourceJsonString);
        if (sourceDecoded is! Map) {
          throw _invalidStyle(sourceUrl);
        }
        source = sourceDecoded;
      }

      final sourceTiles = source['tiles'] as List? ?? [];
      if (sourceTiles.isNotEmpty) {
        providers[sourceEntry.key] = NetworkVectorTileProvider(
          type: type,
          urlTemplate: sourceTiles[0] as String,
          maximumZoom: source['maxzoom'] as int? ?? 14,
          minimumZoom: source['minzoom'] as int? ?? 1,
        );
      }
    }
    if (providers.isEmpty) {
      throw 'Unexpected response';
    }
    return providers;
  }

  static String _invalidStyle(String url) => 'Uri does not appear to be a valid style: $url';

  static Future<String> _httpGet(String url) async {
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw 'HTTP ${response.statusCode}: ${response.body}';
    }
  }

  static Future<Uint8List> _loadBinary(String url) async {
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw 'HTTP ${response.statusCode}: ${response.body}';
    }
  }
}

class _SpriteUri {
  final String json;
  final String image;

  const _SpriteUri({required this.json, required this.image});
}
