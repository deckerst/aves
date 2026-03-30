import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

// cf https://github.com/topojson/topojson-specification
class TopoJson {
  Future<Topology?> parse(String jsonString) async {
    try {
      return Isolate.run<Topology>(() {
        final jsonMap = jsonDecode(jsonString) as Map<String, Object?>;
        return Topology.parse(jsonMap);
      });
    } catch (error, stack) {
      debugPrint('failed to parse TopoJSON with error=$error\n$stack');
      return null;
    }
  }
}

enum TopoJsonObjectType { topology, point, multipoint, linestring, multilinestring, polygon, multipolygon, geometrycollection }

TopoJsonObjectType? _parseTopoJsonObjectType(String? data) {
  switch (data) {
    case 'Topology':
      return TopoJsonObjectType.topology;
    case 'Point':
      return TopoJsonObjectType.point;
    case 'MultiPoint':
      return TopoJsonObjectType.multipoint;
    case 'LineString':
      return TopoJsonObjectType.linestring;
    case 'MultiLineString':
      return TopoJsonObjectType.multilinestring;
    case 'Polygon':
      return TopoJsonObjectType.polygon;
    case 'MultiPolygon':
      return TopoJsonObjectType.multipolygon;
    case 'GeometryCollection':
      return TopoJsonObjectType.geometrycollection;
  }
  return null;
}

class TopologyJsonObject {
  final List<num>? bbox;

  TopologyJsonObject.parse(Map<String, Object?> data) : bbox = data.containsKey('bbox') ? (data['bbox'] as List).cast<num>().toList() : null;
}

class Topology extends TopologyJsonObject {
  final Map<String, Geometry> objects;
  final List<List<List<num>>> arcs;
  final Transform? transform;

  Topology.parse(super.data)
    : objects = Map.fromEntries(
        (data['objects'] as Map).cast<String, Object?>().entries.map((kv) {
          final name = kv.key;
          final geometryData = kv.value;
          if (geometryData is! Map) return null;

          final geometry = Geometry.build(geometryData.cast<String, Object?>());
          if (geometry == null) return null;

          return MapEntry(name, geometry);
        }).nonNulls,
      ),
      arcs = (data['arcs'] as List).cast<List>().map((arc) => arc.cast<List>().map((position) => position.cast<num>()).toList()).toList(),
      transform = data.containsKey('transform') ? Transform.parse((data['transform'] as Map).cast<String, Object?>()) : null,
      super.parse();

  List<List<num>> _arcAt(int index) {
    var arc = arcs[index < 0 ? ~index : index];

    if (transform != null) {
      var x = 0, y = 0;
      arc = arc.map((quantized) {
        final absolute = List.of(quantized);
        absolute[0] = (x += quantized[0] as int) * transform!.scale[0] + transform!.translate[0];
        absolute[1] = (y += quantized[1] as int) * transform!.scale[1] + transform!.translate[1];
        return absolute;
      }).toList();
    }

    return index < 0 ? arc.reversed.toList() : arc;
  }

  List<List<num>> _toLine(List<List<List<num>>> arcs) {
    return arcs.fold(<List<num>>[], (prev, arc) => [...prev, ...prev.isEmpty ? arc : arc.skip(1)]);
  }

  List<List<num>> _decodeRingArcs(List<int> ringArcs) {
    return _toLine(ringArcs.map(_arcAt).toList());
  }

  List<List<List<num>>> _decodePolygonArcs(List<List<int>> polyArcs) {
    return polyArcs.map(_decodeRingArcs).toList();
  }

  List<List<List<List<num>>>> _decodeMultiPolygonArcs(List<List<List<int>>> multiPolyArcs) {
    return multiPolyArcs.map(_decodePolygonArcs).toList();
  }

  // cf https://en.wikipedia.org/wiki/Even%E2%80%93odd_rule
  bool _pointInRing(List<num> point, List<List<num>> poly) {
    final x = point[0];
    final y = point[1];
    final length = poly.length;
    var j = length - 1;
    var c = false;
    for (var i = 0; i < length; i++) {
      if (((poly[i][1] > y) != (poly[j][1] > y)) && (x < poly[i][0] + (poly[j][0] - poly[i][0]) * (y - poly[i][1]) / (poly[j][1] - poly[i][1]))) {
        c = !c;
      }
      j = i;
    }
    return c;
  }

