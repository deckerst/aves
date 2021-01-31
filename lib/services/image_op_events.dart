import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class ImageOpEvent {
  final bool success;
  final String uri;

  const ImageOpEvent({
    this.success,
    this.uri,
  });

  factory ImageOpEvent.fromMap(Map map) {
    return ImageOpEvent(
      success: map['success'] ?? false,
      uri: map['uri'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ImageOpEvent && other.success == success && other.uri == uri;
  }

  @override
  int get hashCode => hashValues(success, uri);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{success=$success, uri=$uri}';
}

class MoveOpEvent extends ImageOpEvent {
  final Map newFields;

  const MoveOpEvent({bool success, String uri, this.newFields})
      : super(
          success: success,
          uri: uri,
        );

  factory MoveOpEvent.fromMap(Map map) {
    return MoveOpEvent(
      success: map['success'] ?? false,
      uri: map['uri'],
      newFields: map['newFields'],
    );
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{success=$success, uri=$uri, newFields=$newFields}';
}

class ExportOpEvent extends MoveOpEvent {
  final int pageId;

  const ExportOpEvent({bool success, String uri, this.pageId, Map newFields})
      : super(
          success: success,
          uri: uri,
          newFields: newFields,
        );

  factory ExportOpEvent.fromMap(Map map) {
    return ExportOpEvent(
      success: map['success'] ?? false,
      uri: map['uri'],
      pageId: map['pageId'],
      newFields: map['newFields'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ExportOpEvent && other.success == success && other.uri == uri && other.pageId == pageId;
  }

  @override
  int get hashCode => hashValues(success, uri, pageId);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{success=$success, uri=$uri, pageId=$pageId, newFields=$newFields}';
}
