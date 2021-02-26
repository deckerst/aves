import 'package:aves/geo/topojson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const example1 = '''
{
  "type": "Topology",
  "objects": {
    "example": {
      "type": "GeometryCollection",
      "geometries": [
        {
          "type": "Point",
          "properties": {
            "prop0": "value0"
          },
          "coordinates": [102, 0.5]
        },
        {
          "type": "LineString",
          "properties": {
            "prop0": "value0",
            "prop1": 0
          },
          "arcs": [0]
        },
        {
          "type": "Polygon",
          "properties": {
            "prop0": "value0",
            "prop1": {
              "this": "that"
            }
          },
          "arcs": [[-2]]
        }
      ]
    }
  },
  "arcs": [
    [[102, 0], [103, 1], [104, 0], [105, 1]],
    [[100, 0], [101, 0], [101, 1], [100, 1], [100, 0]]
  ]
}
''';

  const example1Quantized = '''
{
  "type": "Topology",
  "transform": {
    "scale": [0.0005000500050005, 0.00010001000100010001],
    "translate": [100, 0]
  },
  "objects": {
    "example": {
      "type": "GeometryCollection",
      "geometries": [
        {
          "type": "Point",
          "properties": {
            "prop0": "value0"
          },
          "coordinates": [4000, 5000]
        },
        {
          "type": "LineString",
          "properties": {
            "prop0": "value0",
            "prop1": 0
          },
          "arcs": [0]
        },
        {
          "type": "Polygon",
          "properties": {
            "prop0": "value0",
            "prop1": {
              "this": "that"
            }
          },
          "arcs": [[1]]
        }
      ]
    }
  },
  "arcs": [
    [[4000, 0], [1999, 9999], [2000, -9999], [2000, 9999]],
    [[0, 0], [0, 9999], [2000, 0], [0, -9999], [-2000, 0]]
  ]
}
''';

  test('parse example', () async {
    final topo = await TopoJson().parse(example1);
    expect(topo.objects.containsKey('example'), true);

    final exampleObj = topo.objects['example'] as GeometryCollection;
    expect(exampleObj.geometries.length, 3);

    final point = exampleObj.geometries[0] as Point;
    expect(point.coordinates, [102, 0.5]);

    final lineString = exampleObj.geometries[1] as LineString;
    expect(lineString.arcs, [0]);

    final polygon = exampleObj.geometries[2] as Polygon;
    expect(polygon.arcs.first, [-2]);
    expect(polygon.properties.containsKey('prop0'), true);
  });

  test('parse quantized example', () async {
    final topo = await TopoJson().parse(example1Quantized);
    expect(topo.arcs.first.first, [4000, 0]);
    expect(topo.transform.scale, [0.0005000500050005, 0.00010001000100010001]);
  });
}
