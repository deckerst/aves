import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class const TrashDetails({
  required final int id,
  required final String path,
  required final int dateMillis,
}) extends Equatable {
  @override
  List<Object?> get props => [id, path, dateMillis];

  TrashDetails copyWith({
    int? id,
  }) {
    return TrashDetails(
      id: id ?? this.id,
      path: path,
      dateMillis: dateMillis,
    );
  }

  factory fromMap(Map map) {
    return TrashDetails(
      id: map['id'] as int,
      path: map['path'] as String,
      dateMillis: map['dateMillis'] as int,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'path': path,
    'dateMillis': dateMillis,
  };

  Map<String, Object?> toDbMap() => toMap();
}
