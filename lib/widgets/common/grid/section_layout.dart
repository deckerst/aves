import 'dart:math';

import 'package:aves/model/source/section_keys.dart';
import 'package:aves/theme/durations.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

abstract class SectionedListLayoutProvider<T> extends StatelessWidget {
  final double scrollableWidth;
  final int columnCount;
  final double spacing, tileWidth, tileHeight;
  final Widget Function(T item) tileBuilder;
  final Duration tileAnimationDelay;
  final Widget child;

  const SectionedListLayoutProvider({
    Key? key,
    required this.scrollableWidth,
    required this.columnCount,
    required this.spacing,
    required this.tileWidth,
    required this.tileHeight,
    required this.tileBuilder,
    required this.tileAnimationDelay,
    required this.child,
  })  : assert(scrollableWidth != 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider0<SectionedListLayout<T>>(
      update: (context, _) => _updateLayouts(context),
      child: child,
    );
  }

  SectionedListLayout<T> _updateLayouts(BuildContext context) {
    final _showHeaders = showHeaders;
    final _sections = sections;
    final sectionKeys = _sections.keys.toList();
    final animate = tileAnimationDelay > Duration.zero;

    final sectionLayouts = <SectionLayout>[];
    var currentIndex = 0;
    var currentOffset = 0.0;
    sectionKeys.forEach((sectionKey) {
      final section = _sections[sectionKey]!;
      final sectionItemCount = section.length;
      final rowCount = (sectionItemCount / columnCount).ceil();
      final sectionChildCount = 1 + rowCount;

      final headerExtent = _showHeaders ? getHeaderExtent(context, sectionKey) : 0.0;

      final sectionFirstIndex = currentIndex;
      currentIndex += sectionChildCount;
      final sectionLastIndex = currentIndex - 1;

      final sectionMinOffset = currentOffset;
      currentOffset += headerExtent + tileHeight * rowCount + spacing * (rowCount - 1);
      final sectionMaxOffset = currentOffset;

      sectionLayouts.add(
        SectionLayout(
          sectionKey: sectionKey,
          firstIndex: sectionFirstIndex,
          lastIndex: sectionLastIndex,
          minOffset: sectionMinOffset,
          maxOffset: sectionMaxOffset,
          headerExtent: headerExtent,
          tileHeight: tileHeight,
          spacing: spacing,
          builder: (context, listIndex) => _buildInSection(
            context,
            section,
            listIndex * columnCount,
            listIndex - sectionFirstIndex,
            sectionKey,
            headerExtent,
            animate,
          ),
        ),
      );
    });
    return SectionedListLayout<T>(
      sections: _sections,
      showHeaders: _showHeaders,
      columnCount: columnCount,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      spacing: spacing,
      sectionLayouts: sectionLayouts,
    );
  }

  Widget _buildInSection(
    BuildContext context,
    List<T> section,
    int sectionGridIndex,
    int sectionChildIndex,
    SectionKey sectionKey,
    double headerExtent,
    bool animate,
  ) {
    if (sectionChildIndex == 0) {
      final header = headerExtent > 0 ? buildHeader(context, sectionKey, headerExtent) : const SizedBox.shrink();
      return animate ? _buildAnimation(sectionGridIndex, header) : header;
    }
    sectionChildIndex--;

    final sectionItemCount = section.length;

    final minItemIndex = sectionChildIndex * columnCount;
    final maxItemIndex = min(sectionItemCount, minItemIndex + columnCount);
    final children = <Widget>[];
    for (var i = minItemIndex; i < maxItemIndex; i++) {
      final itemGridIndex = sectionGridIndex + i - minItemIndex;
      final item = RepaintBoundary(
        child: tileBuilder(section[i]),
      );
      children.add(animate ? _buildAnimation(itemGridIndex, item) : item);
    }
    return _GridRow(
      width: tileWidth,
      height: tileHeight,
      spacing: spacing,
      children: children,
    );
  }

  Widget _buildAnimation(int index, Widget child) {
    return AnimationConfiguration.staggeredGrid(
      position: index,
      columnCount: columnCount,
      duration: Durations.staggeredAnimation,
      delay: tileAnimationDelay,
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }

  bool get showHeaders;

  Map<SectionKey, List<T>> get sections;

  double getHeaderExtent(BuildContext context, SectionKey sectionKey);

  Widget buildHeader(BuildContext context, SectionKey sectionKey, double headerExtent);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('scrollableWidth', scrollableWidth));
    properties.add(IntProperty('columnCount', columnCount));
    properties.add(DoubleProperty('spacing', spacing));
    properties.add(DoubleProperty('tileWidth', tileWidth));
    properties.add(DoubleProperty('tileHeight', tileHeight));
    properties.add(DiagnosticsProperty<bool>('showHeaders', showHeaders));
  }
}

class SectionedListLayout<T> {
  final Map<SectionKey, List<T>> sections;
  final bool showHeaders;
  final int columnCount;
  final double tileWidth, tileHeight, spacing;
  final List<SectionLayout> sectionLayouts;

  const SectionedListLayout({
    required this.sections,
    required this.showHeaders,
    required this.columnCount,
    required this.tileWidth,
    required this.tileHeight,
    required this.spacing,
    required this.sectionLayouts,
  });

