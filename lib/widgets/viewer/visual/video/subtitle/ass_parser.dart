import 'package:aves/ref/unicode.dart';
import 'package:aves/widgets/viewer/visual/video/subtitle/line.dart';
import 'package:aves/widgets/viewer/visual/video/subtitle/span.dart';
import 'package:aves/widgets/viewer/visual/video/subtitle/style.dart';
import 'package:flutter/material.dart';

class AssParser {
  // the optional `*` before the tags seems to be used for inner overrides
  // but specs for its usage are yet to be found
  static final overridePattern = RegExp(r'{\*?(.*?)}');

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

  // (<X>,<Y>)
  static final multiParamPattern = RegExp('\\((.*)\\)');

  // e.g. m 937.5 472.67 b 937.5 472.67 937.25 501.25 960 501.5 960 501.5 937.5 500.33 937.5 529.83
  static final pathPattern = RegExp(r'([mnlbspc])([.\s\d]+)');

  // Parse text with ASS style overrides
  // cf https://aegi.vmoe.info/docs/3.0/ASS_Tags/
  // e.g. `And I'm like, "We can't {\i1}not{\i0} see it."`
  // e.g. `{\fad(200,200)\blur3}lorem ipsum"`
  // e.g. `{\fnCrapFLTSB\an9\bord5\fs70\c&H403A2D&\3c&HE5E5E8&\pos(1868.286,27.429)}lorem ipsum"`
  static StyledSubtitleLine parse(String text, TextStyle baseStyle, double scale) {
    final spans = <StyledSubtitleSpan>[];
    var line = StyledSubtitleLine(spans: spans);
    var extraStyle = const SubtitleStyle();
    var textStyle = baseStyle;
    var i = 0;
    final overrideMatches = overridePattern.allMatches(text);
    overrideMatches.forEach((overrideMatch) {
      if (i != overrideMatch.start) {
        final spanText = extraStyle.drawingPaths?.isNotEmpty == true ? null : _replaceChars(text.substring(i, overrideMatch.start));
        spans.add(StyledSubtitleSpan(
          textSpan: TextSpan(
            text: spanText,
            style: textStyle,
          ),
          extraStyle: extraStyle,
        ));
      }
      i = overrideMatch.end;
      final tags = overrideMatch.group(1);
      tags?.split('\\').where((v) => v.isNotEmpty).forEach((tagWithParam) {
        final tag = tagPattern.firstMatch(tagWithParam)?.group(1);
        if (tag != null) {
          final param = tagWithParam.substring(tag.length);
          switch (tag) {
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
                  extraStyle = extraStyle.copyWith(
                    borderColor: extraStyle.borderColor?.withAlpha(a),
                  );
                }
              }
            case '1a':
              {
                // \1a: fill alpha
                final a = _parseAlpha(param);
                if (a != null) textStyle = textStyle.copyWith(color: textStyle.color?.withAlpha(a));
              }
            case '3a':
              {
                // \3a: border alpha
                final a = _parseAlpha(param);
                if (a != null) extraStyle = extraStyle.copyWith(borderColor: extraStyle.borderColor?.withAlpha(a));
              }
            case '4a':
              {
                // \4a: shadow alpha
                final a = _parseAlpha(param);
                if (a != null) {
                  textStyle = textStyle.copyWith(
                      shadows: textStyle.shadows
                          ?.map((v) => Shadow(
                                color: v.color.withAlpha(a),
                                offset: v.offset,
                                blurRadius: v.blurRadius,
                              ))
                          .toList());
                }
              }
            case 'a':
              // \a: line alignment (legacy)
              extraStyle = _copyWithAlignment(_parseLegacyAlignment(param), extraStyle);
            case 'an':
              // \an: line alignment
              extraStyle = _copyWithAlignment(_parseNewAlignment(param), extraStyle);
            case 'b':
              {
                // \b: bold
                final weight = _parseFontWeight(param);
                if (weight != null) textStyle = textStyle.copyWith(fontWeight: weight);
              }
            case 'be':
              {
                // \be: blurs the edges of the text
                final times = int.tryParse(param);
                if (times != null) extraStyle = extraStyle.copyWith(edgeBlur: times == 0 ? 0 : 1);
              }
            case 'blur':
              {
                // \blur: blurs the edges of the text (Gaussian kernel)
                final strength = double.tryParse(param);
                if (strength != null) extraStyle = extraStyle.copyWith(edgeBlur: strength / 2);
              }
            case 'bord':
              {
                // \bord: border width
                final size = double.tryParse(param);
                if (size != null) extraStyle = extraStyle.copyWith(borderWidth: size);
              }
            case 'c':
            case '1c':
              {
                // \c or \1c: fill color
                final color = _parseColor(param);
                if (color != null) {
                  textStyle = textStyle.copyWith(color: color.withValues(alpha: textStyle.color?.a ?? 1));
                }
              }
            case '3c':
              {
                // \3c: border color
                final color = _parseColor(param);
                if (color != null) {
                  extraStyle = extraStyle.copyWith(
                    borderColor: color.withValues(alpha: extraStyle.borderColor?.a ?? 1),
                  );
                }
              }
            case '4c':
              {
                // \4c: shadow color
                final color = _parseColor(param);
                if (color != null) {
                  textStyle = textStyle.copyWith(
                      shadows: textStyle.shadows
                          ?.map((v) => Shadow(
                                color: color.withValues(alpha: v.color.a),
                                offset: v.offset,
                                blurRadius: v.blurRadius,
                              ))
                          .toList());
                }
              }
            case 'clip':
              // \clip: clip (within rectangle or path)
              line = line.copyWith(clip: _parseClip(param));
            case 'fax':
              {
                final factor = double.tryParse(param);
                // ignore subsequent shearing when line is positioned
                if (factor != null && (line.position == null || extraStyle.shearX == null)) {
                  extraStyle = extraStyle.copyWith(shearX: factor);
                }
              }
            case 'fay':
              {
                final factor = double.tryParse(param);
                // ignore subsequent shearing when line is positioned
                if (factor != null && (line.position == null || extraStyle.shearY == null)) {
                  extraStyle = extraStyle.copyWith(shearY: factor);
                }
              }
            case 'fn':
              {
                final name = param;
                // TODO TLAD [subtitles] extract fonts from attachment streams, and load these fonts in Flutter
                if (name.isNotEmpty) textStyle = textStyle.copyWith(fontFamily: name);
              }
            case 'frx':
              {
                // \frx: text rotation (X axis)
                final amount = double.tryParse(param);
                if (amount != null) extraStyle = extraStyle.copyWith(rotationX: amount);
              }
            case 'fry':
              {
                // \fry: text rotation (Y axis)
                final amount = double.tryParse(param);
                if (amount != null) extraStyle = extraStyle.copyWith(rotationY: amount);
              }
            case 'fr':
            case 'frz':
              {
                // \frz: text rotation (Z axis)
                final amount = double.tryParse(param);
                if (amount != null) extraStyle = extraStyle.copyWith(rotationZ: amount);
              }
            case 'fs':
              {
                // \fs: font size
                final size = int.tryParse(param);
                if (size != null) textStyle = textStyle.copyWith(fontSize: size * scale);
              }
            case 'fscx':
              {
                // \fscx: font scale (horizontal)
                final scale = int.tryParse(param);
                if (scale != null) extraStyle = extraStyle.copyWith(scaleX: scale.toDouble() / 100);
              }
            case 'fscy':
              {
                // \fscx: font scale (vertical)
                final scale = int.tryParse(param);
                if (scale != null) extraStyle = extraStyle.copyWith(scaleY: scale.toDouble() / 100);
              }
            case 'fsp':
              {
                // \fsp: letter spacing
                final spacing = double.tryParse(param);
                textStyle = textStyle.copyWith(letterSpacing: spacing);
              }
            case 'i':
              // \i: italics
              textStyle = textStyle.copyWith(fontStyle: param == '1' ? FontStyle.italic : FontStyle.normal);
            case 'p':
              {
                // \p drawing paths
                final scale = int.tryParse(param);
                if (scale != null) {
                  if (scale > 0) {
                    final start = overrideMatch.end;
                    final end = text.indexOf('{', start);
                    final commands = text.substring(start, end == -1 ? null : end);
                    extraStyle = extraStyle.copyWith(drawingPaths: _parsePaths(commands, scale));
                  } else {
                    extraStyle = extraStyle.copyWith(drawingPaths: null);
                  }
                }
              }
            case 'pos':
              {
                // \pos: line position
                final match = multiParamPattern.firstMatch(param);
                if (match != null) {
                  final g = match.group(1);
                  if (g != null) {
                    final params = g.split(',');
                    if (params.length == 2) {
                      final x = double.tryParse(params[0]);
                      final y = double.tryParse(params[1]);
                      if (x != null && y != null) {
                        line = line.copyWith(position: Offset(x, y));
                      }
                    }
                  }
                }
              }
            case 'r':
              // \r: reset
              textStyle = baseStyle;
            case 's':
              // \s: strikeout
              textStyle = textStyle.copyWith(decoration: param == '1' ? TextDecoration.lineThrough : TextDecoration.none);
            case 'u':
              // \u: underline
              textStyle = textStyle.copyWith(decoration: param == '1' ? TextDecoration.underline : TextDecoration.none);
            // TODO TLAD [subtitles] SHOULD support the following
            case 'shad':
            case 't': // \t: animated transform
            case 'xshad':
            case 'yshad':
            // line props: \pos, \move, \clip, \iclip, \org, \fade and \fad
            case 'iclip': // \iclip: clip (inverse)
            case 'fad': // \fad: fade
            case 'fade': // \fade: fade (complex)
            case 'move': // \move: movement
            case 'org': // \org: rotation origin
            // TODO TLAD [subtitles] MAY support the following
            case 'fe': // \fe: font encoding
            case 'pbo': // \pbo: baseline offset
            case 'q': // \q: wrap style
            // border size
            case 'xbord':
            case 'ybord':
            // karaoke
            case '2a':
            case '2c':
            case 'k':
            case 'K':
            case 'kf':
            case 'ko':
            default:
              debugPrint('unhandled ASS tag=$tag');
          }
        }
      });
    });
    if (i != text.length) {
      final spanText = extraStyle.drawingPaths?.isNotEmpty == true ? null : _replaceChars(text.substring(i));
      spans.add(StyledSubtitleSpan(
        textSpan: TextSpan(
          text: spanText,
          style: textStyle,
        ),
        extraStyle: extraStyle,
      ));
    }
    return line;
  }

  static SubtitleStyle _copyWithAlignment(Alignment? alignment, SubtitleStyle extraStyle) {
    if (alignment == null) return extraStyle;

    var hAlign = TextAlign.center;
    var vAlign = TextAlignVertical.bottom;
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
    return extraStyle.copyWith(
      hAlign: hAlign,
      vAlign: vAlign,
    );
  }

  static String _replaceChars(String text) => text.replaceAll(r'\h', UniChars.noBreakSpace).replaceAll(r'\N', '\n');

  static int? _parseAlpha(String param) {
    final match = alphaPattern.firstMatch(param);
    if (match != null) {
      final as = match.group(1);
      final ai = as != null ? int.tryParse(as, radix: 16) : null;
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

  static FontWeight? _parseFontWeight(String param) {
    switch (int.tryParse(param)) {
      case 0:
        return FontWeight.normal;
      case 1:
        return FontWeight.bold;
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return null;
    }
  }

  static Alignment? _parseNewAlignment(String param) {
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

  static Alignment? _parseLegacyAlignment(String param) {
    switch (int.tryParse(param)) {
      case 1:
        return Alignment.bottomLeft;
      case 2:
        return Alignment.bottomCenter;
      case 3:
        return Alignment.bottomRight;
      case 5:
        return Alignment.topLeft;
      case 6:
        return Alignment.topCenter;
      case 7:
        return Alignment.topRight;
      case 9:
        return Alignment.centerLeft;
      case 10:
        return Alignment.center;
      case 11:
        return Alignment.centerRight;
      default:
        return null;
    }
  }

  static List<Path> _parsePaths(String commands, int scale) {
    final paths = <Path>[];
    Path? path;
    pathPattern.allMatches(commands).forEach((match) {
      if (match.groupCount == 2) {
        final command = match.group(1)!;
        final params = match.group(2)!.trim().split(' ').map(double.tryParse).nonNulls.map((v) => v / scale).toList();
        switch (command) {
          case 'b':
            if (path != null) {
              const bParamCount = 6;
              final steps = (params.length / bParamCount).floor();
              for (var i = 0; i < steps; i++) {
                final points = params.skip(i * bParamCount).take(bParamCount).toList();
                path!.cubicTo(points[0], points[1], points[2], points[3], points[4], points[5]);
              }
            }
          case 'c':
            if (path != null) {
              path!.close();
            }
            path = null;
          case 'l':
            if (path != null) {
              const lParamCount = 2;
              final steps = (params.length / lParamCount).floor();
              for (var i = 0; i < steps; i++) {
                final points = params.skip(i * lParamCount).take(lParamCount).toList();
                path!.lineTo(points[0], points[1]);
              }
            }
          case 'm':
            if (params.length == 2) {
              if (path != null) {
                path!.close();
              }
              path = Path();
              paths.add(path!);
              path!.moveTo(params[0], params[1]);
            }
          case 'n':
            if (params.length == 2 && path != null) {
              path!.moveTo(params[0], params[1]);
            }
          case 's':
          case 'p':
            debugPrint('unhandled ASS drawing command=$command');
        }
      }
    });
    if (path != null) {
      path!.close();
    }
    return paths;
  }

  static List<Path>? _parseClip(String param) {
    List<Path>? paths;
    final match = multiParamPattern.firstMatch(param);
    if (match != null) {
      final g = match.group(1);
      if (g != null) {
        final params = g.split(',');
        if (params.length == 4) {
          final points = params.map(double.tryParse).nonNulls.toList();
          if (points.length == 4) {
            paths = [
              Path()
                ..addRect(Rect.fromPoints(
                  Offset(points[0], points[1]),
                  Offset(points[2], points[3]),
                ))
            ];
          }
        } else {
          int? scale;
          String? commands;
          if (params.length == 1) {
            scale = 1;
            commands = params[0];
          } else if (params.length == 2) {
            scale = int.tryParse(params[0]);
            commands = params[1];
          }
          if (scale != null && commands != null) {
            paths = _parsePaths(commands, scale);
          }
        }
      }
    }
    return paths;
  }
}
