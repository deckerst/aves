import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

// because `toString` outputs `Instance of `Foo`` and is unusable in non-debug mode
String toStringDebug(Object? o) {
  if (o == null) return 'null';

  if (o is Diagnosticable) return _stringifyDiagnosticable(o);

  if (o is Alignment) return _stringifyAlignment(o);
  if (o is BorderRadius) return _stringifyBorderRadius(o);
  if (o is EdgeInsets) return _stringifyEdgeInsets(o);
  if (o is Offset) return _stringifyOffset(o);
  if (o is Radius) return _stringifyRadius(o);

  return o.toString();
}

String _stringifyDiagnosticable(Diagnosticable o) {
  return o.toDiagnosticsNode(style: DiagnosticsTreeStyle.singleLine).toString(minLevel: .info);
}

String _stringifyAlignment(Alignment o) {
  final x = o.x;
  final y = o.y;
  return switch ((x, y)) {
    (-1.0, -1.0) => 'Alignment.topLeft',
    (0.0, -1.0) => 'Alignment.topCenter',
    (1.0, -1.0) => 'Alignment.topRight',
    (-1.0, 0.0) => 'Alignment.centerLeft',
    (0.0, 0.0) => 'Alignment.center',
    (1.0, 0.0) => 'Alignment.centerRight',
    (-1.0, 1.0) => 'Alignment.bottomLeft',
    (0.0, 1.0) => 'Alignment.bottomCenter',
    (1.0, 1.0) => 'Alignment.bottomRight',
    _ => 'Alignment(${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)})',
  };
}

String _stringifyBorderRadius(BorderRadius o) {
  final tl = o.topLeft;
  final tr = o.topRight;
  final bl = o.bottomLeft;
  final br = o.bottomRight;
  if (tl == tr && tr == bl && bl == br) {
    return 'BorderRadius(${_stringifyRadius(tl)})';
  }
  return 'BorderRadius('
      'topLeft=${_stringifyRadius(tl)}, '
      'topRight=${_stringifyRadius(tr)}, '
      'bottomLeft=${_stringifyRadius(bl)}, '
      'bottomRight=${_stringifyRadius(br)})';
}

String _stringifyEdgeInsets(EdgeInsets o) {
  return 'EdgeInsets('
      '${o.left.toStringAsFixed(1)}, '
      '${o.top.toStringAsFixed(1)}, '
      '${o.right.toStringAsFixed(1)}, '
      '${o.bottom.toStringAsFixed(1)})';
}

String _stringifyOffset(Offset o) {
  return 'Offset(${o.dx.toStringAsFixed(1)}, ${o.dy.toStringAsFixed(1)})';
}

String _stringifyRadius(Radius o) {
  final x = o.x;
  final y = o.y;
  if (x == y) return x.toStringAsFixed(1);
  return 'Radius('
      '${x.toStringAsFixed(1)}, '
      '${y.toStringAsFixed(1)})';
}
