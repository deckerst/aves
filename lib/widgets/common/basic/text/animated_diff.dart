import 'dart:math';

import 'package:aves/utils/diff_match.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

class AnimatedDiffText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final StrutStyle? strutStyle;
  final Curve curve;
  final Duration duration;

  const AnimatedDiffText(
    this.text, {
    super.key,
    this.textStyle,
    this.strutStyle,
    this.curve = Curves.easeInOutCubic,
    required this.duration,
  });

  @override
  State<AnimatedDiffText> createState() => _AnimatedDiffTextState();
}

class _AnimatedDiffTextState extends State<AnimatedDiffText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  final List<_TextDiff> _diffs = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _computeDiff(widget.text, widget.text);
  }

  @override
  void didUpdateWidget(covariant AnimatedDiffText oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldText = oldWidget.text;
    final newText = widget.text;
    if (oldText != newText) {
      _computeDiff(oldText, newText);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text.rich(
          TextSpan(
            children: _diffs.map((diff) {
              final oldText = diff.item1;
              final newText = diff.item2;
              final oldWidth = diff.item3;
              final newWidth = diff.item4;
              final text = (_animation.value == 0 ? oldText : newText) ?? '';
              return WidgetSpan(
                child: AnimatedSize(
                  key: ValueKey(diff),
                  curve: widget.curve,
                  duration: widget.duration,
                  child: AnimatedSwitcher(
                    duration: widget.duration,
                    switchInCurve: widget.curve,
                    switchOutCurve: widget.curve,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ...previousChildren.map(
                            (child) => ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: min(oldWidth, newWidth),
                              ),
                              child: child,
                            ),
                          ),
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: Text(
                      text,
                      key: Key(text),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          strutStyle: widget.strutStyle,
        );
      },
    );
  }

  double textWidth(String text) {
    final para = RenderParagraph(
      TextSpan(text: text, style: widget.textStyle),
      textDirection: Directionality.of(context),
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
      strutStyle: widget.strutStyle,
    )..layout(const BoxConstraints(), parentUsesSize: true);
    return para.getMaxIntrinsicWidth(double.infinity);
  }

  // use an adaptation of Google's `Diff Match and Patch`
  // as package `diffutil_dart` (as of v3.0.0) is unreliable
  void _computeDiff(String oldText, String newText) {
    final oldCharacters = oldText.characters.join();
    final newCharacters = newText.characters.join();

    final dmp = DiffMatchPatch();
    final d = dmp.diff_main(oldCharacters, newCharacters);
    dmp.diff_cleanupSemantic(d);

    _diffs
      ..clear()
      ..addAll(d.map((diff) {
        final text = diff.text;
        switch (diff.operation) {
          case Operation.delete:
            return Tuple4(text, null, textWidth(text), .0);
          case Operation.insert:
            return Tuple4(null, text, .0, textWidth(text));
          case Operation.equal:
          default:
            final width = textWidth(text);
            return Tuple4(text, text, width, width);
        }
      }).fold<List<_TextDiff>>([], (prev, v) {
        if (prev.isNotEmpty) {
          final last = prev.last;
          final prevNewText = last.item2;
          if (prevNewText == null) {
            // previous diff is a deletion
            final thisOldText = v.item1;
            if (thisOldText == null) {
              // this diff is an insertion
              // merge deletion and insertion as a change operation
              final change = Tuple4(last.item1, v.item2, last.item3, v.item4);
              return [...prev.take(prev.length - 1), change];
            }
          }
        }
        return [...prev, v];
      }));
  }

// void _computeDiff(String oldText, String newText) {
//   final oldCharacters = oldText.characters.toList();
//   final newCharacters = newText.characters.toList();
//   final diffResult = calculateListDiff<String>(oldCharacters, newCharacters, detectMoves: false);
//   final updates = diffResult.getUpdatesWithData().toList();
//   List<TextDiff> diffs = [];
//   DataDiffUpdate<String>? pendingUpdate;
//   int lastPos = oldCharacters.length;
//   void addKeep(int pos) {
//     if (pos < lastPos) {
//       final text = oldCharacters.sublist(pos, lastPos).join();
//       final width = textWidth(text);
//       diffs.insert(0, Tuple4(text, text, width, width));
//       lastPos = pos;
//     }
//   }
//
//   void commit(DataDiffUpdate<String>? update) {
//     update?.when(
//       insert: (pos, data) {
//         addKeep(pos);
//         diffs.insert(0, Tuple4(null, data, 0, textWidth(data)));
//         lastPos = pos;
//       },
//       remove: (pos, data) {
//         addKeep(pos + data.length);
//         diffs.insert(0, Tuple4(data, null, textWidth(data), 0));
//         lastPos = pos;
//       },
//       change: (pos, oldData, newData) {
//         addKeep(pos + oldData.length);
//         diffs.insert(0, Tuple4(oldData, newData, textWidth(oldData), textWidth(newData)));
//         lastPos = pos;
//       },
//       move: (from, to, data) {
//         assert(false, '`move` update: from=$from, to=$from, data=$data');
//       },
//     );
//   }
//
//   for (var update in updates) {
//     update.when(
//       insert: (pos, data) {
//         if (pendingUpdate == null) {
//           pendingUpdate = update;
//           return;
//         }
//         if (pendingUpdate is DataInsert) {
//           final pendingInsert = pendingUpdate as DataInsert;
//           if (pendingInsert.position == pos) {
//             // merge insertions
//             pendingUpdate = DataInsert(position: pos, data: data + pendingInsert.data);
//             return;
//           }
//         } else if (pendingUpdate is DataRemove) {
//           final pendingRemove = pendingUpdate as DataRemove;
//           if (pendingRemove.position == pos) {
//             // convert to change
//             pendingUpdate = DataChange(position: pos, oldData: pendingRemove.data, newData: data);
//             return;
//           }
//         } else if (pendingUpdate is DataChange) {
//           final pendingChange = pendingUpdate as DataChange;
//           if (pendingChange.position == pos) {
//             // merge changes
//             pendingUpdate = DataChange(position: pos, oldData: pendingChange.oldData, newData: data + pendingChange.newData);
//             return;
//           }
//         }
//         commit(pendingUpdate);
//         pendingUpdate = update;
//       },
//       remove: (pos, data) {
//         if (pendingUpdate == null) {
//           pendingUpdate = update;
//           return;
//         }
//         if (pendingUpdate is DataRemove) {
//           final pendingRemove = pendingUpdate as DataRemove;
//           if (pendingRemove.position == pos + data.length) {
//             // merge removals
//             pendingUpdate = DataRemove(position: pos, data: data + pendingRemove.data);
//             return;
//           }
//         }
//         commit(pendingUpdate);
//         pendingUpdate = update;
//       },
//       change: (pos, oldData, newData) {
//         assert(false, '`change` update: from=$pos, oldData=$oldData, newData=$newData');
//       },
//       move: (from, to, data) {
//         assert(false, '`move` update: from=$from, to=$from, data=$data');
//       },
//     );
//   }
//   commit(pendingUpdate);
//   addKeep(0);
//   _diffs
//     ..clear()
//     ..addAll(diffs);
// }
}

typedef _TextDiff = Tuple4<String?, String?, double, double>;
