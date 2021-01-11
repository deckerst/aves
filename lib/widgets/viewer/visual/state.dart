import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ViewState {
  final Offset position;
  final double scale;
  final Size viewportSize;

  static const ViewState zero = ViewState(Offset.zero, 0, null);

  const ViewState(this.position, this.scale, this.viewportSize);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{position=$position, scale=$scale, viewportSize=$viewportSize}';
}

class ViewStateNotification extends Notification {
  final String uri;
  final ViewState viewState;

  const ViewStateNotification(this.uri, this.viewState);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{uri=$uri, viewState=$viewState}';
}
