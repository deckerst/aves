import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

extension StyleReaderExtra on StyleReader {
  Future<Style> readExtra({required Set<String> skippedSources}) async {
    final styleText = await _httpGet(uri);
    final style = await compute(jsonDecode, styleText);
    if (style is! Map<String, dynamic>) {
      throw _invalidStyle(uri);
    }
    final sources = style['sources'] as Map<String, dynamic>;
    final providerByName = await _readProviderByName(Map.fromEntries(sources.entries.where((kv) => !skippedSources.contains(kv.key))));
    final name = style['name'] as String?;

    final center = style['center'];
    LatLng? centerPoint;
    if (center is List && center.length == 2) {
      centerPoint = LatLng((center[1] as num).toDouble(), (center[0] as num).toDouble());
    }

    double? zoom = (style['zoom'] as num?)?.toDouble();
    if (zoom != null && zoom < 2) {
      zoom = null;
      centerPoint = null;
    }

    final spriteUri = style['sprite'];
    SpriteStyle? sprites;
    if (spriteUri is String && spriteUri.trim().isNotEmpty) {
      final spriteUris = [
        _SpriteUri(json: '$spriteUri@2x.json?secure', image: '$spriteUri@2x.png?secure'),
        _SpriteUri(json: '$spriteUri.json?secure', image: '$spriteUri.png?secure'),
      ];
      for (final spriteUri in spriteUris) {
        dynamic spritesJson;
        try {
          final spritesJsonText = await _httpGet(spriteUri.json);
          spritesJson = await compute(jsonDecode, spritesJsonText);
        } catch (e) {
          logger.log(() => 'error reading sprite uri: ${spriteUri.json}');
          continue;
        }
        sprites = SpriteStyle(atlasProvider: () => _loadBinary(spriteUri.image), index: SpriteIndexReader(logger: logger).read(spritesJson));
        break;
      }
    }
    return Style(theme: ThemeReader(logger: logger).read(style), providers: TileProviders(providerByName), sprites: sprites, name: name, center: centerPoint, zoom: zoom);
  }

  Future<Map<String, VectorTileProvider>> _readProviderByName(Map<String, dynamic> sources) async {
    final providers = <String, VectorTileProvider>{};
    final sourceEntries = sources.entries.toList();
    for (final entry in sourceEntries) {
      final type = TileProviderType.values.where((e) => e.name == entry.value['type']).firstOrNull;
      if (type == null) continue;
      dynamic source;
      var entryUrl = entry.value['url'] as String?;
      if (entryUrl != null) {
        final sourceUrl = entryUrl;
        source = await compute(jsonDecode, await _httpGet(sourceUrl));
        if (source is! Map) {
          throw _invalidStyle(sourceUrl);
        }
      } else {
        source = entry.value;
      }
      final entryTiles = source['tiles'];
      final maxzoom = source['maxzoom'] as int? ?? 14;
      final minzoom = source['minzoom'] as int? ?? 1;
      if (entryTiles is List && entryTiles.isNotEmpty) {
        final tileUri = entryTiles[0] as String;
        final tileUrl = tileUri;
        providers[entry.key] = NetworkVectorTileProvider(type: type, urlTemplate: tileUrl, maximumZoom: maxzoom, minimumZoom: minzoom);
      }
    }
    if (providers.isEmpty) {
      throw 'Unexpected response';
    }
    return providers;
  }

  String _invalidStyle(String url) => 'Uri does not appear to be a valid style: $url';

  Future<String> _httpGet(String url) async {
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw 'HTTP ${response.statusCode}: ${response.body}';
    }
  }

  Future<Uint8List> _loadBinary(String url) async {
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