  bool _pointInRings(List<num> point, List<List<List<num>>> rings) {
    return rings.any((ring) => _pointInRing(point, ring));
  }
}

class Transform {
  final List<num> scale;
  final List<num> translate;

  Transform.parse(Map<String, Object?> data) : scale = (data['scale'] as List).cast<num>(), translate = (data['translate'] as List).cast<num>();
}

abstract class Geometry extends TopologyJsonObject {
  final Object? id;
  final Map<String, Object?>? properties;

  Geometry.parse(super.data) : id = data.containsKey('id') ? data['id'] : null, properties = data.containsKey('properties') ? data['properties'] as Map<String, Object?>? : null, super.parse();

  static Geometry? build(Map<String, Object?> data) {
    final type = _parseTopoJsonObjectType(data['type'] as String?);
    switch (type) {
      case .topology:
      case null:
        return null;
      case .point:
        return Point.parse(data);
      case .multipoint:
        return MultiPoint.parse(data);
      case .linestring:
        return LineString.parse(data);
      case .multilinestring:
        return MultiLineString.parse(data);
      case .polygon:
        return Polygon.parse(data);
      case .multipolygon:
        return MultiPolygon.parse(data);
      case .geometrycollection:
        return GeometryCollection.parse(data);
    }
  }

  bool containsPoint(Topology topology, List<num> point) => false;
}

class Point extends Geometry {
  final List<num> coordinates;

  Point.parse(super.data) : coordinates = (data['coordinates'] as List).cast<num>(), super.parse();
}

class MultiPoint extends Geometry {
  final List<List<num>> coordinates;

  MultiPoint.parse(super.data) : coordinates = (data['coordinates'] as List).cast<List>().map((position) => position.cast<num>()).toList(), super.parse();
}

class LineString extends Geometry {
  final List<int> arcs;

  LineString.parse(super.data) : arcs = (data['arcs'] as List).cast<int>(), super.parse();
}

class MultiLineString extends Geometry {
  final List<List<int>> arcs;

  MultiLineString.parse(super.data) : arcs = (data['arcs'] as List).cast<List>().map((arc) => arc.cast<int>()).toList(), super.parse();
}

class Polygon extends Geometry {
  final List<List<int>> arcs;

  Polygon.parse(super.data) : arcs = (data['arcs'] as List).cast<List>().map((arc) => arc.cast<int>()).toList(), super.parse();

  List<List<List<num>>>? _rings;

  List<List<List<num>>> rings(Topology topology) {
    _rings ??= topology._decodePolygonArcs(arcs);
    return _rings!;
  }

  @override
  bool containsPoint(Topology topology, List<num> point) {
    return topology._pointInRings(point, rings(topology));
  }
}

class MultiPolygon extends Geometry {
  final List<List<List<int>>> arcs;

  MultiPolygon.parse(super.data) : arcs = (data['arcs'] as List).cast<List>().map((polygon) => polygon.cast<List>().map((arc) => arc.cast<int>()).toList()).toList(), super.parse();

  List<List<List<List<num>>>>? _polygons;

  List<List<List<List<num>>>> polygons(Topology topology) {
    _polygons ??= topology._decodeMultiPolygonArcs(arcs);
    return _polygons!;
  }

  @override
  bool containsPoint(Topology topology, List<num> point) {
    return polygons(topology).any((polygon) => topology._pointInRings(point, polygon));
  }
}

class GeometryCollection extends Geometry {
  final List<Geometry> geometries;

  GeometryCollection.parse(super.data) : geometries = (data['geometries'] as List).cast<Map<String, Object?>>().map(Geometry.build).nonNulls.toList(), super.parse();

  @override
  bool containsPoint(Topology topology, List<num> point) {
    return geometries.any((geometry) => geometry.containsPoint(topology, point));
  }
}
