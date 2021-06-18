import 'package:aves/widgets/viewer/visual/subtitle/style.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class AssParser {
  static final tagPattern = RegExp(r'('
      r'1a|2a|3a|4a'
      r'|1c|2c|3c|4c'
      r'|alpha|an|a'
      r'|be|blur|bord|b'
      r'|clip|c'
      r'|fade|fad|fax|fay|fe|fn'
      r'|frx|fry|frz|fr|fscx|fscy|fsp|fs'
      r'|iclip|i'
      r'|kf|ko|k|K'
      r'|move|org'
      r'|pbo|pos|p'
      r'|q|r'
      r'|shad|s'
      r'|t|u'
      r'|xbord|xshad|ybord|yshad'
      r')');

  // &H<aa>
  static final alphaPattern = RegExp('&H(..)');

  // &H<bb><gg><rr>&
  static final colorPattern = RegExp('&H(..)(..)(..)&');

  static const noBreakSpace = '\u00A0';

  // TODO TLAD [video] process ASS tags, cf https://aegi.vmoe.info/docs/3.0/ASS_Tags/
  // e.g. `And I'm like, "We can't {\i1}not{\i0} see it."`
  // e.g. `{\fad(200,200)\blur3}lorem ipsum"`
  // e.g. `{\fnCrapFLTSB\an9\bord5\fs70\c&H403A2D&\3c&HE5E5E8&\pos(1868.286,27.429)}lorem ipsum"`
  static List<Tuple2<TextSpan, SubtitleExtraStyle>> parseAss(String text, TextStyle baseStyle, double scale) {
    final spans = <Tuple2<TextSpan, SubtitleExtraStyle>>[];
    var extraStyle = const SubtitleExtraStyle();
    var textStyle = baseStyle;
    var i = 0;
    final matches = RegExp(r'{(.*?)}').allMatches(text);
    matches.forEach((m) {
      if (i != m.start) {
        spans.add(Tuple2(
          TextSpan(
            text: _replaceChars(text.substring(i, m.start)),
            style: textStyle,
          ),
          extraStyle,
        ));
      }
      i = m.end;
      final tags = m.group(1);
      tags?.split('\\').where((v) => v.isNotEmpty).forEach((tagWithParam) {
        final tag = tagPattern.firstMatch(tagWithParam)?.group(1);
        if (tag != null) {
          final param = tagWithParam.substring(tag.length);
          switch (tag) {
            case 'r':
              {
                // \r: reset
                textStyle = baseStyle;
                break;
              }
            case 'alpha':
              {
                // \alpha: alpha of all components at once
                final a = _parseAlpha(param);
                if (a != null) {
                  textStyle = textStyle.copyWith(
                      color: textStyle.color?.withAlpha(a),
                      shadows: textStyle.shadows
                          ?.map((v) => Shadow(
                                color: v.color.withAlpha(a),
                                offset: v.offset,
                                blurRadius: v.blurRadius,
                              ))
                          .toList());
                }
                break;
              }
            case 'an':
              {
                // \an: alignment
                var hAlign = TextAlign.center;
                var vAlign = TextAlignVertical.bottom;
                final alignment = _parseAlignment(param);
                if (alignment != null) {
                  if (alignment.x < 0) {
                    hAlign = TextAlign.left;
                  } else if (alignment.x > 0) {
                    hAlign = TextAlign.right;
                  }
                  if (alignment.y < 0) {
                    vAlign = TextAlignVertical.top;
                  } else if (alignment.y == 0) {
                    vAlign = TextAlignVertical.center;
                  }
                  extraStyle = extraStyle.copyWith(
                    hAlign: hAlign,
                    vAlign: vAlign,
                  );
                }
                break;
              }
            case 'b':
              {
                // \b: bold
                textStyle = textStyle.copyWith(fontWeight: param == '1' ? FontWeight.bold : FontWeight.normal);
                break;
              }
            case 'blur':
              {
                // \blur: blurs the edges of the text
                final strength = double.tryParse(param);
                if (strength != null) extraStyle = extraStyle.copyWith(edgeBlur: strength);
                break;
              }
            case 'bord':
              {
                // \bord: border width
                final size = double.tryParse(param);
                if (size != null) extraStyle = extraStyle.copyWith(borderWidth: size);
                break;
              }
            case 'c':
            case '1c':
              {
                // \c or \1c: fill color
                final color = _parseColor(param);
                if (color != null) {
                  textStyle = textStyle.copyWith(color: color.withAlpha(textStyle.color?.alpha ?? 0xFF));
                }
                break;
              }
            case '3c':
              {
                // \3c: border color
                final color = _parseColor(param);
                if (color != null) {
                  extraStyle = extraStyle.copyWith(
                    borderColor: color.withAlpha(extraStyle.borderColor?.alpha ?? 0xFF),
                  );
                }
                break;
              }
            case '4c':
              {
                // \4c: shadow color
                final color = _parseColor(param);
                if (color != null) {
                  textStyle = textStyle.copyWith(
                      shadows: textStyle.shadows
                          ?.map((v) => Shadow(
                                color: color.withAlpha(v.color.alpha),
                                offset: v.offset,
                                blurRadius: v.blurRadius,
                              ))
                          .toList());
                }
                break;
              }
            case 'fax':
              {
                final factor = double.tryParse(param);
                if (factor != null) extraStyle = extraStyle.copyWith(shearX: factor);
                break;
              }
            case 'fay':
              {
                final factor = double.tryParse(param);
                if (factor != null) extraStyle = extraStyle.copyWith(shearY: factor);
                break;
              }
            case 'fn':
              {
                final name = param;
                // TODO TLAD [video] extract fonts from attachment streams, and load these fonts in Flutter
                if (name.isNotEmpty) textStyle = textStyle.copyWith(fontFamily: name);
                break;
              }
            case 'fs':
              {
                final size = int.tryParse(param);
                if (size != null) textStyle = textStyle.copyWith(fontSize: size * scale);
                break;
              }
            case 'frx':
              {
                final amount = double.tryParse(param);
                if (amount != null) extraStyle = extraStyle.copyWith(rotationX: amount);
                break;
              }
            case 'fry':
              {
                final amount = double.tryParse(param);
                if (amount != null) extraStyle = extraStyle.copyWith(rotationY: amount);
                break;
              }
            case 'fr':
            case 'frz':
              {
                final amount = double.tryParse(param);
                if (amount != null) extraStyle = extraStyle.copyWith(rotationZ: amount);
                break;
              }
            case 'fscx':
              {
                final scale = int.tryParse(param);
                if (scale != null) extraStyle = extraStyle.copyWith(scaleX: scale.toDouble() / 100);
                break;
              }
            case 'fscy':
              {
                final scale = int.tryParse(param);
                if (scale != null) extraStyle = extraStyle.copyWith(scaleY: scale.toDouble() / 100);
                break;
              }
            case 'i':
              {
                // \i: italics
                textStyle = textStyle.copyWith(fontStyle: param == '1' ? FontStyle.italic : FontStyle.normal);
                break;
              }
            default:
              debugPrint('unhandled ASS tag=$tag');
          }
        }
      });
    });
    if (i != text.length) {
      spans.add(Tuple2(
        TextSpan(
          text: _replaceChars(text.substring(i, text.length)),
          style: textStyle,
        ),
        extraStyle,
      ));
    }
    return spans;
  }

  static String _replaceChars(String text) => text.replaceAll(r'\h', noBreakSpace).replaceAll(r'\N', '\n');

  static Alignment? _parseAlignment(String param) {
    switch (int.tryParse(param)) {
      case 1:
        return Alignment.bottomLeft;
      case 2:
        return Alignment.bottomCenter;
      case 3:
        return Alignment.bottomRight;
      case 4:
        return Alignment.centerLeft;
      case 5:
        return Alignment.center;
      case 6:
        return Alignment.centerRight;
      case 7:
        return Alignment.topLeft;
      case 8:
        return Alignment.topCenter;
      case 9:
        return Alignment.topRight;
      default:
        return null;
    }
  }

  static int? _parseAlpha(String param) {
    final match = alphaPattern.firstMatch(param);
    if (match != null) {
      final as = match.group(1);
      final ai = int.tryParse('$as', radix: 16);
      if (ai != null) {
        return 0xFF - ai;
      }
    }
    return null;
  }

  static Color? _parseColor(String param) {
    final match = colorPattern.firstMatch(param);
    if (match != null) {
      final bs = match.group(1);
      final gs = match.group(2);
      final rs = match.group(3);
      final rgb = int.tryParse('ff$rs$gs$bs', radix: 16);
      if (rgb != null) {
        return Color(rgb);
      }
    }
    return null;
  }
}
