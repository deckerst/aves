import 'package:aves/widgets/viewer/visual/subtitle/span.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class StyledSubtitleLine with Diagnosticable {
  final List<StyledSubtitleSpan> spans;
  final List<Path>? clip;
  final Offset? position;

  const StyledSubtitleLine({
    required this.spans,
    this.clip,
    this.position,
  });

  StyledSubtitleLine copyWith({
    List<StyledSubtitleSpan>? spans,
    List<Path>? clip,
    Offset? position,
  }) {
    return StyledSubtitleLine(
      spans: spans ?? this.spans,
      clip: clip ?? this.clip,
      position: position ?? this.position,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<List<StyledSubtitleSpan>>('spans', spans));
    properties.add(DiagnosticsProperty<List<Path>>('clip', clip));
    properties.add(DiagnosticsProperty<Offset>('position', position));
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is StyledSubtitleLine && other.spans == spans && other.clip == clip && other.position == position;
  }

  @override
  int get hashCode => hashValues(
        spans,
        clip,
        position,
      );
}
