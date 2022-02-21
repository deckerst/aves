import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class TrashDetails extends Equatable {
  final int id;
  final String path;
  final int dateMillis;

  @override
  List<Object?> get props => [id, path, dateMillis];

  const TrashDetails({
    required this.id,
    required this.path,
    required this.dateMillis,
  });

  TrashDetails copyWith({
    int? id,
  }) {
    return TrashDetails(
      id: id ?? this.id,
      path: path,
      dateMillis: dateMillis,
    );
  }

  factory TrashDetails.fromMap(Map map) {
    return TrashDetails(
      id: map['id'] as int,
      path: map['path'] as String,
      dateMillis: map['dateMillis'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'path': path,
        'dateMillis': dateMillis,
      };
}
