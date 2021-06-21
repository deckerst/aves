import 'package:aves/widgets/viewer/visual/subtitle/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class StyledSubtitleSpan with Diagnosticable {
  final TextSpan textSpan;
  final SubtitleStyle extraStyle;

  const StyledSubtitleSpan({
    required this.textSpan,
    required this.extraStyle,
  });

  StyledSubtitleSpan copyWith({
    TextSpan? textSpan,
    SubtitleStyle? extraStyle,
  }) {
    return StyledSubtitleSpan(
      textSpan: textSpan ?? this.textSpan,
      extraStyle: extraStyle ?? this.extraStyle,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextSpan>('textSpan', textSpan));
    properties.add(DiagnosticsProperty<SubtitleStyle>('extraStyle', extraStyle));
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is StyledSubtitleSpan && other.textSpan == textSpan && other.extraStyle == extraStyle;
  }

  @override
  int get hashCode => hashValues(
        textSpan,
        extraStyle,
      );
}
