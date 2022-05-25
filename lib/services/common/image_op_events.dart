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
  final bool deleted;

  @override
  List<Object?> get props => [success, skipped, uri, newFields, deleted];

  const MoveOpEvent({
    required super.success,
    required super.skipped,
    required super.uri,
    required this.newFields,
    required this.deleted,
  });

  factory MoveOpEvent.fromMap(Map map) {
    final newFields = map['newFields'] ?? {};
    final skipped = (map['skipped'] ?? false) || (newFields['skipped'] ?? false);
    final deleted = (map['deleted'] ?? false) || (newFields['deleted'] ?? false);
    return MoveOpEvent(
      success: (map['success'] ?? false) || skipped,
      skipped: skipped,
      uri: map['uri'],
      newFields: newFields,
      deleted: deleted,
    );
  }
}

@immutable
class ExportOpEvent extends MoveOpEvent {
  final int? pageId;

  @override
  List<Object?> get props => [success, skipped, uri, pageId, newFields];

  const ExportOpEvent({
    required super.success,
    required super.skipped,
    required super.uri,
    this.pageId,
    required super.newFields,
  }) : super(
          deleted: false,
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
