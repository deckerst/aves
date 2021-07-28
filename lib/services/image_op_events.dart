import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class ImageOpEvent extends Equatable {
  final bool success;
  final String uri;

  @override
  List<Object?> get props => [success, uri];

  const ImageOpEvent({
    required this.success,
    required this.uri,
  });

  factory ImageOpEvent.fromMap(Map map) {
    return ImageOpEvent(
      success: map['success'] ?? false,
      uri: map['uri'],
    );
  }
}

class MoveOpEvent extends ImageOpEvent {
  final Map newFields;

  const MoveOpEvent({required bool success, required String uri, required this.newFields})
      : super(
          success: success,
          uri: uri,
        );

  factory MoveOpEvent.fromMap(Map map) {
    return MoveOpEvent(
      success: map['success'] ?? false,
      uri: map['uri'],
      newFields: map['newFields'] ?? {},
    );
  }

  @override
  String toString() => '$runtimeType#${shortHash(this)}{success=$success, uri=$uri, newFields=$newFields}';
}

class ExportOpEvent extends MoveOpEvent {
  final int? pageId;

  @override
  List<Object?> get props => [success, uri, pageId];

  const ExportOpEvent({required bool success, required String uri, this.pageId, required Map newFields})
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
      newFields: map['newFields'] ?? {},
    );
  }
}
