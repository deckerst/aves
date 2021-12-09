import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class ImageOpEvent extends Equatable {
  final bool success, skipped;
  final String uri;

  @override
  List<Object?> get props => [success, skipped, uri];

  const ImageOpEvent({
    required this.success,
    required this.skipped,
    required this.uri,
  });

  factory ImageOpEvent.fromMap(Map map) {
    final skipped = map['skipped'] ?? false;
    return ImageOpEvent(
      success: (map['success'] ?? false) || skipped,
      skipped: skipped,
      uri: map['uri'],
    );
  }
}

@immutable
class MoveOpEvent extends ImageOpEvent {
  final Map newFields;

  @override
  List<Object?> get props => [success, skipped, uri, newFields];

  const MoveOpEvent({
    required bool success,
    required bool skipped,
    required String uri,
    required this.newFields,
  }) : super(
          success: success,
          skipped: skipped,
          uri: uri,
        );

  factory MoveOpEvent.fromMap(Map map) {
    final newFields = map['newFields'] ?? {};
    final skipped = (map['skipped'] ?? false) || (newFields['skipped'] ?? false);
    return MoveOpEvent(
      success: (map['success'] ?? false) || skipped,
      skipped: skipped,
      uri: map['uri'],
      newFields: newFields,
    );
  }
}

@immutable
class ExportOpEvent extends MoveOpEvent {
  final int? pageId;

  @override
  List<Object?> get props => [success, skipped, uri, pageId, newFields];

  const ExportOpEvent({
    required bool success,
    required bool skipped,
    required String uri,
    this.pageId,
    required Map newFields,
  }) : super(
          success: success,
          skipped: skipped,
          uri: uri,
          newFields: newFields,
        );

  factory ExportOpEvent.fromMap(Map map) {
    final newFields = map['newFields'] ?? {};
    final skipped = (map['skipped'] ?? false) || (newFields['skipped'] ?? false);
    return ExportOpEvent(
      success: (map['success'] ?? false) || skipped,
      skipped: skipped,
      uri: map['uri'],
      pageId: map['pageId'],
      newFields: newFields,
    );
  }
}
