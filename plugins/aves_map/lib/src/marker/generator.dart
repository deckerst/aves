import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

// generate bitmap from widget, for Google map
class MarkerGeneratorWidget<T extends Key> extends StatefulWidget {
  final List<Widget> markers;
  final bool Function(T markerKey) isReadyToRender;
  final void Function(T markerKey, Uint8List bitmap) onRendered;

  const MarkerGeneratorWidget({
    Key? key,
    required this.markers,
    required this.isReadyToRender,
    required this.onRendered,
  }) : super(key: key);

  @override
  State<MarkerGeneratorWidget<T>> createState() => _MarkerGeneratorWidgetState<T>();
}

class _MarkerGeneratorWidgetState<T extends Key> extends State<MarkerGeneratorWidget<T>> {
  final Set<_MarkerGeneratorItem<T>> _items = {};

  @override
  void initState() {
    super.initState();
    _checkNextFrame();
  }

  @override
  void didUpdateWidget(covariant MarkerGeneratorWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.markers.forEach((markerWidget) {
      final item = getOrCreate(markerWidget.key as T);
      item.globalKey = GlobalKey();
    });
    _checkNextFrame();
  }

  void _checkNextFrame() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (!mounted) return;
      final waitingItems = _items.where((v) => v.isWaiting).toSet();
      final readyItems = waitingItems.where((v) => widget.isReadyToRender(v.markerKey)).toSet();
      readyItems.forEach((v) async {
        final bitmap = await v.render();
        if (bitmap != null) {
          widget.onRendered(v.markerKey, bitmap);
        }
      });
      if (readyItems.length < waitingItems.length) {
        _checkNextFrame();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(context.select<MediaQueryData, double>((mq) => mq.size.width), 0),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: _items.map((item) {
            return RepaintBoundary(
              key: item.globalKey,
              child: widget.markers.firstWhereOrNull((v) => v.key == item.markerKey) ?? const SizedBox(),
            );
          }).toList(),
        ),
      ),
    );
  }

  _MarkerGeneratorItem getOrCreate(T markerKey) {
    final existingItem = _items.firstWhereOrNull((v) => v.markerKey == markerKey);
    if (existingItem != null) return existingItem;

    final newItem = _MarkerGeneratorItem(markerKey);
    _items.add(newItem);
    return newItem;
  }
}

enum MarkerGeneratorItemState { waiting, rendering, done }

class _MarkerGeneratorItem<T extends Key> {
  final T markerKey;
  GlobalKey? globalKey;
  MarkerGeneratorItemState state = MarkerGeneratorItemState.waiting;

  _MarkerGeneratorItem(this.markerKey);

  bool get isWaiting => state == MarkerGeneratorItemState.waiting;

  Future<Uint8List?> render() async {
    Uint8List? bytes;
    final _globalKey = globalKey;
    if (_globalKey != null) {
      state = MarkerGeneratorItemState.rendering;
      final boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      if (boundary.hasSize && boundary.size != Size.zero) {
        try {
          final image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          bytes = byteData?.buffer.asUint8List();
        } catch (error) {
          // happens when widget is offscreen
          debugPrint('failed to render image for key=$_globalKey with error=$error');
        }
      }
      state = bytes != null ? MarkerGeneratorItemState.done : MarkerGeneratorItemState.waiting;
    }
    return bytes;
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{markerKey=$markerKey, globalKey=$globalKey, state=$state}';
}