  Rect? getTileRect(T item) {
    final MapEntry<SectionKey?, List<T>>? section = sections.entries.firstWhereOrNull((kv) => kv.value.contains(item));
    if (section == null) return null;

    final sectionKey = section.key;
    final sectionLayout = sectionLayouts.firstWhereOrNull((sl) => sl.sectionKey == sectionKey);
    if (sectionLayout == null) return null;

    final sectionItemIndex = section.value.indexOf(item);
    final column = sectionItemIndex % columnCount;
    final row = (sectionItemIndex / columnCount).floor();
    final listIndex = sectionLayout.firstIndex + 1 + row;

    final left = tileWidth * column + spacing * (column - 1);
    final top = sectionLayout.indexToLayoutOffset(listIndex);
    return Rect.fromLTWH(left, top, tileWidth, tileHeight);
  }

  SectionLayout? getSectionAt(double offsetY) => sectionLayouts.firstWhereOrNull((sl) => offsetY < sl.maxOffset);

  T? getItemAt(Offset position) {
    var dy = position.dy;
    final sectionLayout = getSectionAt(dy);
    if (sectionLayout == null) return null;

    final section = sections[sectionLayout.sectionKey];
    if (section == null) return null;

    dy -= sectionLayout.minOffset + sectionLayout.headerExtent;
    if (dy < 0) return null;

    final row = dy ~/ (tileHeight + spacing);
    final column = position.dx ~/ (tileWidth + spacing);
    final index = row * columnCount + column;
    if (index >= section.length) return null;

    return section[index];
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{sectionCount=${sections.length} columnCount=$columnCount, tileWidth=$tileWidth, tileHeight=$tileHeight}';
}

@immutable
class SectionLayout extends Equatable {
  final SectionKey sectionKey;
  final int firstIndex, lastIndex, bodyFirstIndex;
  final double minOffset, maxOffset, bodyMinOffset;
  final double headerExtent, tileHeight, spacing, mainAxisStride;
  final IndexedWidgetBuilder builder;

  @override
  List<Object?> get props => [sectionKey, firstIndex, lastIndex, minOffset, maxOffset, headerExtent, tileHeight, spacing];

  const SectionLayout({
    required this.sectionKey,
    required this.firstIndex,
    required this.lastIndex,
    required this.minOffset,
    required this.maxOffset,
    required this.headerExtent,
    required this.tileHeight,
    required this.spacing,
    required this.builder,
  })  : bodyFirstIndex = firstIndex + 1,
        bodyMinOffset = minOffset + headerExtent,
        mainAxisStride = tileHeight + spacing;

  bool hasChild(int index) => firstIndex <= index && index <= lastIndex;

  bool hasChildAtOffset(double scrollOffset) => minOffset <= scrollOffset && scrollOffset <= maxOffset;

  double indexToLayoutOffset(int index) {
    index -= bodyFirstIndex;
    if (index < 0) return minOffset;
    return bodyMinOffset + index * mainAxisStride;
  }

  int getMinChildIndexForScrollOffset(double scrollOffset) {
    scrollOffset -= bodyMinOffset;
    if (scrollOffset < 0) return firstIndex;
    return bodyFirstIndex + scrollOffset ~/ mainAxisStride;
  }

  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    scrollOffset -= bodyMinOffset;
    if (scrollOffset < 0) return firstIndex;
    return bodyFirstIndex + (scrollOffset / mainAxisStride).ceil() - 1;
  }
}

class _GridRow extends MultiChildRenderObjectWidget {
  final double width, height, spacing;

  _GridRow({
    Key? key,
    required this.width,
    required this.height,
    required this.spacing,
    required List<Widget> children,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGridRow(
      width: width,
      height: height,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderGridRow renderObject) {
    renderObject.width = width;
    renderObject.height = height;
    renderObject.spacing = spacing;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('spacing', spacing));
  }
}

class _GridRowParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderGridRow extends RenderBox with ContainerRenderObjectMixin<RenderBox, _GridRowParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _GridRowParentData> {
  _RenderGridRow({
    List<RenderBox>? children,
    required double width,
    required double height,
    required double spacing,
  })  : _width = width,
        _height = height,
        _spacing = spacing {
    addAll(children);
  }

  double get width => _width;
  double _width;

  set width(double value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  double get height => _height;
  double _height;

  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  double get spacing => _spacing;
  double _spacing;

  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GridRowParentData) {
      child.parentData = _GridRowParentData();
    }
  }

  double get intrinsicWidth => width * childCount + spacing * (childCount - 1);

  @override
  double computeMinIntrinsicWidth(double height) => intrinsicWidth;

  @override
  double computeMaxIntrinsicWidth(double height) => intrinsicWidth;

  @override
  double computeMinIntrinsicHeight(double width) => height;

  @override
  double computeMaxIntrinsicHeight(double width) => height;

  @override
  void performLayout() {
    var child = firstChild;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    size = Size(constraints.maxWidth, height);
    final childConstraints = BoxConstraints.tight(Size(width, height));
    var offset = Offset.zero;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: false);
      final childParentData = child.parentData! as _GridRowParentData;
      childParentData.offset = offset;
      offset += Offset(width + spacing, 0);
      child = childParentData.nextSibling;
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('spacing', spacing));
  }
}
