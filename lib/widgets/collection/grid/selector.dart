import 'dart:async';
import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class GridSelectionGestureDetector extends StatefulWidget {
  final bool selectable;
  final CollectionLens collection;
  final ScrollController scrollController;
  final ValueNotifier<double> appBarHeightNotifier;
  final Widget child;

  const GridSelectionGestureDetector({
    this.selectable = true,
    @required this.collection,
    @required this.scrollController,
    @required this.appBarHeightNotifier,
    @required this.child,
  });

  @override
  _GridSelectionGestureDetectorState createState() => _GridSelectionGestureDetectorState();
}

class _GridSelectionGestureDetectorState extends State<GridSelectionGestureDetector> {
  bool _pressing, _selecting;
  int _fromIndex, _lastToIndex;
  Offset _localPosition;
  EdgeInsets _scrollableInsets;
  double _scrollSpeedFactor;
  Timer _updateTimer;

  CollectionLens get collection => widget.collection;

  List<ImageEntry> get entries => collection.sortedEntries;

  ScrollController get scrollController => widget.scrollController;

  double get appBarHeight => widget.appBarHeightNotifier.value;

  static const double scrollEdgeRatio = .15;
  static const double scrollMaxPixelPerSecond = 600.0;
  static const Duration scrollUpdateInterval = Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: widget.selectable
          ? (details) {
              final fromEntry = _getEntryAt(details.localPosition);
              if (fromEntry == null) return;

              collection.toggleSelection(fromEntry);
              _selecting = collection.isSelected([fromEntry]);
              _fromIndex = entries.indexOf(fromEntry);
              _lastToIndex = _fromIndex;
              _scrollableInsets = EdgeInsets.only(
                top: appBarHeight,
                bottom: context.read<MediaQueryData>().viewInsets.bottom,
              );
              _scrollSpeedFactor = 0;
              _pressing = true;
            }
          : null,
      onLongPressMoveUpdate: widget.selectable
          ? (details) {
              if (!_pressing) return;
              _localPosition = details.localPosition;
              _onLongPressUpdate();
            }
          : null,
      onLongPressEnd: widget.selectable
          ? (details) {
              if (!_pressing) return;
              _setScrollSpeed(0);
              _pressing = false;
            }
          : null,
      child: widget.child,
    );
  }

  void _onLongPressUpdate() {
    final dy = _localPosition.dy;

    final height = scrollController.position.viewportDimension;
    final top = dy < height / 2;

    final distanceToEdge = max(0, top ? dy - _scrollableInsets.top : height - dy - _scrollableInsets.bottom);
    final threshold = height * scrollEdgeRatio;
    if (distanceToEdge < threshold) {
      _setScrollSpeed((top ? -1 : 1) * roundToPrecision((threshold - distanceToEdge) / threshold, decimals: 1));
    } else {
      _setScrollSpeed(0);
    }

    final toEntry = _getEntryAt(_localPosition);
    _toggleSelectionToIndex(entries.indexOf(toEntry));
  }

  void _setScrollSpeed(double speedFactor) {
    if (speedFactor == _scrollSpeedFactor) return;
    _scrollSpeedFactor = speedFactor;
    _updateTimer?.cancel();

    final current = scrollController.offset;
    if (speedFactor == 0) {
      scrollController.jumpTo(current);
      return;
    }

    final target = speedFactor > 0 ? scrollController.position.maxScrollExtent : .0;
    if (target != current) {
      final distance = target - current;
      final millis = distance * 1000 / scrollMaxPixelPerSecond / speedFactor;
      scrollController.animateTo(
        target,
        duration: Duration(milliseconds: millis.round()),
        curve: Curves.linear,
      );
      // use a timer to update the entry selection, because `onLongPressMoveUpdate`
      // is not called when the pointer stays still while the view is scrolling
      _updateTimer = Timer.periodic(scrollUpdateInterval, (_) => _onLongPressUpdate());
    }
  }

  ImageEntry _getEntryAt(Offset localPosition) {
    // as of Flutter v1.22.5, `hitTest` on the `ScrollView` render object works fine when it is static,
    // but when it is scrolling (through controller animation), result is incomplete and children are missing,
    // so we use custom layout computation instead to find the entry.
    final offset = Offset(0, scrollController.offset - appBarHeight) + localPosition;
    final sectionedListLayout = context.read<SectionedListLayout<ImageEntry>>();
    return sectionedListLayout.getEntryAt(offset);
  }

  void _toggleSelectionToIndex(int toIndex) {
    if (toIndex == -1) return;

    if (_selecting) {
      if (toIndex <= _fromIndex) {
        if (toIndex < _lastToIndex) {
          collection.addToSelection(entries.getRange(toIndex, min(_fromIndex, _lastToIndex)));
          if (_fromIndex < _lastToIndex) {
            collection.removeFromSelection(entries.getRange(_fromIndex + 1, _lastToIndex + 1));
          }
        } else if (_lastToIndex < toIndex) {
          collection.removeFromSelection(entries.getRange(_lastToIndex, toIndex));
        }
      } else if (_fromIndex < toIndex) {
        if (_lastToIndex < toIndex) {
          collection.addToSelection(entries.getRange(max(_fromIndex, _lastToIndex), toIndex + 1));
          if (_lastToIndex < _fromIndex) {
            collection.removeFromSelection(entries.getRange(_lastToIndex, _fromIndex));
          }
        } else if (toIndex < _lastToIndex) {
          collection.removeFromSelection(entries.getRange(toIndex + 1, _lastToIndex + 1));
        }
      }
      _lastToIndex = toIndex;
    } else {
      collection.removeFromSelection(entries.getRange(min(_fromIndex, toIndex), max(_fromIndex, toIndex) + 1));
    }
  }
}
